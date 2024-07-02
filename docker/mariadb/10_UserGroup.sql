
DROP TABLE IF EXISTS `UsersGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UsersGroup` (
  `UsersGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`UsersGroupID`),
  KEY `EmailUserID` (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UsersGroup`
--

LOCK TABLES `UsersGroup` WRITE;
/*!40000 ALTER TABLE `UsersGroup` DISABLE KEYS */;
INSERT INTO `UsersGroup` VALUES
(1,1,9,'2008-10-30 00:34:10'),
(2,1,45,'2008-10-30 00:34:10'),
(3,1,3,'2008-10-30 00:34:10'),
(4,2,3,'2008-10-30 00:34:10'),
(5,3,3,'2023-07-07 00:00:00');
-- user3 & user4 should have access to nothing
-- (6,4,3,'2023-07-07 00:00:00'),
-- (7,5,3,'2023-07-07 00:00:00'),

/*!40000 ALTER TABLE `UsersGroup` ENABLE KEYS */;
UNLOCK TABLES;
