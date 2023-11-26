USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scheduler].[tblMessageLog](
	[IDMessageLog] [int] IDENTITY(1,1) NOT NULL,
	[IDSchedule] [int] NOT NULL,
	[dest] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[msg] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[send] [int] NOT NULL,
	[date] [datetime] NOT NULL,
 CONSTRAINT [PK_SchedulerTblMessageLog_IDMessageLog] PRIMARY KEY CLUSTERED 
(
	[IDMessageLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scheduler].[tblMessageLog]  WITH NOCHECK ADD  CONSTRAINT [FK_SchedulerTblSchedule_SchedulerTblMessageLog_IDSchedule] FOREIGN KEY([IDSchedule])
REFERENCES [Scheduler].[tblSchedule] ([IDSchedule])
GO
ALTER TABLE [Scheduler].[tblMessageLog] CHECK CONSTRAINT [FK_SchedulerTblSchedule_SchedulerTblMessageLog_IDSchedule]
GO
