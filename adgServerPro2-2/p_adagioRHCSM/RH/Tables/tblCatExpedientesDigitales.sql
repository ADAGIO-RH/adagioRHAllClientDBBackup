USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatExpedientesDigitales](
	[IDExpedienteDigital] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Requerido] [bit] NULL,
	[RequeridoTexto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCarpetaExpedienteDigital] [int] NULL,
 CONSTRAINT [PK_RHTblCatExpedientesDigitales_IDCatExpedienteDigital] PRIMARY KEY CLUSTERED 
(
	[IDExpedienteDigital] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHtblCatExpedientesDigitales_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] ADD  CONSTRAINT [d_RHtblCatExpedientesDigitales_Requerido]  DEFAULT ((0)) FOR [Requerido]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatCarpetasExpedienteDigital_RHtblCatExpedientesDigitales_IDCarpetaExpedienteDigital] FOREIGN KEY([IDCarpetaExpedienteDigital])
REFERENCES [RH].[tblCatCarpetasExpedienteDigital] ([IDCarpetaExpedienteDigital])
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] CHECK CONSTRAINT [FK_RHtblCatCarpetasExpedienteDigital_RHtblCatExpedientesDigitales_IDCarpetaExpedienteDigital]
GO
