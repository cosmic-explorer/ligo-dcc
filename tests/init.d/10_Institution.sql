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
-- Table structure for table `Institution`
--

DROP TABLE IF EXISTS `Institution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Institution` (
  `InstitutionID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortName` varchar(40) NOT NULL DEFAULT '',
  `LongName` varchar(80) NOT NULL DEFAULT '',
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`InstitutionID`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Institution`
--

LOCK TABLES `Institution` WRITE;
/*!40000 ALTER TABLE `Institution` DISABLE KEYS */;
INSERT INTO `Institution` VALUES (1,'WA','University of Western Australia','2008-10-24 22:45:12'),(2,'CS','Charles Sturt University','2008-10-24 22:45:12'),(3,'AN','Australian National University','2008-10-24 22:45:12'),(4,'UM','The University of Melbourne','2008-10-24 22:45:12'),(5,'MO','Monash University','2008-10-24 22:45:12'),(6,'UA','University of Adelaide','2008-10-24 22:45:12'),(7,'CA','Caltech-CaRT','2008-10-24 22:45:12'),(8,'AU','Andrews University','2008-10-24 22:45:12'),(9,'AEI-Potsdam-Golm','Albert-Einstein-Institut, Postdam-Golm','2015-09-02 22:40:59'),(10,'CL','Carleton College','2008-10-24 22:45:12'),(11,'CH','California Institute of Technology','2008-10-24 22:45:12'),(12,'SE','Southeastern Louisiana University','2008-10-24 22:45:12'),(13,'EU','Eötvös University','2013-08-23 00:09:17'),(14,'ER','Embry-Riddle Aeronautical University','2008-10-24 22:45:12'),(15,'CO','Columbia University','2008-10-24 22:45:12'),(16,'GU','University of Glasgow','2008-10-24 22:45:12'),(17,'AH','Albert-Einstein-Institut, Max-Planck-Institut fur Gravitationsphysik','2011-10-28 17:55:24'),(18,'UW','University of Wisconsin-Milwaukee','2008-10-24 22:45:12'),(19,'BR','University of Birmingham','2008-10-24 22:45:12'),(20,'HU','Leibniz Universität Hannover','2013-08-23 00:11:53'),(21,'CU','Cardiff University','2008-10-24 22:45:12'),(22,'SF','The University of Sheffield','2008-10-24 22:45:12'),(23,'RA','Rutherford Appleton Laboratory','2008-10-24 22:45:12'),(24,'SH','University of Southampton','2008-10-24 22:45:12'),(25,'SC','University of Strathclyde','2008-10-24 22:45:12'),(26,'CT','LIGO - California Institute of Technology','2008-10-24 22:45:12'),(27,'RI','Rochester Institute of Technology','2008-10-24 22:45:12'),(28,'ND','NASA/Goddard Space Flight Center','2008-10-24 22:45:12'),(29,'HC','Hobart and William Smith Colleges','2008-10-24 22:45:12'),(30,'IA','Institute of Applied Physics','2008-10-24 22:45:12'),(31,'IU','Inter-University Centre for Astronomy  and Astrophysics','2008-10-24 22:45:12'),(32,'LL','Loyola University','2008-10-24 22:45:12'),(33,'LO','LIGO - Hanford Observatory','2008-10-24 22:45:12'),(34,'LV','LIGO - Livingston Observatory','2008-10-24 22:45:12'),(35,'LM','LIGO - Massachusetts Institute of Technology','2008-10-24 22:45:12'),(36,'LU','Louisiana State University','2008-10-24 22:45:12'),(37,'MD','University of Maryland','2008-10-24 22:45:12'),(38,'MU','University of Michigan','2008-10-24 22:45:12'),(39,'MS','Moscow State University','2008-10-24 22:45:12'),(40,'MT','Montana State University','2008-10-24 22:45:12'),(41,'NA','National Astronomical Observatory of Japan','2008-10-24 22:45:12'),(42,'NO','Northwestern University','2008-10-24 22:45:12'),(43,'PU','The Pennsylvania State University','2008-10-24 22:45:12'),(44,'LE','Louisiana Tech University','2008-10-24 22:45:12'),(45,'SA','Stanford University','2008-10-24 22:45:12'),(46,'SN','University of Sannio at Benevento','2008-10-24 22:45:12'),(47,'SJ','San Jose State University','2008-10-24 22:45:12'),(48,'SM','Sonoma State University','2008-10-24 22:45:12'),(49,'SO','Southern University and A&M College','2008-10-24 22:45:12'),(50,'SUGWG','Syracuse University','2011-09-14 18:16:23'),(51,'TR','Trinity University','2008-10-24 22:45:12'),(52,'FA','University of Florida','2008-10-24 22:45:12'),(53,'BB','Universitat de les Illes Balears','2008-10-24 22:45:12'),(54,'AM','University of Massachusetts - Amherst','2008-10-24 22:45:12'),(55,'MN','University of Minnesota','2008-10-24 22:45:12'),(56,'MI','University of Mississippi','2008-10-24 22:45:12'),(57,'OU','University of Oregon','2008-10-24 22:45:12'),(58,'RO','University of Rochester','2008-10-24 22:45:12'),(59,'UTAustin','The University of Texas at Austin','2018-09-21 01:59:27'),(60,'CGWA-UTRGV','Center for Gravitational Wave Astronomy - University of Texas Rio Grande Valley','2015-05-18 21:31:11'),(61,'WU','Washington State University','2008-10-24 22:45:12'),(62,'YA','Yale University','2008-12-17 19:29:37'),(63,'VIRGO','Virgo Collaboration','2009-09-23 18:08:14'),(64,'GEO','GEO600 Project','2009-01-12 23:27:30'),(65,'Cornell','Cornell University','2009-01-20 17:38:42'),(66,'NSF','External Committee','2019-03-13 19:36:16'),(67,'HM','Harvey Mudd College','2009-02-27 20:53:04'),(68,'EGO','European Gravitational Observatory','2009-03-11 17:12:18'),(69,'Osaka','Osaka University','2009-05-12 17:18:54'),(70,'NUT','Nagaoka University of Technology','2009-03-12 17:40:29'),(71,'Georgia Tech','Georgia Tech','2009-05-04 15:45:33'),(72,'MEGA','McNeese State University','2009-06-05 16:56:35'),(73,'UWash','University of Washington','2009-06-05 16:57:04'),(75,'UTokyo','The University of Tokyo','2016-04-27 00:14:14'),(76,'VT','Virginia Tech','2009-07-01 22:05:20'),(77,'UCLA','University of California, Los Angeles','2009-06-24 18:19:37'),(81,'UPMC','Université Pierre et Marie Curie','2009-06-25 15:12:52'),(83,'FSUJ','Friedrich-Schiller-Universität Jena','2009-07-01 22:08:10'),(84,'ESA','European Space Agency','2009-07-01 22:18:11'),(85,'PNNL','Pacific Northwest National Laboratory','2009-08-04 17:36:47'),(86,'PROMEC','PROMEC','2009-09-23 18:07:50'),(87,'GEC','Gulf Engineers & Consultants','2009-09-25 17:45:38'),(88,'Smith','Smith College','2009-10-01 00:11:22'),(89,'HOLYOKE','Mt. Holyoke College','2009-10-01 00:10:14'),(91,'USCISI','USC Information Sciences Institute','2009-10-14 21:05:59'),(92,'UoM','University of Manchester','2009-10-14 21:06:30'),(93,'NOAO','National Optical Astronomy Observatory','2009-10-14 21:05:27'),(94,'ORNL','Oak Ridge National Laboratory','2009-10-14 21:05:27'),(95,'FANDM','Franklin & Marshall College','2009-10-14 21:12:54'),(96,'UCSB','University of California, Santa Barbara','2009-10-14 21:12:54'),(97,'MKI','MIT Kavli Institute for Astrophysics and Space Research','2009-10-14 21:30:09'),(98,'IAPFSUJ','Institut für Angewandte Physik, Friedrich-Schiller-Universitat Jena','2009-10-30 17:46:49'),(99,'HY','Hanyang University','2009-12-22 21:48:41'),(100,'KISTI','Korea Institute of Science and Tech Information','2009-11-03 00:49:56'),(101,'LUND','Lund University','2009-12-24 00:40:38'),(102,'NIMS','National Institute of Mathematical Sciences','2009-11-03 00:49:56'),(103,'PNU','Pusan National University','2009-12-22 21:50:31'),(104,'SNU','Seoul National University','2009-12-22 21:51:16'),(105,'TSINGHUA','Tsinghua University','2009-12-22 21:51:43'),(106,'LBL','Lawrence Berkeley National Laboratory','2009-11-23 18:52:30'),(107,'IntegPhotonics','Integrated Photonics, Inc','2009-11-23 18:53:57'),(108,'Adler','Adler Planetarium','2009-11-23 18:53:57'),(109,'SLAC','SLAC National Accelerator Laboratory','2009-11-23 18:55:14'),(110,'AOSense','AOSense, Inc','2009-11-23 18:55:14'),(111,'Princeton','Princeton University','2009-11-23 18:58:25'),(112,'UPenn','University of Pennsylvania','2009-11-23 18:59:09'),(113,'FULLERTON','California State University, Fullerton','2013-08-07 19:41:15'),(114,'Unknown','Unknown Institution','2010-03-10 22:02:35'),(115,'CAMBR','University of Cambridge','2010-03-12 00:37:42'),(116,'UNH','University of New Hampshire','2010-03-18 22:36:07'),(117,'NIST','National Institute of Standards & Technology','2010-03-31 22:49:32'),(118,'KSU','Kansas State University','2010-03-31 22:49:32'),(119,'WashU','Washington University','2010-03-31 22:49:32'),(120,'LLNL','Lawrence Livermore National Laboratory','2010-03-31 22:49:32'),(121,'BNL','Brookhaven National Laboratory','2010-03-31 22:49:32'),(122,'MLC','Micro-g LaCoste, Inc.','2010-03-31 22:49:32'),(123,'BATC','Ball Aerospace & Technologies Corp.','2010-03-31 22:49:32'),(124,'UON','University of Napoli','2010-06-07 18:44:52'),(125,'IceCube','IceCube Neutrino Observatory','2010-09-20 17:54:24'),(126,'UCB','University of California, Berkeley','2010-12-17 18:31:51'),(127,'NTHU','National Tsing Hua University','2011-05-09 20:27:51'),(128,'CITA','Canadian Institute for Theoretical Astrophysics','2015-05-18 21:39:01'),(129,'ICRR','University of Tokyo Institute for Cosmic Ray','2011-07-09 00:35:18'),(130,'IUCAA','The Inter-University Centre for Astronomy and Astrophysics, Pune, India','2011-09-30 17:11:25'),(131,'RRI','Raman Research Institute','2011-09-30 17:12:26'),(132,'CMI','Chennai Mathematical Institute','2016-11-16 02:52:03'),(133,'IISER-TVM','Indian Institute of Science Education and Research, Thiruvananthapuram','2011-10-14 21:30:09'),(134,'IITGN','Indian Institute of Technology Gandhinagar','2012-06-12 22:04:44'),(135,'GWINPE','Instituto Nacional de Pesquisas Espaciais/Sao Jose,Brazil','2011-10-24 22:08:23'),(136,'SNS','Scuola Normale Superiore','2011-12-08 21:15:44'),(137,'RRI','Raman Research Institute, Bangalore','2012-06-12 22:09:29'),(138,'RRCAT','Raja Ramanna Centre for Advanced Technology','2012-01-06 00:11:10'),(139,'IISER-KOL','Indian Institute Of Science Education and Research, Kolkata','2012-01-06 00:11:10'),(140,'TIFR','Tata Institute for Fundamental Research ','2012-01-06 00:11:10'),(141,'American','American University','2012-02-17 01:06:13'),(142,'UAZ','University of Arizona','2012-03-14 01:17:24'),(143,'ACU','Abilene Christian University','2012-03-22 21:10:03'),(144,'KU','Kyoto University','2012-03-29 18:13:55'),(145,'IPR','Institute for Plasma Research','2012-04-15 00:24:35'),(146,'USU','Utah State University','2012-05-07 19:16:17'),(147,'CWM','College of William and Mary','2012-05-07 19:16:17'),(148,'VCQ','Vienna Center for Quantum Science and Technology','2012-06-01 17:09:48'),(149,'NIKHEF','National Institute for Subatomic Physics','2012-06-01 18:24:05'),(150,'JPL','Jet Propulsion Laboratory','2012-06-04 17:50:49'),(151,'IPR-Bhat','Institute for Plasma Research - Bhat ','2012-06-12 22:11:04'),(152,'INGV','Istituto Nazionale di Geofisica & Vulcanologia','2013-05-09 20:34:27'),(153,'AGWG','Argentinian Gravitational Wave Group','2013-03-08 23:02:07'),(154,'ULB','University of Brussels','2013-03-08 23:02:07'),(155,'GWU','George Washington University','2013-03-08 23:02:07'),(156,'MontclairState','Montclair State University','2013-05-09 20:36:22'),(157,'ICTS-TIFR','International Center for Theoretical Sciences, Bangalore','2013-06-01 00:57:12'),(158,'UWS','University of the West of Scotland','2013-07-02 04:17:27'),(159,'ICTPSAIFR','Int\'l Centre for Theoretical Physics-S. American Inst for Fundamental Research','2013-10-09 19:23:51'),(160,'MontclairS','Montclair State University','2013-12-06 18:52:34'),(161,'Mayfield','Mayfield High School','2014-01-31 02:14:58'),(162,'Arcadia','Arcadia High School','2014-01-31 02:14:58'),(163,'WVU','West Virginia University','2014-04-11 17:44:33'),(164,'Whitman','Whitman College','2014-04-11 17:44:33'),(165,'Toyama','University of Toyama','2014-04-25 19:08:47'),(166,'NIIGATA','Niigata University','2014-04-28 05:57:20'),(167,'UChicago','University of Chicago','2014-10-01 23:11:11'),(168,'GaTech','Georgia Institute of Technology','2014-10-01 23:11:11'),(170,'AEI-Golm','Albert-Einstein-Institut, Postdam-Golm','2015-07-13 22:04:09'),(171,'KCL','Kings College, University of London','2015-03-12 20:52:10'),(172,'Uni-Hamburg','Institute for Laser Physics, University of Hamburg','2015-03-12 20:52:10'),(173,'KAGRA','KAGRA','2015-06-22 23:23:12'),(175,'AEI-Hannover-Data','Albert-Einstein-Institut, Hannover-Data','2015-09-02 21:01:38'),(176,'TTU','Texas Tech University','2015-09-21 23:16:26'),(177,'UAH','University of Alabama - Huntsville','2015-09-30 00:11:02'),(178,'Kenyon','Kenyon College','2015-09-30 00:11:02'),(179,'CalStateLA','California State University, Los Angeles','2016-11-23 01:44:36'),(180,'OEwaves','OEwaves Inc.','2015-11-18 21:32:10'),(181,'SZTE','Szeged University','2015-12-21 22:25:30'),(182,'NCSARG','NCSARG - Univ of Illinois at Urbana-Champaign','2016-06-13 23:08:52'),(183,'CUHK','The Chinese University of Hong Kong','2016-04-02 00:17:50'),(184,'InjeU','Inje University','2016-06-13 23:09:59'),(185,'IIT-Hydera','Indian Institute of Technology Hyderabad','2016-09-23 01:45:20'),(186,'IAR','Institute of Advanced Research, Gandhinagar','2018-06-18 23:31:37'),(187,'UWB','University of Washington Bothell','2016-09-23 01:45:20'),(188,'Bellevue','Bellevue College','2017-06-30 22:25:16'),(189,'CSU','Colorado State University - Advanced Coatings Group','2016-09-23 01:45:20'),(190,'IIP-UFRN','International Institute of Physics, Universidade Federal do Rio Grande do Norte','2016-11-08 03:16:11'),(191,'IIT-Madras','Indian Institute of Technology Madras','2016-11-11 19:39:08'),(192,'NASA-MSFC','NASA - Marshall Space Flight Center','2016-11-19 01:16:05'),(193,'MUIC','Mahidol University International College','2017-01-24 01:51:29'),(194,'External','NSF or External Committee','2017-02-06 20:35:16'),(195,'Swinburne','Swinburne University of Technology ','2017-03-31 02:12:56'),(196,'UZH','University of Zurich','2017-03-31 02:12:56'),(197,'KASI','Korea Astronomy and Space Science Institute','2017-03-31 02:12:56'),(198,'IIT-Bombay','Indian Institute of Technology Bombay','2017-05-06 01:37:04'),(199,'INAF','INAF-Osservatorio Astronomico di Padova','2017-07-13 17:58:29'),(200,'SPFI','Sao Paulo Federal Institute','2017-07-18 00:47:40'),(201,'NCHC','National Center for High-Performance Computing, Taiwan','2017-07-18 00:47:40'),(202,'Hillsdale','Hillsdale College','2017-07-18 23:34:20'),(204,'UMontreal','University of Montreal','2017-09-11 15:30:24'),(205,'Birmingham','University of Birmingham','2017-09-28 23:27:50'),(206,'DCSEM','DCSEM','2017-10-09 19:03:35'),(207,'Villanova','Villanova University','2017-11-29 01:26:02'),(208,'IISER-Pune','Indian Institute Of Science Education and Research, Pune','2017-12-01 01:02:45'),(209,'UNIST','Ulsan National Institute of Science and Technology','2018-01-09 19:32:04'),(210,'ILP-UH','University of Hamburg','2018-01-26 17:28:27'),(211,'Ewha','Ewha Womans University','2018-03-07 02:17:36'),(212,'UCBerkeley','University of California, Berkeley','2018-03-21 19:05:58'),(213,'Vanderbilt','Vanderbilt University','2018-05-14 21:34:52'),(214,'UniFI','University of Florence','2018-05-16 23:58:10'),(215,'INFN','National Institute of Nuclear Physics (INFN)','2018-05-16 23:58:10'),(216,'Portsmouth','University of Portsmouth','2018-06-13 17:52:06'),(217,'AEI-Theory','Albert-Einstein-Institut, Max-Planck-Institut - Theory ','2018-09-04 22:13:50'),(218,'CNU','Christopher Newport University','2018-09-04 22:12:57'),(219,'LIO','LIGO - India','2018-09-26 17:14:57'),(220,'URI','University of Rhode Island','2018-09-26 19:22:10'),(221,'SHCSA','Sacred Heart College, South Australia','2018-09-27 20:31:48'),(222,'USDC','University of Santiago de Compostela','2018-10-22 23:59:23'),(223,'Bard','Bard College','2018-10-22 23:59:23'),(224,'AEI-Theory','AEI-Hannover Theory','2018-11-03 00:05:10'),(225,'Haverford','Haverford College','2018-11-08 08:18:09'),(226,'Marquette','Marquette University','2019-01-04 22:39:28'),(227,'MST','Missouri University of Science and Technology','2019-01-04 23:56:48'),(228,'UofA','University of Arizona','2019-02-08 22:10:52'),(229,'CUW','Concordia University Wisconsin','2019-03-15 02:12:04'),(230,'SBU/CCA','Stony Brook / Flatiron CCA','2019-03-22 19:29:11'),(231,'BNU','Beijing Normal University','2019-05-07 16:50:12'),(232,'Lancaster','University of Lancaster','2019-08-07 19:16:04'),(233,'UUtah','University of Utah','2019-09-02 02:10:10'),(234,'BarIlan','Bar-Ilan University','2019-09-19 19:15:10');
/*!40000 ALTER TABLE `Institution` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01 12:53:51