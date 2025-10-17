-- Define o banco de dados a ser utilizado para a sessão atual.
USE HubDados;
GO -- Separa os lotes de comandos. Boa prática em scripts mais longos.

-- 1. PREPARAÇÃO DO AMBIENTE
--------------------------------------------------------------------------------
-- Garante que as tabelas temporárias de execuções anteriores sejam removidas
-- para evitar erros de "objeto já existente".
DROP TABLE IF EXISTS #CCUSTO, #ORCAMENTO,#PLANO_CONTAS;

-- 2. CRIAÇÃO DAS TABELAS DE APOIO E FILTROS
--------------------------------------------------------------------------------
-- Cria uma tabela em memória (@CONTAS) para armazenar a lista de contas contábeis de interesse.
-- Esta abordagem é mais performática do que um longo `IN (...)` na consulta principal.
--
-- OTIMIZAÇÕES APLICADAS:
--   a) COLLATE Latin1_General_CI_AS: Garante que a "regra de texto" desta tabela seja
--      exatamente a mesma das tabelas do banco, eliminando erros de "Collation Conflict".
--   b) PRIMARY KEY: Cria um índice na coluna CONTA, o que torna a junção (INNER JOIN)
--      na consulta final extremamente rápida.
DECLARE @CONTAS AS TABLE (
    CONTA VARCHAR(50) COLLATE Latin1_General_CI_AS PRIMARY KEY
);

-- Define variáveis para o período de análise, tornando o script dinâmico.
--DECLARE @ANO INT = '2024';

-- Cria as datas de início e fim do ano para um filtro de data performático.
-- Esta abordagem (>= e <) é "SARGable", permitindo que o SQL Server use índices na coluna de data.
DECLARE @DATA_INICIO DATE = '2024-01-01';
DECLARE @DATA_FIM DATE = '2025-12-31';

-- Popula a tabela @CONTAS com a lista de contas a serem analisadas.
INSERT INTO @CONTAS (CONTA)
VALUES 
('3.1.1.1.01.001'), ('3.1.1.1.01.002'), ('3.1.1.1.01.004'), ('3.1.1.1.01.005'), ('3.1.1.1.01.008'),
('3.1.1.1.02.001'), ('3.1.1.1.03.001'), ('3.1.1.1.04.001'), ('3.1.1.1.04.999'), ('3.1.1.2.01.004'),
('3.1.1.2.01.005'), ('3.1.1.2.01.006'), ('3.1.1.3.01.001'), ('3.1.1.3.01.002'), ('3.1.1.3.01.003'),
('3.1.1.3.01.004'), ('3.1.1.3.01.005'), ('3.1.1.3.01.008'), ('3.1.1.3.01.999'), ('3.1.2.1.01.001'),
('3.1.2.1.01.002'), ('3.1.2.1.02.001'), ('3.1.2.1.02.002'), ('3.1.2.1.02.003'), ('3.1.2.1.02.004'),
('3.1.2.1.02.005'), ('3.1.2.1.02.006'), ('3.1.2.1.02.007'), ('3.1.2.1.02.008'), ('3.1.2.1.02.009'),
('3.1.2.1.02.010'), ('3.1.2.1.02.013'), ('3.1.2.1.02.014'), ('3.1.2.1.02.019'), ('3.1.2.1.02.022'),
('3.1.2.1.02.999'), ('3.1.2.1.03.001'), ('3.1.2.2.01.001'), ('3.1.2.2.01.002'), ('3.1.2.2.01.003'),
('3.1.2.2.01.004'), ('3.1.2.2.01.005'), ('3.1.2.2.01.006'), ('3.1.2.2.01.008'), ('3.1.2.2.01.999'),
('3.1.2.2.02.001'), ('3.1.2.2.02.002'), ('3.1.2.2.02.004'), ('3.1.2.2.02.007'), ('3.1.2.2.02.999'),
('3.1.2.3.01.001'), ('3.1.3.1.01.001'), ('3.1.3.1.01.002'), ('3.1.3.1.01.003'), ('3.1.3.1.01.004'),
('3.1.3.1.01.005'), ('3.1.3.1.01.006'), ('3.1.3.1.01.999'), ('3.1.3.1.02.001'), ('3.1.3.1.02.002'),
('3.1.3.1.02.003'), ('3.1.3.1.02.004'), ('3.1.3.1.02.005'), ('3.1.3.1.02.006'), ('3.1.3.1.02.009'),
('3.1.3.1.02.010'), ('3.1.3.1.02.999'), ('3.1.3.2.01.001'), ('3.1.3.2.01.002'), ('3.1.3.2.01.003'),
('3.1.3.2.01.004'), ('3.1.3.2.01.999'), ('3.1.3.2.02.004'), ('3.1.3.3.01.001'), ('3.1.3.3.01.002'),
('3.1.3.3.01.003'), ('3.1.3.3.01.005'), ('3.1.3.3.01.007'), ('3.1.3.3.01.008'), ('3.1.3.3.01.999'),
('3.1.3.4.01.002'), ('3.1.3.4.01.003'), ('3.1.3.4.01.005'), ('3.1.3.4.01.999'), ('3.1.3.5.01.001'),
('3.1.3.5.01.002'), ('3.1.3.5.01.003'), ('3.1.3.5.01.004'), ('3.1.3.5.01.005'), ('3.1.3.6.01.001'),
('3.1.3.6.01.002'), ('3.1.3.6.01.003'), ('3.1.3.6.01.004'), ('3.1.3.6.01.005'), ('3.1.3.6.01.006'),
('3.1.3.6.01.999'), ('3.1.3.7.01.001'), ('3.1.3.7.01.003'),
('3.1.3.7.01.004'), ('3.1.3.7.01.005'), ('3.1.3.7.01.006'),
('3.1.3.7.01.007'), ('3.1.3.7.01.008'), ('3.1.3.7.01.009'), ('3.1.3.7.01.010'), ('3.1.3.7.01.011'),
('3.1.3.7.01.015'), ('3.1.3.7.01.021'), ('3.1.3.7.01.023'), ('3.1.3.7.01.999'), ('3.1.3.8.01.001'),
('3.1.4.1.01.001'),('3.1.4.1.01.002'), ('3.1.4.1.01.003'), ('3.1.4.1.01.005'),('3.1.4.1.02.001'),
('3.1.4.2.01.001'), ('3.1.4.2.01.002'),
('3.1.4.2.01.004'), ('3.1.4.2.01.005'), ('3.1.4.2.01.006'), ('3.1.4.2.01.007'), ('3.1.4.2.01.999'),
('5.1.1.2.01.001'), ('5.2.2.2.01.001'), ('5.2.2.2.01.003'), ('5.2.2.2.01.004'), ('5.2.2.2.01.005'),('5.2.2.2.01.006'),
('5.2.4.1.01.001'), ('5.2.5.2.01.001');

-- 3. CRIAÇÃO DAS TABELAS DE DADOS TEMPORÁRIAS
--------------------------------------------------------------------------------
SELECT DISTINCT
    -- Contas e Descrições de todos os níveis
    Nivel6.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl6,
    Nivel6.[REDUZIDO] COLLATE Latin1_General_CI_AS as cdgReduzido,
    Nivel6.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl6,
    Nivel1.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl1,
    Nivel1.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl1,
    Nivel2.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl2,
    Nivel2.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl2,
    Nivel3.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl3,
    Nivel3.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl3,
    Nivel4.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl4,
    Nivel4.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl4,
    Nivel5.CODCONTA COLLATE Latin1_General_CI_AS as cdgContaNvl5,
    Nivel5.DESCRICAO COLLATE Latin1_General_CI_AS as descContaNvl5,
    Nivel6.ANALITICA,
    -- Lógica de Negócio para Categoria
    CASE 
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.1.1.1' THEN 'Contribuição para o Sebrae (CSO)'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.1.2.1' THEN 'Contribuição Social do Sebrae/NA  (CSN)'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.1.2.2' THEN 'CSN Proposta'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.2.1.3' THEN 'Aplicações Financeiras'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.2.1.2' THEN 'Empresas Beneficiadas'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.1.3.2' THEN 'Contrato Interno com Sebrae/NA'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.2.1.1' THEN 'Convênios, Subvenções e Auxílios'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.2.1.4' THEN 'Outras Receitas'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.3.1.1' THEN 'Alienação de Bens'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '6.9.1.1' THEN 'Saldo Financ. Exerc. Anterior'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.1.1' THEN 'Pessoal'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.1.2' THEN 'Encargos Sociais'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.1.3' THEN 'Benefícios Sociais'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.2.1' THEN 'Serviços Especializados'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.2.2' THEN 'Serviços Contratados'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.2.3' THEN 'Encargos Sociais s/Serviços de Terceiros'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.1' THEN 'Despesas com Viagens'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.2' THEN 'Aluguéis e Encargos'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.3' THEN 'Divulgação, Anúncios, Publicidade e Propaganda'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.4' THEN 'Serviços Gráficos e de Reprodução'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.5' THEN 'Serviços de Comunicação em Geral'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.6' THEN 'Materiais de Consumo'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.7' THEN 'Demais Custos e Despesas Gerais'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.3.8' THEN 'Doações e Subvenções'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.4.1' THEN 'Despesas Tributárias'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.4.2' THEN 'Despesas Financeiras'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '3.1.5.3' THEN 'Transf. Externas - Convênios c/Outras Entidades'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.2.1' THEN 'Bens Imóveis'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.2.2' THEN 'Bens Móveis'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.2.3' THEN 'Bens Intangíveis'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.5.2' THEN 'Fundo de Empresas Emergentes'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.5.3' THEN 'Microcrédito'
        WHEN LEFT(Nivel6.CODCONTA, 7) = '5.1.4.1' THEN 'Depósitos Judiciais'
        ELSE NULL 
    END AS CATEGORIA,
    -- Lógica de Negócio para Receita/Despesa
    CASE 
        WHEN LEFT(Nivel6.CODCONTA, 1) = '6' THEN 1
        WHEN LEFT(Nivel6.CODCONTA, 1) IN ('3', '5') THEN 2
        ELSE NULL 
    END AS RECEITA_DESPESA
INTO #PLANO_CONTAS
FROM HUBDADOS.CorporeRM.CCONTA AS Nivel6
LEFT JOIN HUBDADOS.CorporeRM.CCONTA AS Nivel5 ON LEFT(Nivel6.CODCONTA, 10) = Nivel5.CODCONTA COLLATE Latin1_General_CI_AS
LEFT JOIN HUBDADOS.CorporeRM.CCONTA AS Nivel4 ON LEFT(Nivel6.CODCONTA, 7) = Nivel4.CODCONTA COLLATE Latin1_General_CI_AS
LEFT JOIN HUBDADOS.CorporeRM.CCONTA AS Nivel3 ON LEFT(Nivel6.CODCONTA, 5) = Nivel3.CODCONTA COLLATE Latin1_General_CI_AS
LEFT JOIN HUBDADOS.CorporeRM.CCONTA AS Nivel2 ON LEFT(Nivel6.CODCONTA, 3) = Nivel2.CODCONTA COLLATE Latin1_General_CI_AS
LEFT JOIN HUBDADOS.CorporeRM.CCONTA AS Nivel1 ON LEFT(Nivel6.CODCONTA, 1) = Nivel1.CODCONTA COLLATE Latin1_General_CI_AS
-- Filtro para trazer apenas as contas analíticas (onde ocorrem os lançamentos)
WHERE
    Nivel6.ANALITICA = 1;

-- Cria a tabela #CCUSTO, que servirá como uma tabela de dimensão para os Centros de Custo.
-- A collation da coluna 'CC' é padronizada para garantir compatibilidade nos JOINs.
SELECT
    NivelAcao.CODCCUSTO COLLATE Latin1_General_CI_AS AS CC,
    NivelUnidade.CAMPOLIVRE AS ACAO,
    NivelProjeto.CAMPOLIVRE AS PROJETO,
    NivelAcao.CAMPOLIVRE AS UNIDADE
INTO #CCUSTO
FROM CorporeRM.GCCUSTO AS NivelAcao
LEFT JOIN CorporeRM.GCCUSTO AS NivelProjeto ON LEFT(NivelAcao.CODCCUSTO, 5) = NivelProjeto.CODCCUSTO
LEFT JOIN CorporeRM.GCCUSTO AS NivelUnidade ON LEFT(NivelAcao.CODCCUSTO, 12) = NivelUnidade.CODCCUSTO
WHERE 
    LEN(NivelAcao.CODCCUSTO) = 16 AND NivelAcao.ATIVO = 'T' AND NivelAcao.PERMITELANC = 'T';

-- Cria a tabela #ORCAMENTO, que consolida todos os lançamentos de débito e crédito.
-- Esta é a tabela de fatos principal da nossa análise.
SELECT
    RIGHT(crt.CODGERENCIAL, 16) COLLATE Latin1_General_CI_AS AS CC, 
    cln.DEBITO COLLATE Latin1_General_CI_AS AS CONTA,
    
    -- LINHA MODIFICADA (1/2) --
    CASE 
        WHEN pc.Natureza = 1 THEN (CASE WHEN crt.VLRDEBITO <> 0 AND crt.VLRCREDITO <> 0 THEN NULL WHEN crt.VLRDEBITO <> 0 THEN crt.VLRDEBITO WHEN crt.VLRCREDITO <> 0 THEN crt.VLRCREDITO ELSE 0 END) 
        ELSE -1 * (CASE WHEN crt.VLRDEBITO <> 0 AND crt.VLRCREDITO <> 0 THEN NULL WHEN crt.VLRDEBITO <> 0 THEN crt.VLRDEBITO WHEN crt.VLRCREDITO <> 0 THEN crt.VLRCREDITO ELSE 0 END) 
    END AS VALOR,
    
    crt.IDRATEIO, crt.LCTREF, crt.IDPARTIDA, tmv.IDMOV, tmv.CODTMV,tmv.CAMPOLIVRE1 as CONTRATO,FCFO.NOME AS FORNECEDOR,
    tmv.CODUSUARIO, tmv.DATAEMISSAO, cln.COMPLEMENTO, cln.[DATA], 'D' AS TipoLancamento
INTO #ORCAMENTO
FROM HUBDADOS.CorporeRM.CRATEIOLC crt
LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln ON crt.LCTREF = cln.LCTREF and crt.IDPARTIDA = cln.IDPARTIDA
-- Para evitar o erro "Conversion failed", convertemos o lado numérico (IDMOV) para texto (VARCHAR).
-- Isso garante que a comparação seja sempre entre texto e texto.
LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv ON cln.INTEGRACHAVE = CAST(tmv.IDMOV AS VARCHAR(255))
INNER JOIN CorporeRM.CCONTA pc ON pc.CODCONTA = cln.DEBITO
LEFT JOIN CorporeRM.FCFO FCFO ON tmv.CODCFO = FCFO.CODCFO
WHERE (cln.[DATA] >= @DATA_INICIO AND cln.[DATA] < @DATA_FIM) AND cln.CODHISTP <> 820

UNION ALL

SELECT
    RIGHT(crt.CODGERENCIAL, 16) COLLATE Latin1_General_CI_AS AS CC, 
    cln.CREDITO COLLATE Latin1_General_CI_AS AS CONTA,

    -- LINHA MODIFICADA (2/2) --
    CASE 
        WHEN pc.Natureza = 0 THEN (CASE WHEN crt.VLRDEBITO <> 0 AND crt.VLRCREDITO <> 0 THEN NULL WHEN crt.VLRDEBITO <> 0 THEN crt.VLRDEBITO WHEN crt.VLRCREDITO <> 0 THEN crt.VLRCREDITO ELSE 0 END) 
        ELSE -1 * (CASE WHEN crt.VLRDEBITO <> 0 AND crt.VLRCREDITO <> 0 THEN NULL WHEN crt.VLRDEBITO <> 0 THEN crt.VLRDEBITO WHEN crt.VLRCREDITO <> 0 THEN crt.VLRCREDITO ELSE 0 END) 
    END AS VALOR,
    
    crt.IDRATEIO, crt.LCTREF, crt.IDPARTIDA, tmv.IDMOV, tmv.CODTMV,tmv.CAMPOLIVRE1 as CONTRATO,FCFO.NOME AS FORNECEDOR,
    tmv.CODUSUARIO, tmv.DATAEMISSAO, cln.COMPLEMENTO, cln.[DATA], 'C' AS TipoLancamento
FROM HUBDADOS.CorporeRM.CRATEIOLC crt
LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln ON crt.LCTREF = cln.LCTREF and crt.IDPARTIDA = cln.IDPARTIDA
LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv ON cln.INTEGRACHAVE = CAST(tmv.IDMOV AS VARCHAR(255))
INNER JOIN CorporeRM.CCONTA pc ON pc.CODCONTA = cln.CREDITO
LEFT JOIN CorporeRM.FCFO FCFO ON tmv.CODCFO = FCFO.CODCFO
WHERE (cln.[DATA] >= @DATA_INICIO AND cln.[DATA] < @DATA_FIM) AND cln.CODHISTP <> 820;

-- 4. OTIMIZAÇÃO DE PERFORMANCE (INDEXAÇÃO)
--------------------------------------------------------------------------------
-- Após carregar os dados, criamos índices nas tabelas temporárias.
-- Isso acelera drasticamente as operações de JOIN e WHERE na consulta final.
CREATE CLUSTERED INDEX IX_ORCAMENTO_CONTA ON #ORCAMENTO (CONTA);
CREATE NONCLUSTERED INDEX IX_ORCAMENTO_CC ON #ORCAMENTO (CC);
CREATE CLUSTERED INDEX IX_CCUSTO_CC ON #CCUSTO (CC);

-- 5. CONSULTA FINAL
--------------------------------------------------------------------------------
-- Junta todas as tabelas preparadas para gerar o resultado final.
-- Como todos os problemas de collation e performance foram tratados nas etapas
-- anteriores, esta consulta final é limpa, legível e rápida.
SELECT
    orc.*,	
    cc.ACAO,
    cc.PROJETO,
    cc.UNIDADE,
	B.descContaNvl6 AS DESCNVL6,
	B.descContaNvl5 AS DESCNVL5,
	B.descContaNvl4 AS DESCNVL4,
	B.descContaNvl3 AS DESCNVL3,
	B.descContaNvl2 AS DESCNVL2,
	B.descContaNvl1 AS DESCNVL1,
	B.CATEGORIA
FROM #ORCAMENTO AS orc
-- Filtra os lançamentos para incluir apenas as contas de interesse, usando um JOIN rápido.
INNER JOIN @CONTAS AS f ON orc.CONTA = f.CONTA
-- Adiciona as informações do Centro de Custo, usando um LEFT JOIN para não perder lançamentos caso um CC não seja encontrado.
LEFT JOIN #CCUSTO AS cc ON orc.CC = cc.CC
LEFT JOIN #PLANO_CONTAS B ON B.cdgContaNvl6 = orc.CONTA 
-- Ordena o resultado final.
ORDER BY orc.CONTA DESC;


 
