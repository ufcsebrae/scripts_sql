-- Define o banco de dados a ser utilizado para a sessão atual.
USE HubDados;
GO -- Separa os lotes de comandos. Boa prática em scripts mais longos.

-- 1. PREPARAÇÃO DO AMBIENTE
--------------------------------------------------------------------------------
-- Garante que as tabelas temporárias de execuções anteriores sejam removidas
-- para evitar erros de "objeto já existente".
DROP TABLE IF EXISTS #CCUSTO, #ORCAMENTO;

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
DECLARE @ANO INT = YEAR(GETDATE());
-- Cria as datas de início e fim do ano para um filtro de data performático.
-- Esta abordagem (>= e <) é "SARGable", permitindo que o SQL Server use índices na coluna de data.
DECLARE @DATA_INICIO DATE = DATEFROMPARTS(@ANO, 1, 1);
DECLARE @DATA_FIM DATE = DATEFROMPARTS(@ANO + 1, 1, 1);

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
('3.1.3.6.01.999'), ('3.1.3.7.01.001'), ('3.1.3.7.01.004'), ('3.1.3.7.01.005'), ('3.1.3.7.01.006'),
('3.1.3.7.01.007'), ('3.1.3.7.01.008'), ('3.1.3.7.01.009'), ('3.1.3.7.01.010'), ('3.1.3.7.01.011'),
('3.1.3.7.01.015'), ('3.1.3.7.01.021'), ('3.1.3.7.01.023'), ('3.1.3.7.01.999'), ('3.1.3.8.01.001'),
('3.1.4.1.01.002'), ('3.1.4.1.01.003'), ('3.1.4.1.02.001'), ('3.1.4.2.01.001'), ('3.1.4.2.01.002'),
('3.1.4.2.01.004'), ('3.1.4.2.01.005'), ('3.1.4.2.01.006'), ('3.1.4.2.01.007'), ('3.1.4.2.01.999'),
('5.1.1.2.01.001'), ('5.2.2.2.01.001'), ('5.2.2.2.01.003'), ('5.2.2.2.01.004'), ('5.2.2.2.01.006'),
('5.2.4.1.01.001'), ('5.2.5.2.01.001');

-- 3. CRIAÇÃO DAS TABELAS DE DADOS TEMPORÁRIAS
--------------------------------------------------------------------------------

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
    CASE WHEN pc.Natureza = 1 THEN cln.VALOR ELSE -1 * cln.VALOR END AS VALOR,
    crt.IDRATEIO, crt.LCTREF, crt.IDPARTIDA, tmv.IDMOV, tmv.CODTMV,tmv.CAMPOLIVRE1 as CONTRATO,
    tmv.CODUSUARIO, tmv.DATAEMISSAO, cln.COMPLEMENTO, cln.[DATA], 'D' AS TipoLancamento
INTO #ORCAMENTO
FROM HUBDADOS.CorporeRM.CRATEIOLC crt
INNER JOIN HUBDADOS.CorporeRM.CLANCA cln ON crt.LCTREF = cln.LCTREF
-- Para evitar o erro "Conversion failed", convertemos o lado numérico (IDMOV) para texto (VARCHAR).
-- Isso garante que a comparação seja sempre entre texto e texto.
INNER JOIN HUBDADOS.CorporeRM.TMOV tmv ON cln.INTEGRACHAVE = CAST(tmv.IDMOV AS VARCHAR(255))
INNER JOIN CorporeRM.CCONTA pc ON pc.CODCONTA = cln.DEBITO
WHERE cln.[DATA] >= @DATA_INICIO AND cln.[DATA] < @DATA_FIM 
UNION ALL
SELECT
    RIGHT(crt.CODGERENCIAL, 16) COLLATE Latin1_General_CI_AS AS CC, 
    cln.CREDITO COLLATE Latin1_General_CI_AS AS CONTA,
    CASE WHEN pc.Natureza = 0 THEN cln.VALOR ELSE -1 * cln.VALOR END AS VALOR,
    crt.IDRATEIO, crt.LCTREF, crt.IDPARTIDA, tmv.IDMOV, tmv.CODTMV,tmv.CAMPOLIVRE1 as CONTRATO,
    tmv.CODUSUARIO, tmv.DATAEMISSAO, cln.COMPLEMENTO, cln.[DATA], 'C' AS TipoLancamento
FROM HUBDADOS.CorporeRM.CRATEIOLC crt
INNER JOIN HUBDADOS.CorporeRM.CLANCA cln ON crt.LCTREF = cln.LCTREF
INNER JOIN HUBDADOS.CorporeRM.TMOV tmv ON cln.INTEGRACHAVE = CAST(tmv.IDMOV AS VARCHAR(255))

INNER JOIN CorporeRM.CCONTA pc ON pc.CODCONTA = cln.CREDITO
WHERE cln.[DATA] >= @DATA_INICIO AND cln.[DATA] < @DATA_FIM;

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
    cc.UNIDADE
FROM #ORCAMENTO AS orc
-- Filtra os lançamentos para incluir apenas as contas de interesse, usando um JOIN rápido.
INNER JOIN @CONTAS AS f ON orc.CONTA = f.CONTA
-- Adiciona as informações do Centro de Custo, usando um LEFT JOIN para não perder lançamentos caso um CC não seja encontrado.
LEFT JOIN #CCUSTO AS cc ON orc.CC = cc.CC
-- Ordena o resultado final.
ORDER BY orc.CONTA DESC;
GO
