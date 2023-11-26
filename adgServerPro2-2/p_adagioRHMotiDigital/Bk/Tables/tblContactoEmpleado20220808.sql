USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblContactoEmpleado20220808](
	[IDContactoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoContactoEmpleado] [int] NOT NULL,
	[Value] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Predeterminado] [bit] NULL
) ON [PRIMARY]
GO
