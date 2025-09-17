WITH SERV AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(cln.CREDITO LIKE '3.1.2%', cln.CREDITO, cln.DEBITO) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(cln.DATA) = YEAR(GETDATE())
        AND (cln.DEBITO NOT LIKE '2.4.1.1.01%' OR cln.DEBITO IS NULL)
        AND (cln.CREDITO LIKE '3.1.2%' OR cln.DEBITO LIKE '3.1.2%')
        AND cln.COMPLEMENTO IS NOT NULL
),

PESSOAL AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(cln.CREDITO LIKE '3.1.1%', cln.CREDITO, cln.DEBITO) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(cln.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND (Debito LIKE '3.1.1%' OR Credito LIKE '3.1.1%')
        AND COMPLEMENTO IS NOT NULL
        AND COMPLEMENTO NOT LIKE 'Custo Serviço e financeiro referente ao ano de 2018'
),

CRED AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(cln.DEBITO LIKE '5.1.1.2%', cln.debito, cln.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(cln.DATA) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND COMPLEMENTO IS NOT NULL
        AND Debito LIKE '5.2.5.3%'
),

LIBERCONV AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(cln.DEBITO LIKE '5.1.1.2%' OR cln.DEBITO LIKE '1.9.5.7.01.001', cln.debito, cln.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(cln.DATA) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND COMPLEMENTO IS NOT NULL
        AND (
            CODGERENCIAL NOT LIKE '9.99999.999999.999'
            AND Debito LIKE '5.1.1.2%' OR CREDITO LIKE '5.1.1.2%'
        )
),

IMOB AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF((cln.DEBITO LIKE '5.2.2.2%' OR cln.DEBITO LIKE '5.2.3.1%' OR cln.DEBITO LIKE '1.9.5.2.03%' OR cln.DEBITO LIKE '1.9.5.2.04%' OR cln.DEBITO LIKE '1.9.5.2.03.004'), cln.debito, cln.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(cln.DATA) = YEAR(GETDATE())
        AND ((DEBITO NOT LIKE '7.2.3.1.01%' AND DEBITO NOT LIKE '7.2.2.2.01%') OR DEBITO IS NULL)
        AND COMPLEMENTO IS NOT NULL
        AND (Debito LIKE '5.2.2.2%' OR Credito LIKE '5.2.2.2%' OR Debito LIKE '5.2.3.1%' OR Credito LIKE '5.2.3.1%')
),

INVEST AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(Debito LIKE '5.2.2.1%' OR Debito LIKE '1.9.5.2.02%', CLN.debito, CLN.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTida = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(CLN.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND COMPLEMENTO IS NOT NULL
        AND (Debito LIKE '5.2.2.1%' OR Credito LIKE '5.2.2.1%')
        AND IDRATEIO NOT LIKE '1929077'
),

FUNDO AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(CLN.DEBITO LIKE '5.2.5.2.01.001' OR CLN.Debito LIKE '1.9.5.1.01.003', CLN.debito, CLN.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        (YEAR(CLN.[DATA]) = YEAR(GETDATE())
            AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
            AND COMPLEMENTO IS NOT NULL
            AND DEBITO LIKE '5.2.5.2.01.001'
        )
        OR (YEAR(CLN.[DATA]) = YEAR(GETDATE())
            AND CREDITO IN ('5.2.5.2.01.001')
        )
),

ENCARGO AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(Credito LIKE '3.1.4%', CLN.credito, CLN.debito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(CLN.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND (Debito LIKE '3.1.4.1%' OR Credito LIKE '3.1.4.1%' OR Debito LIKE '3.1.4.2%' OR Credito LIKE '3.1.4.2%')
        AND COMPLEMENTO IS NOT NULL
        AND IDRATEIO NOT IN ('1537384', '1911286')
),

DEPOSITO AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(cln.DEBITO LIKE '5.2.4.1.01%' OR cln.Debito LIKE '1.9.5.1.01.001', cln.debito, cln.credito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(CLN.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND (Debito LIKE '5.2.4.1.01%' OR CREDITO LIKE '5.2.4.1.01%')
),

CUSTO AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(Credito LIKE '3.1.3%', cln.credito, cln.debito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(CLN.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND (Debito LIKE '3.1.3%' OR Credito LIKE '3.1.3%')
        AND COMPLEMENTO IS NOT NULL
        AND IDRATEIO NOT LIKE '1537388'
),

--RECEITAS

EB AS (
    SELECT DISTINCT
        crt.IDRATEIO,
        crt.LCTREF,
        tmc.IDOPERACAO,
        crt.IDPARTIDA,
        tct.IDMOV,
        tmv.CODTMV,
        tmv.CODUSUARIO,
        tmv.DATAEMISSAO,
        cln.CREDITO,
        cln.DEBITO,
        IIF(Credito LIKE '4.1.2%', cln.credito, cln.debito) AS COD_CONTA,
        crt.CODGERENCIAL,
        cln.COMPLEMENTO,
        cln.DATA,
        crt.VLRCREDITO,
        crt.VLRDEBITO,
        crt.VLRDEBITO - crt.VLRCREDITO AS UNIFICAVALOR
    FROM HUBDADOS.CorporeRM.CRATEIOLC crt
    LEFT JOIN HUBDADOS.CorporeRM.CLANCA cln       ON crt.LCTREF = cln.LCTREF
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCONT tmc     ON cln.IDPARTIDA = tmc.IDPARTIDA
    LEFT JOIN HUBDADOS.CorporeRM.TMOVCTB tct      ON tmc.IDOPERACAO = tct.IDOPERACAO
    LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv         ON tct.IDMOV = tmv.IDMOV
    WHERE
        YEAR(CLN.[DATA]) = YEAR(GETDATE())
        AND (DEBITO NOT LIKE '2.4.1.1.01%' OR DEBITO IS NULL)
        AND (Debito LIKE '4.1.2%' OR Credito LIKE '4.1.2%')
        AND COMPLEMENTO IS NOT NULL

),



CC AS (
    SELECT
        A.CODCCUSTO,
        B.CAMPOLIVRE AS UNIDADE,
        C.CAMPOLIVRE AS PROJETO,
        D.CAMPOLIVRE AS ACAO
    FROM HUBDADOS.CorporeRM.GCCUSTO A
    INNER JOIN HUBDADOS.CorporeRM.GCCUSTO B   ON A.CODCCUSTO = B.CODCCUSTO
    INNER JOIN HUBDADOS.CorporeRM.GCCUSTO C   ON LEFT(A.CODCCUSTO, 5) = C.CODCCUSTO
    INNER JOIN HUBDADOS.CorporeRM.GCCUSTO D   ON LEFT(A.CODCCUSTO, 12) = D.CODCCUSTO
    WHERE
        LEN(A.CODCCUSTO) > 15
),

DESPESAS AS (
    SELECT * FROM SERV
    UNION ALL
    SELECT * FROM PESSOAL
    UNION ALL
    SELECT * FROM CRED
    UNION ALL
    SELECT * FROM LIBERCONV
    UNION ALL
    SELECT * FROM IMOB
    UNION ALL
    SELECT * FROM INVEST
    UNION ALL
    SELECT * FROM FUNDO
    UNION ALL
    SELECT * FROM ENCARGO
    UNION ALL
    SELECT * FROM DEPOSITO
    UNION ALL
    SELECT * FROM CUSTO
),

RECEITAS AS (
SELECT * FROM EB

)
,

TOTAL AS (SELECT * FROM DESPESAS UNION ALL SELECT * FROM RECEITAS)

SELECT * FROM CC


/*
SELECT
	bd.IDMOV,
	bd.IDRATEIO,
	bd.IDPARTIDA,
	bd.IDOPERACAO,
    bd.UNIFICAVALOR as UNIFICAVALOR,
    REPLACE(CC.UNIDADE, CHAR(22), '') AS CLASSIFICA,
    RIGHT(bd.CODGERENCIAL, 16) AS CODGERENCIAL,
    REPLACE(bd.COMPLEMENTO, CHAR(22), '') AS COMPLEMENTO,
    REPLACE(FCFO.NOME, CHAR(22), '') AS FORNECEDOR,
    REPLACE(CC.PROJETO, CHAR(22), '') AS PROJETO,
    REPLACE(CC.ACAO, CHAR(22), '') AS ACAO,
    bd.DATA,
    REPLACE(CCTA.DESCRICAO, CHAR(22), '') AS DESCNVL6,
    bd.COD_CONTA COLLATE Latin1_General_CI_AS AS COD_CONTA,
    FCFO.CODCFO AS CODCFO
FROM TOTAL AS bd
LEFT JOIN HUBDADOS.CorporeRM.TMOV tmv            ON bd.IDMOV = tmv.IDMOV
LEFT JOIN CC CC                                  ON CC.CODCCUSTO = RIGHT(bd.CODGERENCIAL, 16)
LEFT JOIN HUBDADOS.CorporeRM.CCONTA CCTA         ON CCTA.CODCONTA COLLATE Latin1_General_CI_AS = bd.COD_CONTA
LEFT JOIN HUBDADOS.CORPORERM.FCFO FCFO           ON FCFO.CODCFO = tmv.CODCFO
LEFT JOIN HUBDADOS.CORPORERM.TTMV TTMV           ON TTMV.CODTMV = tmv.CODTMV



ORDER BY DATA DESC;
*/