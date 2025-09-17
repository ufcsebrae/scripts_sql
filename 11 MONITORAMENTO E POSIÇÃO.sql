USE FINANCA
;

UPDATE dbo.MONITORAMENTO
SET Posição = '"Aditamento - Termo Aditivo assinado por mais 12 meses"'
WHERE [Cod.Contrato] = 'SPA1.000987.21'
;

UPDATE dbo.Posicao
SET Posição = '"Aditamento - Termo Aditivo assinado por mais 12 meses"'
WHERE [Cod.Contrato] = 'SPA1.000987.21'


/*INSERT INTO Posicao
VALUES ('SPA1.000987.21', '', '"Aditamento - Termo Aditivo assinado por mais 12 meses"')*/