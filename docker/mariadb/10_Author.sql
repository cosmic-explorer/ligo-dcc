DROP TABLE IF EXISTS `Author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Author` (
  `AuthorID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) NOT NULL,
  `MiddleInitials` varchar(16) DEFAULT NULL,
  `LastName` varchar(100) NOT NULL,
  `InstitutionID` int(11) NOT NULL DEFAULT 0,
  `Active` int(11) DEFAULT 1,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `AuthorAbbr` varchar(10) DEFAULT NULL COMMENT 'Used in the Old DCC',
  `FullAuthorName` varchar(256) DEFAULT NULL COMMENT 'Used in the Old DCC',
  PRIMARY KEY (`AuthorID`),
  KEY `Name` (`LastName`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Author`
--

LOCK TABLES `Author` WRITE;
/*!40000 ALTER TABLE `Author` DISABLE KEYS */;
INSERT INTO `Author` VALUES
(1,'Admin',NULL,'Istrator',26,1,'2021-10-26 00:00:00',NULL,NULL),
(2,'User',NULL,'One',26,1,'2021-10-26 00:00:00',NULL,NULL),
(3,'User',NULL,'Two',26,1,'2021-10-26 00:00:00',NULL,NULL),
(4,'User',NULL,'Three',26,1,'2021-10-26 00:00:00',NULL,NULL);

/*!40000 ALTER TABLE `Author` ENABLE KEYS */;
UNLOCK TABLES;
