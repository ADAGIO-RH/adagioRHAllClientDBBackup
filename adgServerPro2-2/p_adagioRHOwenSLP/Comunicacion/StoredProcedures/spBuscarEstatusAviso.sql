USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comunicacion].[spBuscarEstatusAviso] (	
    @IDUsuario int 
) as

    DECLARE @IDIdioma varchar(225)
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

    select 
        [IDEstatus],
        JSON_VALUE(t.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) [Descripcion],
        Variant 
     From  [Comunicacion].[tblCatEstatusAviso] t
GO
