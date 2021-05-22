USE [EntertainmentAgencyDW]
GO
/****** Object:  Table [dbo].[DimAgents]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAgents](
	[AgentKey] [int] NOT NULL,
	[AgtFirstName] [varchar](25) NULL,
	[AgtLastName] [varchar](25) NULL,
	[AgtCity] [varchar](30) NOT NULL,
	[AgtState] [varchar](2) NULL,
	[AgtZipCode] [varchar](10) NULL,
 CONSTRAINT [PK_DimAgents] PRIMARY KEY CLUSTERED 
(
	[AgentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimCustomers]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCustomers](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CustFirstName] [varchar](25) NULL,
	[CustLastName] [varchar](25) NULL,
	[CustCity] [varchar](30) NOT NULL,
	[CustZipCode] [varchar](10) NULL,
	[Start] [date] NOT NULL,
	[End] [date] NULL,
 CONSTRAINT [PK_DimCustomers] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimDate]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDate](
		[DateKey] INT, 
		[FullDateAlternateKey] [date] NOT NULL,
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[EnglishDayNameOfWeek] [varchar](10) NOT NULL,
		[DutchDayNameOfWeek] [varchar](10) NOT NULL,
		[DayOfWeek] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[EnglishMonthName] [varchar](10) NOT NULL,
		[DutchMonthName] [varchar](10) NOT NULL,
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimEntertainers]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimEntertainers](
	[EnterTainerKey] [int] NOT NULL,
	[EntStageName] [varchar](50) NULL,
	[EntCity] [varchar](30) NULL,
	[EntState] [varchar](2) NULL,
	[EntZipCode] [varchar](10) NULL,
 CONSTRAINT [PK_DimEntertainers] PRIMARY KEY CLUSTERED 
(
	[EnterTainerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimMusical_Styles]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMusical_Styles](
	[Musical_StyleKey] [int] NOT NULL,
	[StyleName] [varchar](75) NOT NULL,
 CONSTRAINT [PK_DimMusical_Styles] PRIMARY KEY CLUSTERED 
(
	[Musical_StyleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactEngagements]    Script Date: 2021-04-07 15:38:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactEngagements](
	[EngagementKey] [int] NOT NULL,
	[StartDateKey] [int] NOT NULL,
	[EndDateKey] [int] NOT NULL,
	[NumberOfDays] [int] NOT NULL,
	[StartTime] [time] (7) NOT NULL,
	[StopTime] [time] (7) NOT NULL,
	[NumberOfHours] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[AgentKey] [int] NOT NULL,
	[EntertainerKey] [int] NOT NULL,
	[Musical_StyleKey] [int] NOT NULL,
	[ContractPrice] [decimal](7, 2) NOT NULL,
	[CommissionAgent] [decimal](7, 2) NOT NULL
 CONSTRAINT [PK_FactEngagements] PRIMARY KEY CLUSTERED 
(
	[EngagementKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimAgents] FOREIGN KEY([AgentKey])
REFERENCES [dbo].[DimAgents] ([AgentKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimAgents]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimCustomers] FOREIGN KEY([CustomerKey])
REFERENCES [dbo].[DimCustomers] ([CustomerKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimCustomers]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimStartDate] FOREIGN KEY([StartDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimStartDate]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimEndDate] FOREIGN KEY([EndDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimEndDate]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimEntertainers] FOREIGN KEY([EntertainerKey])
REFERENCES [dbo].[DimEntertainers] ([EnterTainerKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimEntertainers]
GO
ALTER TABLE [dbo].[FactEngagements]  WITH CHECK ADD  CONSTRAINT [FK_FactEngagements_DimMusical_Styles] FOREIGN KEY([Musical_StyleKey])
REFERENCES [dbo].[DimMusical_Styles] ([Musical_StyleKey])
GO
ALTER TABLE [dbo].[FactEngagements] CHECK CONSTRAINT [FK_FactEngagements_DimMusical_Styles]
GO
