USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblSalariosMinimos](
	[IDSalarioMinimo] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[SalarioMinimo] [decimal](18, 2) NULL,
	[UMA] [decimal](18, 2) NULL,
	[FactorDescuento] [decimal](18, 2) NULL,
	[IDPais] [int] NULL,
 CONSTRAINT [Pk_NominaTblSalariosMinimos_IDSalarioMinimo] PRIMARY KEY CLUSTERED 
(
	[IDSalarioMinimo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblSalariosMinimos_Fecha] ON [Nomina].[tblSalariosMinimos]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblSalariosMinimos]  WITH NOCHECK ADD  CONSTRAINT [FK_SATTblCatPaises_NominaTblSalariosMinimos_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Nomina].[tblSalariosMinimos] CHECK CONSTRAINT [FK_SATTblCatPaises_NominaTblSalariosMinimos_IDPais]
GO
