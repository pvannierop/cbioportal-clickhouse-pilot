-- SQL command to create the table genetic_alteration_normalized in cbioportal mysql database
-- this table normalizes the comma separated VALUES column in genetic_alteration table
-- Each value in the comma separated VALUES column will be added as a separate row
CREATE TABLE `genetic_alteration_normalized` (
  `GENETIC_PROFILE_ID` int(11) NOT NULL,
  `GENETIC_ENTITY_ID` int(11) NOT NULL,
  `SAMPLE_INTERNAL_ID` int(11) NOT NULL,
  `VALUE` longtext NOT NULL,
  PRIMARY KEY (`GENETIC_PROFILE_ID`,`GENETIC_ENTITY_ID`,`SAMPLE_INTERNAL_ID` ),
  KEY `GENETIC_ENTITY_ID` (`GENETIC_ENTITY_ID`),
  CONSTRAINT `genetic_alteration_normalized_ibfk_1` FOREIGN KEY (`GENETIC_PROFILE_ID`) REFERENCES `genetic_profile` (`GENETIC_PROFILE_ID`) ON DELETE CASCADE,
  CONSTRAINT `genetic_alteration_normalized_ibfk_2` FOREIGN KEY (`GENETIC_ENTITY_ID`) REFERENCES `genetic_entity` (`ID`) ON DELETE CASCADE,
  CONSTRAINT `genetic_alteration_normalized_ibfk_3` FOREIGN KEY (`SAMPLE_INTERNAL_ID`) REFERENCES `sample` (`INTERNAL_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;