USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblSMS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SMSId] [int] NULL,
	[Type] [int] NULL,
	[ValidTime] [int] NULL,
	[BeginTime] [datetime] NULL,
	[UserID] [char](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Content] [char](320) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [SMS_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
