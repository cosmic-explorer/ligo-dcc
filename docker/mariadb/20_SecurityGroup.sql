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
        (2,'LVK','LSC-Virgo-KAGRA Collaboration','2019-01-31 01:51:29',1,NULL,1,0,'1'),
        (3,'docdbrw','Create and View Documents','2008-11-21 18:58:19',1,NULL,1,0,'0'),
        (4,'LSC','LSC member','2008-12-11 00:33:52',1,0,1,0,'1'),
        (9,'LIGO_Lab','Members of the LIGO Laboratory','2008-10-27 19:19:15',1,0,1,0,'1'),
        (10,'Lab_Business','Laboratory Contractual and Administrative - contracts, other fis','2008-12-02 19:43:02',1,0,1,0,'1'),
        (11,'Lab_Management','Laboratory Management','2008-10-27 19:22:21',1,0,1,0,'1'),
        (12,'Lab_ExecComm','LIGO Lab Executive Committee','2013-08-23 01:21:22',1,0,1,0,'1'),
        (13,'Lab_OMT','LIGO Lab Operations Management Team','2017-01-24 03:07:09',1,0,1,0,'1'),
        (14,'Lab_Directorate','Laboratory Directorate','2017-01-24 03:07:09',1,0,1,0,'1'),
        (15,'Authors','Authors Only','2019-04-02 00:41:04',1,0,1,0,'2'),
        (16,'NSF_Reviewers','NSF Review Committee','2009-12-16 18:33:47',0,0,1,0,'2'),
        (17,'Lab_Safety','Laboratory Safety','2009-11-06 00:36:58',1,0,1,0,'2'),
        (18,'MOU_Reviewers','MOU Reviewers','2019-04-02 00:43:28',1,0,1,0,'2'),
        (19,'aLIGO_Business','Advanced LIGO Lab Business','2010-02-13 00:40:37',1,0,1,0,'2'),
        (20,'PAC','Program Advisory Comittee','2009-10-14 22:19:01',1,0,1,0,'2'),
        (21,'LSC_Spokesperson','LSC Spokesperson','2019-04-02 00:49:06',1,0,1,0,'2'),
        (22,'LIGO_Lab_IT','LIGO Lab IT Staff','2019-04-02 00:46:34',1,0,1,0,'2'),
        (23,'Meeting_Support','Meeting Support Personnel','2019-04-02 00:46:12',1,0,1,0,'2'),
        (24,'Lab_Security','Laboratory Cybersecurity','2009-11-06 00:36:48',1,0,1,0,'2'),
        (25,'Richard_Bagley','Richard Bagley','2014-01-18 02:34:34',1,0,1,0,'0'),
        (26,'NSF_LIGO_Office','NSF LIGO Officers','2009-12-16 18:32:40',1,0,1,0,'2'),
        (27,'PAC_Guest','PAC Guest','2011-11-14 20:35:15',1,0,1,0,'2'),
        (28,'Lab_StaffComm','Lab Staffing Committee','2010-01-11 23:30:09',1,0,1,0,'2'),
        (29,'LAAAP','LIGO Astronomy and Astrophysics Advisory Panel','2010-03-25 20:10:26',0,0,1,0,'2'),
        (30,'PAP','LIGO Program Advisory Panel','2010-09-13 18:08:15',0,0,1,0,'2'),
        (31,'LAAAP_Guest','LAAAP Guest','2011-04-10 16:06:03',0,0,1,0,'2'),
        (32,'LIGO_India_Reviewers','LIGO-India Reviewers','2019-07-01 20:48:46',0,0,1,0,'3'),
        (33,'LIGO_Oversight','LIGO Oversight Committee','2011-12-01 17:54:53',1,0,1,0,'2'),
        (34,'LSC_ExecComm','LSC Executive Committee','2019-04-15 21:51:34',1,0,1,0,'2'),
        (35,'CIT_Auditors','CIT Auditors','2012-08-27 17:24:03',1,0,1,0,'2'),
        (36,'LIGO_India','LIGO-India member','2019-07-01 20:48:51',1,0,1,0,'3'),
        (37,'KAGRA','KAGRA Collaboration','2019-06-29 01:50:29',1,0,1,0,'3'),
        (38,'CDS_Reviewers','CDS Reviewers','2012-08-16 22:03:34',1,0,1,0,'2'),
        (39,'NSF_Review_Guest','NSF Review Guest','2015-04-08 01:17:33',1,0,1,0,'2'),
        (40,'Public_Certify','Group allowed to make documents public','2019-04-18 20:47:43',0,0,1,0,'3'),
        (41,'NSF_BSR','NSF Business Systems Review','2013-01-26 01:08:57',0,0,1,0,'2'),
        (42,'Caltech_OSR','Caltech Office of Sponsored Research','2013-01-30 23:05:57',1,0,1,0,'2'),
        (43,'Obsolete','Repository for obsolete documents','2013-08-23 01:07:36',NULL,NULL,NULL,0,'0'),
        (44,'Lab_Recompetition_Committee','Laboratory Recompetition Committee','2015-06-24 04:38:27',1,0,1,0,'2'),
        (45,'docdbadm','DocDB Administrators','2017-01-24 03:07:09',1,1,1,1,'0'),
        (46,'External_Reviewers','External Reviewers','2017-03-24 21:40:38',0,0,1,0,'2'),
        (47,'Virgo_Spokesperson','Virgo Spokesperson','2017-09-15 22:12:03',1,0,1,0,'2'),
        (48,'LSC_Council','LSC Council Delegates','2017-12-22 20:49:32',1,0,1,0,'2'),
        (49,'Management_Retreat','Management Retreat Attendees','2018-04-20 22:58:53',1,0,1,0,'0'),
        (50,'LSC_Program_Committee','LSC Program Committee','2018-05-17 20:41:15',1,0,1,0,'2'),
        (51,'Change_Request_Board','Change Request Board','2018-07-19 01:59:42',0,0,1,0,'2'),
        (52,'Lab_Supervisors','LIGO Lab Supervisors','2018-08-25 00:47:31',1,0,1,0,'2'),
        (53,'Lab_Safety_Officers','Laboratory Safety Officers','2019-01-07 21:25:49',1,0,1,0,'2'),
        (54,'EPO_PAC','Education & Public Outreach Program Advisory Committee','2019-03-13 03:19:05',1,0,1,0,'2'),
        (55,'VIRGO','VIRGO','2019-03-07 01:57:23',1,0,1,0,'3'),
        (56,'Lab_LIO','LIGOLab - LIGO-India','2019-06-29 02:22:49',1,0,1,0,'2');
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
