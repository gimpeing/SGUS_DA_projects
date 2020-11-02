USE [SG_Crime]
go

/* Add constraint to tables */
ALTER TABLE [Crime_type]
ADD CONSTRAINT [un_crime] UNIQUE ([Type]);

/* Can't add this constraints as NPC change Div, thus will have repeated name under different div */
---ALTER TABLE [Police_station]
---ADD CONSTRAINT [un_NPC] UNIQUE ([PoliceStation]);

ALTER TABLE [Crime_log]
ADD CONSTRAINT [FK_crimeLog_crimeType] FOREIGN KEY ([Crime_code])
REFERENCES Crime_type(Crime_code);

ALTER TABLE [Crime_log]
ALTER COLUMN PoliceStation_ID int;

ALTER TABLE [Crime_log]
ADD CONSTRAINT [FK_crimeLog_NPC] FOREIGN KEY ([PoliceStation_ID])
REFERENCES Police_station(PoliceStation_ID);

ALTER TABLE [Arrested]
ADD CONSTRAINT [FK_arr_crimeType] FOREIGN KEY ([Crime_code])
REFERENCES Crime_type(Crime_code);

ALTER TABLE [Victims]
ADD CONSTRAINT [FK_vic_crimeType] FOREIGN KEY ([Crime_code])
REFERENCES Crime_type(Crime_code);