DROP TABLE IF EXISTS `RemoteUser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RemoteUser` (
  `RemoteUserID` int(11) NOT NULL AUTO_INCREMENT,
  `RemoteUserName` char(255) NOT NULL,
  `EmailUserID` int(11) NOT NULL DEFAULT 0,
  `EmailAddress` char(255) NOT NULL,
  PRIMARY KEY (`RemoteUserID`),
  KEY `Name` (`RemoteUserName`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RemoteUser`
--

LOCK TABLES `RemoteUser` WRITE;
/*!40000 ALTER TABLE `RemoteUser` DISABLE KEYS */;
INSERT INTO `RemoteUser` VALUES
(1,'admin',1,'admin@local'),
(2,'user1@local',2,'user1@local'),
(3,'user2@local',3,'user2@local'),
(4,'user3@local',4,'user3@local');

/*!40000 ALTER TABLE `RemoteUser` ENABLE KEYS */;
UNLOCK TABLES;