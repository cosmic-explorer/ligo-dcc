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
-- Table structure for table `SecurityGroup`
--

DROP TABLE IF EXISTS `SecurityGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SecurityGroup` (
  `GroupID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` char(32) NOT NULL,
  `Description` char(64) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `CanCreate` int(11) DEFAULT 0,
  `CanAdminister` int(11) DEFAULT 0,
  `CanView` int(11) DEFAULT 1,
  `CanConfig` int(11) DEFAULT 0,
  `DisplayInList` enum('0','1','2','3') NOT NULL DEFAULT '1' COMMENT '0=don''t_display 1=display everywhere 2=force_display_in_specific_list 3=display only in group membership',
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SecurityGroup`
--

LOCK TABLES `SecurityGroup` WRITE;
/*!40000 ALTER TABLE `SecurityGroup` DISABLE KEYS */;
INSERT INTO `SecurityGroup` VALUES
        (1,'Public_Pending','Public Pending','2009-05-07 17:10:29',0,0,1,0,'0'),
        (3,'docdbrw','Create and View Documents','2008-11-21 18:58:19',1,NULL,1,0,'0'),
        (9,'DCC_Lab','Members of the local Laboratory','2008-10-27 19:19:15',1,0,1,0,'1'),
        (15,'Authors','Authors Only','2019-04-02 00:41:04',1,0,1,0,'2'),
        (16,'NSF_Reviewers','NSF Review Committee','2009-12-16 18:33:47',0,0,1,0,'2'),
        (26,'NSF_LIGO_Office','NSF LIGO Officers','2009-12-16 18:32:40',1,0,1,0,'2'),
        (35,'INST_Auditors','Institutional Auditors','2012-08-27 17:24:03',1,0,1,0,'2'),
        (37,'EXT_Collab','External Collaboration','2019-06-29 01:50:29',1,0,1,0,'3'),
        (39,'NSF_Review_Guest','NSF Review Guest','2015-04-08 01:17:33',1,0,1,0,'2'),
        (41,'NSF_BSR','NSF Business Systems Review','2013-01-26 01:08:57',0,0,1,0,'2'),
        (43,'Obsolete','Repository for obsolete documents','2013-08-23 01:07:36',NULL,NULL,NULL,0,'0'),
        (45,'docdbadm','DocDB Administrators','2017-01-24 03:07:09',1,1,1,1,'0'),
        (46,'External_Reviewers','External Reviewers','2017-03-24 21:40:38',0,0,1,0,'2');
/*!40000 ALTER TABLE `SecurityGroup` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01 12:36:14
