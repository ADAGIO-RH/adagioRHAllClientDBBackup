USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spBuscarCatExample
as

    select DISTINCT Value
    from rh.TblCatExample
GO
