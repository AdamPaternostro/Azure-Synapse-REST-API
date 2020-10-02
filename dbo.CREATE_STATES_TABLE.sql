CREATE TABLE [dbo].[States]
(
	[StateAbbreviation] [varchar](100) NULL,
	[StateName] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED COLUMNSTORE INDEX
)
GO

INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('AL','Alabama');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('AK','Alaska');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('AZ','Arizona');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('AR','Arkansas');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('CA','California');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('CO','Colorado');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('CT','Connecticut');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('DE','Delaware');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('DC','District of Columbia');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('FL','Florida');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('GA','Georgia');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('HI','Hawaii');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('ID','Idaho');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('IL','Illinois');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('IN','Indiana');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('IA','Iowa');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('KS','Kansas');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('KY','Kentucky');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('LA','Louisiana');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('ME','Maine');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MD','Maryland');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MA','Massachusetts');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MI','Michigan');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MN','Minnesota');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MS','Mississippi');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MO','Missouri');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('MT','Montana');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NE','Nebraska');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NV','Nevada');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NH','New Hampshire');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NJ','New Jersey');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NM','New Mexico');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NY','New York');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('NC','North Carolina');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('ND','North Dakota');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('OH','Ohio');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('OK','Oklahoma');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('OR','Oregon');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('PA','Pennsylvania');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('RI','Rhode Island');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('SC','South Carolina');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('SD','South Dakota');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('TN','Tennessee');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('TX','Texas');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('UT','Utah');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('VT','Vermont');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('VA','Virginia');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('WA','Washington');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('WV','West Virginia');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('WI','Wisconsin');
INSERT INTO [dbo].[States] ([StateAbbreviation],[StateName]) VALUES ('WY','Wyoming');