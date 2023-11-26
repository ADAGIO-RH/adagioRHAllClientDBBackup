USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblTmpFvein](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fid] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Index] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
	[Valid] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Tmp] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Ver] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Duress] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [TmpFvein_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblTmpFvein] ADD  DEFAULT ('0') FOR [Fid]
GO
ALTER TABLE [zkteco].[tblTmpFvein] ADD  DEFAULT ('0') FOR [Index]
GO
ALTER TABLE [zkteco].[tblTmpFvein] ADD  DEFAULT ((0)) FOR [Size]
GO
ALTER TABLE [zkteco].[tblTmpFvein] ADD  DEFAULT ('1') FOR [Valid]
GO
ALTER TABLE [zkteco].[tblTmpFvein] ADD  DEFAULT ('0') FOR [Duress]
GO
