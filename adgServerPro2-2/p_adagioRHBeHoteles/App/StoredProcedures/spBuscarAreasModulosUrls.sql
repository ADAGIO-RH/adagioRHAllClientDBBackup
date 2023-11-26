USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [App].[spBuscarAreasModulosUrls] 
as

    select IDArea, Descripcion
    from App.tblCatAreas

    select *
    from App.tblCatModulos 

    select *
    from App.tblCatUrls
    where Tipo = 'V'
GO
