USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatRutas](
	[IDRuta] [int] IDENTITY(1,1) NOT NULL,
	[ClaveRuta] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Origen] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Destino] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[KMRuta] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TransportetblCatRutas_IDRuta] PRIMARY KEY CLUSTERED 
(
	[IDRuta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatRutas] ADD  DEFAULT ((1)) FOR [Status]
GO
