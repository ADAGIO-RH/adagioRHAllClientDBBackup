USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tzdb].[Intervals](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ZoneId] [int] NOT NULL,
	[UtcStart] [datetime2](0) NOT NULL,
	[UtcEnd] [datetime2](0) NOT NULL,
	[LocalStart] [datetime2](0) NOT NULL,
	[LocalEnd] [datetime2](0) NOT NULL,
	[OffsetMinutes] [smallint] NOT NULL,
	[Abbreviation] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Intervals_Local] ON [Tzdb].[Intervals]
(
	[ZoneId] ASC,
	[LocalStart] ASC,
	[LocalEnd] ASC,
	[UtcStart] ASC
)
INCLUDE([OffsetMinutes],[Abbreviation]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Intervals_Utc] ON [Tzdb].[Intervals]
(
	[ZoneId] ASC,
	[UtcStart] ASC,
	[UtcEnd] ASC
)
INCLUDE([OffsetMinutes],[Abbreviation]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Tzdb].[Intervals]  WITH CHECK ADD  CONSTRAINT [FK_Intervals_Zones] FOREIGN KEY([ZoneId])
REFERENCES [Tzdb].[Zones] ([Id])
GO
ALTER TABLE [Tzdb].[Intervals] CHECK CONSTRAINT [FK_Intervals_Zones]
GO
