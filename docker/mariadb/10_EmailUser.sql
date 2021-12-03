DROP TABLE IF EXISTS `EmailUser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EmailUser` (
  `EmailUserID` int(11) NOT NULL AUTO_INCREMENT,
  `Username` char(255) NOT NULL,
  `Password` char(32) NOT NULL DEFAULT '',
  `Name` char(255) NOT NULL,
  `EmailAddress` char(255) NOT NULL,
  `PreferHTML` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `CanSign` int(11) NOT NULL DEFAULT 0,
  `Verified` int(11) NOT NULL DEFAULT 0,
  `AuthorID` int(11) NOT NULL DEFAULT 0,
  `EmployeeNumber` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EmailUser`
--

LOCK TABLES `EmailUser` WRITE;
/*!40000 ALTER TABLE `EmailUser` DISABLE KEYS */;
INSERT INTO `EmailUser` VALUES
(1,'admin','','Administrator','admin@local',0,'2019-12-31 10:00:15',1,0,1,255),
(2,'user1','','User One','user1@local',0,'2021-10-26 00:00:00',1,0,2,254),
(3,'user2','','User Two','user2@local',0,'2021-10-26 00:00:00',1,0,3,253),
(4,'user3','','User Three','user3@local',0,'2021-10-26 00:00:00',1,0,4,252);

UNLOCK TABLES;
