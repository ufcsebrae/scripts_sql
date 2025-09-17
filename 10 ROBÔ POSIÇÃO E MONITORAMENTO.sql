Declare @DATAHOJE date = GETDATE()
Print @DATAHOJE
 
DROP TABLE IF EXISTS [FINANCA].dbo.Monitoramento_backup -- EXCLUI BACKUP
CREATE TABLE [FINANCA].dbo.Monitoramento_backup (
 
 [Cod.Contrato] VARCHAR (max)
,[Processo] VARCHAR (max)
,[Objeto] VARCHAR (max)
,CNPJ VARCHAR (max)
,Fornecedor VARCHAR (max)
,Departamento VARCHAR (max)
,[Diretoria] VARCHAR(max)
,Modalidade VARCHAR(max)
,Gerente VARCHAR(max)
,Gestor VARCHAR(max)
,[Gestor UAPO] VARCHAR(max)
,[R$ Total Contrato] FLOAT
,[Data Inicio] DATE
,[Data Fim] DATE
,[Data Contrato] DATE
,[Dias Vencimento] NVARCHAR(max)
,[R$ Pago] FLOAT
,[R$ Comprometido] FLOAT
,[R$ Realizado] FLOAT
,[Saldo do Contrato] FLOAT
,[Posição] NVARCHAR(max)
,[Categoria Vencimento] NVARCHAR(max)
,[Monitoramento] BIT 
);  
 
INSERT INTO [FINANCA].dbo.Monitoramento_backup
SELECT * FROM [FINANCA].dbo.Monitoramento -- BACKUP NOVO
 
DROP TABLE IF EXISTS [FINANCA].dbo.Monitoramento
 
 
CREATE TABLE [FINANCA].dbo.Monitoramento  (
 
[Cod.Contrato] VARCHAR (max),
[Processo] VARCHAR (max),
[Objeto] VARCHAR (max),
[CNPJ] VARCHAR (max),
[Fornecedor] VARCHAR (max),
[Departamento] VARCHAR (max),
[Diretoria] VARCHAR(max),
[Modalidade] VARCHAR(max),
[Gerente] VARCHAR(max),
[Gestor] VARCHAR(max),
[Gestor UAPO] VARCHAR(max),
[R$ Total Contrato] FLOAT,
[Data Inicio] DATE,
[Data Fim] DATE,
[Data Contrato] DATE,
[Dias Vencimento] NVARCHAR(max),
[R$ Pago] FLOAT,
[R$ Comprometido] FLOAT,
[R$ Realizado] FLOAT,
[Saldo do Contrato] FLOAT,
[Posição] NVARCHAR(max),
[Categoria Vencimento] NVARCHAR(max),
[Monitoramento] BIT
);  
 
INSERT INTO [FINANCA].dbo.Monitoramento 
  Select
 a.[Cod.Contrato],
 a.Processo,
 a.Objeto,
 a.CNPJ,
 Fornecedor,
 Departamento,
Diretoria,
 Modalidade,
 Gerente,
 Gestor,
[Gestor UAPO],
[R$ Total Contrato] AS 'R$ Total Contrato',
[Data Inicio] AS 'Data Inicio',
[Data Fim] AS 'Data Fim',
[Data Contrato] AS 'Data Contrato',
DATEDIFF(DAY, @datahoje, [Data Fim]) AS 'Dias Vencimento',
 sum(ZUTICONTRATOSANALITICO.VALORPAGO) AS 'R$ Pago',
 sum(ZUTICONTRATOSANALITICO.VALORCOMPROMETIDO) AS 'R$ Comprometido',
 sum(ZUTICONTRATOSANALITICO.VALORREALIZADO) AS 'R$ Realizado',
 
  [R$ Total Contrato] - SUM(ISNULL(ZUTICONTRATOSANALITICO.VALORPAGO,0) + ISNULL(ZUTICONTRATOSANALITICO.VALORREALIZADO,0) + ISNULL(ZUTICONTRATOSANALITICO.VALORCOMPROMETIDO,0)) as 'Saldo do Contrato',
 
  apenasPosicao.Posição AS 'Posição',
  CASE WHEN DATEDIFF(DAY, @datahoje, [Data Fim]) <= 0 THEN 'Vencido'
    WHEN DATEDIFF(DAY, @datahoje, [Data Fim]) > 0 AND DATEDIFF(DAY, @datahoje, [Data Fim]) <= 30 THEN 'Até 30 dias para o vencimento'
    WHEN DATEDIFF(DAY, @datahoje, [Data Fim]) >= 31 AND DATEDIFF(DAY, @datahoje, [Data Fim]) <= 60 THEN 'De 31 até 60 dias para o vencimento'
    WHEN DATEDIFF(DAY, @datahoje, [Data Fim]) >= 61 AND DATEDIFF(DAY, @datahoje, [Data Fim]) <= 90 THEN 'De 61 até 90 dias para o vencimento'
    WHEN DATEDIFF(DAY, @datahoje, [Data Fim]) >= 91 AND DATEDIFF(DAY, @datahoje, [Data Fim]) <= 120 THEN 'De 91 até 120 dias para o vencimento'
 
  ELSE 'Acima de 121 dias' END AS 'Categoria Vencimento',
 
  CASE WHEN [modalidade] IN ('LICITAÇÃO PREGÃO ELETRÔNICO',
'INEXIGIBILIDADE - EXCLUSIVIDADE',
'INEXIGIBILIDADE - CAPUT',
'DISPENSA POR VALOR - OBRAS E ENGENHARIA',
'LICITAÇÃO CONCORRÊNCIA',
'CONVÊNIO DE COOPERAÇÃO TÉCNICA',
'CONVÊNIO DE COOPERAÇÃO TÉCNICA E FINANCEIRA',
'ADESÃO À ATA DE REGISTRO DE PREÇOS (LICITAÇÃO)',
--'EDITAL DE CREDENCIAMENTO',
--'LICITA��O PREG�O PRESENCIAL',
'FUNDO DE INVESTIMENTO',
'LICITAÇÃO CONVITE',
'DISPENSA - NAO INTERESSADOS NA LICITAÇÃO',
'DISPENSA� - URGENCIA / IMPREVISTO / SEM TE',
'DISPENSA  - CONTRAT SERV SOC AUTON OU ORGÃ',--alteracao 3105
'DISPENSA  - ENTIDADE PESQ, ENSINO, S/FIN',
'DISPENSA  - LOCAÇÃO, AQUIS. OU ARREND. DE',
'INEXIGIBILIDADE  - NOTÓRIA',--alteracao 0307
'TERMO DE ADESÃO',
'TERMO DE COMPROMISSO',
--'EDITAL DE CREDENCIAMENTO', -- alteracao 0704 --andrea pediu 
'LICITAÇÃO ATA REGISTRO DE PREÇOS',
'TERMO DE COOPERAÇÃO TÉCNICA' ,
'DISPENSA - CONTR SERV CONSULT DEST PUB ALV SEBR'
)
 THEN 1 ELSE 0 END AS 'Monitoramento'
   FROM (SELECT DISTINCT
 TCNT.CODIGOCONTRATO AS 'Cod.Contrato',
 PAINEL.PROCESSO AS 'Processo',
 PAINEL.OBJETO AS 'Objeto',
 PAINEL.CNPJ AS 'CNPJ',
 TRIM(PAINEL.FORNECEDOR) AS 'Fornecedor',
 PAINEL.DEPARTAMENTO AS 'Departamento',
 PAINEL.MODALIDADE AS 'Modalidade',
 TVEN.NOME AS 'Gerente',
 TVEN2.NOME AS 'Gestor',
  TCNTCOMPL.GESTOR_SUP AS 'Gestor UAPO',
    TCNT.VALORCONTRATO AS 'R$ Total Contrato',
 tcnt.DATAINICIO AS 'Data Inicio',
 tcnt.DATAFIM AS 'Data Fim',
  tcnt.DATACONTRATO AS 'Data Contrato',
 TCNT.CODSTACNT AS 'Status',
 TSTACNT.DESCRICAO, 
  CASE
    WHEN DEPARTAMENTO IN ('UNIDADE SUPRIMENTOS',
                'UNIDADE ADMINISTRAÇÃO, PROJETOS E OBRAS',
                'UNIDADE FINANÇAS E CONTROLADORIA',
                'UNIDADE GESTÃO DE PESSOAS',
                'UNIDADE INFRAESTRUTURA DA INFORMAÇÃO',
                'DIRETORIA DE ADMINISTRAÇÃO E FINANÇAS',
                'UNIDADE ADMINISTRAÇÃO',
                'UNIDADE DE PROJETOS OBRAS',
                'SEDE')
    THEN 'DAF'
    WHEN DEPARTAMENTO IN ('UNIDADE POLITICAS PUBLICAS E RELACOES INSTITUCIONAIS',
                'UNIDADE MARKETING E COMUNICAÇÃO',
                'UNIDADE JURÍDICA E SECRETARIA GERAL',
                'UNIDADE GESTÃO ESTRATÉGICA',
                'PRESIDENCIA',
                'OUVIDORIA',
                'UNIDADE DE INOVAÇÃO',
                'SUPERITENDENCIA',
                'CENTRO DE REFERÊNCIA EM INOVAÇÃO TECNOLÓGICA',
                'AUDITORIA')
    THEN 'SUPER'
    WHEN DEPARTAMENTO IN ('UNIDADE GESTAO DE SOLUCOES E TRANSFORMACAO DIGITAL',
                'UNIDADE DESENVOLVIMENTO SETORIAL E TERRITORIAL',
                'UNIDADE ATENDIMENTO AO CLIENTE',
                'UNIDADE RELACIONAMENTO COM CLIENTE',
                'DIRETORIA TECNICA',
                'UNIDADE CULTURA EMPREENDEDORA',
                'ER ARARAQUARA',
                'ER VOTUPORANGA',
                'ER SOROCABA',
                'ER OURINHOS',
                'ER SAO JOSE DO RIO PRETO',
                'ER ARACATUBA',
                'ER FRANCA',
                'ER ALTO TIETÊ',
                'ER VALE DO RIBEIRA',
                'ER GRANDE ABC',
                'ER BARRETOS',
                'ER MARILIA',
                'ER PRESIDENTE PRUDENTE',
                'ER BAIXADA SANTISTA',
                'ER RIBEIRAO PRETO',
                'ER SAO JOSE DOS CAMPOS',
                'ER CAMPINAS',
                'ER CAPITAL - NORTE',
                'ER GUARULHOS',
                'ER JUNDIAI',
                'ER SUDOESTE PAULISTA',
                'ER SAO JOAO DA BOA VISTA',
                'ER SAO CARLOS',
                'ER PIRACICABA',
                'ER OSASCO',
                'ER GUARATINGUETA',
                'ER CAPITAL LESTE II',
                'ER CAPITAL CENTRO',
                'ER CAPITAL - SUL',
                'ER CAPITAL - OESTE',
                'ER BOTUCATU',
                'ER CAPITAL - LESTE',
                'ER BAURU',
                'UNIDADE GESTÃO DE PRODUTOS',
                'ACESSO A MERCADO E SERVIÇOS FINANCEIROS',
                'UAMSF')
    THEN 'DITEC'
        ELSE '' END AS 'Diretoria'
 
FROM [HubDados].[CorporeRM].[TCNT] TCNT 
  INNER JOIN [HubDados].[CorporeRM].[TSTACNT] TSTACNT
ON TCNT.CODSTACNT COLLATE LATIN1_GENERAL_CS_AI = TSTACNT.CODSTACNT
  INNER JOIN [HubDados].[PainelContrato].[Detalhe] PAINEL
 ON TCNT.CODIGOCONTRATO COLLATE LATIN1_GENERAL_CS_AI = Painel.NRO_CONTRATO
  INNER JOIN [HubDados].[CorporeRM].[TVEN] TVEN
 ON TVEN.CODVEN COLLATE LATIN1_GENERAL_CS_AI = TCNT.CODVEN  
  INNER JOIN [HubDados].[CorporeRM].[TVEN] TVEN2
 ON TVEN2.CODVEN COLLATE LATIN1_GENERAL_CS_AI = TCNT.CODVEN2
  INNER JOIN [HubDados].[CorporeRM].[TCNTCOMPL] TCNTCOMPL
  ON TCNTCOMPL.IDCNT = TCNT.IDCNT 
) a 
  INNER JOIN [HubDados].[CorporeRM].[ZUTICONTRATOSANALITICO] ZUTICONTRATOSANALITICO --- trocar pelo INNER
 ON a.[Cod.Contrato] COLLATE LATIN1_GENERAL_CS_AI = ZUTICONTRATOSANALITICO.CODIGOCONTRATO
  LEFT JOIN [FINANCA].[dbo].[Posicao] apenasPosicao
 ON apenasPosicao.[Cod.Contrato] COLLATE LATIN1_GENERAL_CS_AI = a.[Cod.Contrato]
 
 
  WHERE a.[Status] LIKE '00001' AND
 a.Modalidade IN
 ('ACORDO DE COEXISTÊNCIA DE MARCAS',
 'ADESÃO À ATA DE REGISTRO DE PREÇOS (LICITAÇÃO)',
 'CESSÃO DE USO',
 'COMODATO',
 'CONTRATO DE LICENÇA',
 'CONVÊNIO DE COOPERAÇÃO TÉCNICA',
 'CONVÊNIO DE COOPERAÇÃO TÉCNICA E FINANCEIRA',
  'DISPENSA  - CONTRAT SERV SOC AUTON OU ORGÃ',
  'DISPENSA - CONTR SERV CONSULT DEST PUB ALV SEBR',
    'DISPENSA  - EMERGENCIA/PREJUÍZO/SEGURANÇA',
    'DISPENSA  - ENTIDADE PESQ, ENSINO, S/FIN',
    'DISPENSA  - INSTRUTORIA VINCULADA ATIV FI',
    'DISPENSA  - LOCAÇÃO, AQUIS. OU ARREND. DE',
    'DISPENSA  - MANUTENÇÃO COMO CONDIC GARAN',
 'DISPENSA POR VALOR - BENS E SERVIÇOS',
 'DISPENSA POR VALOR - OBRAS E ENGENHARIA',
 'EDITAL DE CREDENCIAMENTO',
 'EDITAL DE CREDENCIAMENTO - CONSULTORIA E INSTRUTORIA',
 'EDITAL DE CREDENCIAMENTO - EMPRETEC',
 'FUNDO DE INVESTIMENTO',
 'INEXIGIBILIDADE  - NOTÓRIA',
 'INEXIGIBILIDADE - CAPUT',
 'INEXIGIBILIDADE - EXCLUSIVIDADE',
  'LICITAÇÃO ATA REGISTRO DE PREÇOS',
 'LICENÇA DE USO',
 'LICITAÇÃO CONCORRÊNCIA',
 'LICITAÇÃO CONVITE',
 'LICITAÇÃO PREGÃO ELETRÔNICO',
 'LICITAÇÃO PREGÃO PRESENCIAL',
 'PROTOCOLO DE INTENÇÃO',
 'TERMO DE ADESÃO',
 'TERMO DE COMPROMISSO',
 'TERMO DE COOPERAÇÃO TÉCNICA',
  'DISPENSA - NAO INTERESSADOS NA LICITAÇÃO',
  'DISPENSA - URGENCIA / IMPREVISTO / SEM TE') 
  AND DATEDIFF(DAY, @datahoje, [Data Fim]) >= 0 
  AND A.Fornecedor NOT LIKE 'EDUCALIBRAS TREINAMENTO E DESENVOLVIMENTO DO IDIOMA DE LIBRAS LTDA - EPP' 
GROUP BY
a.[Cod.Contrato],
a.Processo,
a.Objeto,
a.CNPJ,
Fornecedor,
Departamento,
Modalidade,
Gerente,
Gestor,
[Gestor UAPO],
[R$ Total Contrato],
[Data Inicio],
[Data Fim],
a.[data Contrato],
a.[Status],
DESCRICAO,
Posição,
Diretoria 
ORDER BY a.[Cod.Contrato] ASC