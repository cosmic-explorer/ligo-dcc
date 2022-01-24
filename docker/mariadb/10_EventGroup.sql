
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `EventGroup`
--

DROP TABLE IF EXISTS `EventGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EventGroup` (
  `EventGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) NOT NULL DEFAULT '',
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`EventGroupID`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EventGroup`
--

LOCK TABLES `EventGroup` WRITE;
/*!40000 ALTER TABLE `EventGroup` DISABLE KEYS */;
INSERT INTO `EventGroup` VALUES (1,'Collaboration Meetings','Collaboration Meetings','2005-09-03 21:21:00'),(2,'Conferences','Conferences','2005-09-03 21:21:00'),(3,'Seminars','Seminars','2008-11-11 20:53:24'),(4,'Reviews','Reviews','2008-11-11 21:28:45'),(5,'Procurement - Operations','Procurement Documents for Operations','2010-02-25 23:14:18'),(6,'Procurement - aLIGO','Procurement Documents for aLIGO','2010-02-25 23:15:15'),(7,'Procurement - Non-NSF','Procurements Funded by Non - NSF','2013-03-20 21:36:56'),(8,'aLIGO Activities','aLIGO Activities','2013-01-08 21:39:26'),(9,'other','other','2010-10-21 19:21:43'),(10,'Procurement - Operations - India','Procurement Documents for Operations - India','2013-01-08 21:32:47'),(11,'Procurement - Other NSF Grants','Procurements funded by Other NSF Grants','2013-03-20 22:26:37'),(12,'Procurement - Operations FY2015+','Procurement - Operations FY2015 & Beyond','2014-07-12 00:32:04'),(13,'Business Office','Business Office','2014-10-14 17:58:42'),(14,'LVK Operations','LIGO VIRGO KAGRA Operation Activities','2020-10-16 22:26:49');
/*!40000 ALTER TABLE `EventGroup` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
