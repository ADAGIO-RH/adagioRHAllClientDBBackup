USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Utilerias].[fnEliminarAcentos] ( @Cadena VARCHAR(100) )
    RETURNS VARCHAR(100)
AS 
BEGIN
 
    --Replace accent marks
    RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Cadena, 'á', 'A'), 'é','E'), 'í', 'I'), 'ó', 'O'), 'ú','U') ,'ñ','N')
END
GO
