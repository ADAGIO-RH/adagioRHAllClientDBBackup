USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc RH.spIUCatExample(
 @Value varchar(100)
) as
    insert into RH.TblCatExample(Value)
    select @Value
GO
