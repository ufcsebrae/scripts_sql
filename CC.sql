with CC AS (
   SELECT
        NivelAcao.CODCCUSTO,
        NivelUnidade.CAMPOLIVRE AS ACAO,
        NivelProjeto.CAMPOLIVRE AS PROJETO,
        NivelAcao.CAMPOLIVRE AS UNIDADE
    FROM HUBDADOS.CorporeRM.GCCUSTO AS NivelAcao
    -- Corrigindo a lógica para buscar os níveis hierárquicos corretos
    LEFT JOIN HUBDADOS.CorporeRM.GCCUSTO AS NivelProjeto ON LEFT(NivelAcao.CODCCUSTO, 5) = NivelProjeto.CODCCUSTO
    LEFT JOIN HUBDADOS.CorporeRM.GCCUSTO AS NivelUnidade ON LEFT(NivelAcao.CODCCUSTO, 12) = NivelUnidade.CODCCUSTO
    WHERE 
     LEN(NivelAcao.CODCCUSTO) > 15 AND NivelAcao.ATIVO = 'T' AND NivelAcao.PERMITELANC = 'T'
	 )

SELECT * FROM CC