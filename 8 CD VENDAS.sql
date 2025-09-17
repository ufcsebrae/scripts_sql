DECLARE @lista TABLE (Id INT)
INSERT INTO @lista VALUES
('3617375'),
('3617801'),
('3617723'),
('3617547'),
('3617410'),
('3617083'),
('3616621'),
('3617714'),
('3617168'),
('3616270'),
('3610709'),
('3606832')
;
WITH agendamento AS (
SELECT * FROM  [HubDados].[RAE].[Pagamento_SolicitacaoVenda_Agendamento]
WHERE CdVenda IN (SELECT id FROM @lista)
)
,inscricao AS (
SELECT * FROM  [HubDados].[RAE].[Pagamento_SolicitacaoVenda_Inscricao]
WHERE CdVenda IN (SELECT id FROM @lista)
)
,total AS ( SELECT * FROM AGENDAMENTO UNION SELECT * FROM inscricao)
SELECT ROW_NUMBER() OVER(PARTITION BY a.cdvenda order by a.cdvenda) AS contagem
,a.CdVenda,b.Descricao_Plano,B.Descricao_Acao,B.CentroCusto,B.Produto,b.idAtendimentoColetivo
,A.ValorBruto,a.ValorDesconto,a.ValorLiquido,a.DataCriacao,a.DataAtualizacao FROM total A
LEFT JOIN [UAC].[dbo].[Atendimentos2024_RAE_Completa] B
ON A.IdAtendimentoAgendamento = B.idAtendimento
ORDER BY CdVenda DESC