USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Norma35.spBuscarArchivosAdjuntos
	-- Add the parameters for the stored procedure here
	@IDUsuario int,
    @IDDenuncia int
AS
BEGIN	
    select IDDenunciasArchivoAdjunto ,IDDenuncia ,Name, ContentType ,[Data] from Norma35.tblDenunciasArchivosAdjuntos where IDDenuncia=@IDDenuncia    	
END
GO
