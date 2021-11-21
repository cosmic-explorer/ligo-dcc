-- MariaDB dump 10.17  Distrib 10.4.11-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: dcc_docdb
-- ------------------------------------------------------
-- Server version	10.4.11-MariaDB-log

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
-- Table structure for table `Topic`
--

DROP TABLE IF EXISTS `Topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Topic` (
  `TopicID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(64) DEFAULT '',
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`TopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Topic`
--

LOCK TABLES `Topic` WRITE;
/*!40000 ALTER TABLE `Topic` DISABLE KEYS */;
INSERT INTO `Topic` VALUES (1,'Detector','Detector','2008-10-27 21:39:40'),(2,'Activity','Activity','2008-10-27 21:39:40'),(3,'Management','Management','2008-10-27 21:42:24'),(4,'Data Analysis','Data Analysis','2008-10-27 21:42:59'),(6,'Observatory Facilities','Observatory Facilities','2008-10-27 22:06:04'),(7,'Vacuum','Vacuum','2008-10-27 22:06:04'),(8,'Seismic Isolation','Seismic Isolation','2008-10-27 22:06:04'),(9,'Suspensions','Suspensions','2008-10-27 22:06:04'),(10,'Laser Systems','Laser Systems','2008-10-27 22:06:04'),(11,'Input Optics','Input Optics','2008-10-27 22:06:04'),(12,'Core Optics','Core Optics','2008-10-27 22:06:04'),(13,'Auxiliary Optics','Auxiliary Optics','2008-10-27 22:06:04'),(14,'Sensing and Control','Sensing and Control','2008-10-27 22:06:04'),(15,'Data Acquisition System','Data Acquisition System','2008-10-27 22:06:04'),(16,'Data and Computing ','Data and Computing ','2008-10-27 22:06:04'),(17,'Project Controls','Project Controls','2008-10-27 22:06:04'),(18,'System Engineering','System Engineering','2008-10-27 22:06:04'),(19,'Basic R&D','Basic R&D','2008-10-27 22:06:04'),(20,'Requirements','Requirements','2008-10-27 22:06:04'),(21,'Conceptual Design','Conceptual Design','2008-10-27 22:06:04'),(22,'Preliminary Design','Preliminary Design','2008-10-27 22:06:04'),(23,'Final Design','Final Design','2008-10-27 22:06:04'),(24,'Installation','Installation','2008-10-27 22:06:04'),(25,'Integration','Integration','2008-10-27 22:06:04'),(26,'System Test','System Test','2008-12-03 23:59:41'),(27,'Commissioning','Commissioning','2008-10-27 22:06:04'),(28,'Upgrades','Upgrades','2008-10-27 22:06:04'),(29,'Operations','Operations','2008-10-27 22:06:04'),(30,'Education, Outreach','Education, Outreach','2008-10-27 22:06:04'),(31,'Modelling','Modelling','2008-10-27 22:06:04'),(32,'Advisory Boards  (e.g., PAC, PAP, ...)','Advisory Boards  (e.g., PAC, PAP, ...)','2013-05-07 21:02:27'),(33,'Change Control','Change Control','2008-10-27 22:06:04'),(34,'Technical Review Board','Technical Review Board','2008-10-27 22:06:04'),(35,'Quality Assurance','Quality Assurance','2008-10-27 22:06:04'),(36,'Safety','Safety','2008-10-27 22:06:04'),(37,'Risk Management','Risk Management','2008-10-27 22:06:04'),(38,'Organizational Relations','Organizational Relations','2008-10-27 22:06:04'),(39,'Procurements','Procurements','2010-06-25 17:46:27'),(40,'Public relations','Public relations','2008-10-27 22:06:04'),(41,'Reviews','Reviews','2008-10-27 22:06:04'),(42,'Operations Business','Operations Business','2008-10-27 22:06:04'),(43,'Policies','Policies','2008-10-27 22:06:04'),(44,'Proposals','Proposals','2008-10-27 22:06:04'),(45,'Reports','Reports','2008-11-04 00:33:29'),(46,'GW source predictions','GW source predictions','2008-10-27 22:06:04'),(47,'Calibration','Calibration','2008-10-27 22:06:04'),(48,'Data quality / vetoes','Data quality / vetoes','2010-02-11 00:35:56'),(49,'Data analysis software','Data analysis software','2008-10-27 22:06:04'),(50,'Compact Binaries','Compact Binaries','2008-10-27 22:06:04'),(51,'GW Bursts','GW Bursts','2008-10-27 22:06:04'),(52,'Continuous Wave','Continuous Wave','2008-10-27 22:06:04'),(53,'Stochastic','Stochastic','2008-10-27 22:06:04'),(54,'Computing/archiving','Computing/archiving','2008-10-27 22:06:04'),(55,'Other data analysis','Other data analysis','2008-10-27 22:06:04'),(56,'Memorandum','Memorandum','2008-11-10 05:19:20'),(57,'Letters','Letters','2008-12-02 18:53:02'),(59,'Temporary Test Document','Temporary Test Document','2018-08-21 22:25:35'),(60,'Fabrication','Fabrication','2009-01-29 00:14:23'),(61,'Meeting','Meeting','2009-01-29 00:14:55'),(62,'Collaboration','Collaboration','2009-01-29 00:16:07'),(63,'Astrophysics / Multi-messenger','Astrophysics / Multi-messenger','2009-02-16 03:11:36'),(64,'Security','Security','2009-03-02 02:30:19'),(65,'Appointment','Appointment','2009-04-24 04:26:25'),(66,'MOU','Memorandum Of Understanding','2009-05-07 16:46:23'),(67,'Subsystem Test','Subsystem Test','2009-07-13 17:53:29'),(68,'Incoming Inspection','Incoming Inspection','2009-07-13 17:54:36'),(69,'Public Talk / Colloquium','Public Talk / Colloquium','2010-02-11 18:21:21'),(70,'Detector Characterization','Detector Characterization','2010-02-10 23:16:01'),(71,'Assembly','Assembly','2010-02-11 22:50:03'),(72,'Document Migration','Document Migration from the old DCC','2010-08-24 03:41:26'),(73,'Limited Lifetime','Limited Lifetime','2010-04-02 03:51:34'),(74,'External Collaboration','External Collaboration','2010-05-03 01:14:28'),(75,'Invoices','Invoices','2010-06-25 17:48:12'),(76,'Diversity','Diversity','2010-11-03 22:53:28'),(77,'NSF','NSF','2010-11-23 18:42:05'),(78,'Personnel','Personnel','2011-05-02 17:29:59'),(79,'Cleaning','Cleaning','2011-05-13 20:55:30'),(80,'Thesis/Dissertation','Thesis/Dissertation','2011-12-08 19:24:10'),(81,'LIGO-India','LIGO-India','2012-04-05 21:42:53'),(82,'State Control and Monitoring','State Control and Monitoring','2012-04-11 00:06:33'),(83,'Squeezer','Squeezer','2012-11-15 18:31:13'),(84,'Operations Liens List','Maintenance and Operations Liens List','2013-04-22 23:53:59'),(85,'Shipping','Shipping','2017-05-05 18:57:14'),(86,'Receiving','Receiving','2017-05-05 18:57:59'),(87,'Property','Property','2017-05-18 19:26:53'),(88,'Machine Learning','Machine Learning','2018-05-14 21:16:44'),(89,'A+','A+ Project','2018-08-21 20:58:54');
/*!40000 ALTER TABLE `Topic` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01 12:52:38
