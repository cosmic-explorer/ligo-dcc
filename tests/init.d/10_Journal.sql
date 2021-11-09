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
-- Table structure for table `Journal`
--

DROP TABLE IF EXISTS `Journal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Journal` (
  `JournalID` int(11) NOT NULL AUTO_INCREMENT,
  `Abbreviation` varchar(64) NOT NULL DEFAULT '',
  `Name` varchar(128) NOT NULL DEFAULT '',
  `Publisher` varchar(64) NOT NULL DEFAULT '',
  `URL` varchar(240) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Acronym` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`JournalID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Journal`
--

LOCK TABLES `Journal` WRITE;
/*!40000 ALTER TABLE `Journal` DISABLE KEYS */;
INSERT INTO `Journal` VALUES (1,'Phys Rev D','Physical Review D','American Physical Society','http://prd.aps.org/','2008-03-20 00:57:46','PRD'),(2,'ApJ Letters','Astrophysical Journal Letters','American Astronomical Society','http://www.journals.uchicago.edu/loi/apjl','2008-03-20 18:26:44','APJL'),(3,'Phys Rev Letters','Physical Review Letters','American Physical Society','http://prl.aps.org/','2008-03-20 18:28:39','PRL'),(4,'Class Quant Grav','Classical and Quantum Gravity','Institute of Physics','http://www.iop.org/EJ/journal/CQG','2008-03-20 18:37:07','CQG'),(5,'Rev Sci Instrum','Review of Scientific Instruments','American Institute of Physics','http://rsi.aip.org','2008-03-20 18:34:37','RSI'),(6,'J Opt A: Pure Appl Opt','Journal of Optics A: Pure and Applied Optics','Institute of Physics','http://www.iop.org/EJ/journal/JOptA','2008-03-20 23:46:07','JOPTA'),(7,'Nature','Nature','Nature Publishing Group','http://www.nature.com/','2008-11-05 00:12:27','NATURE'),(8,'Appl Opt','Applied optics','OPTICAL SOC AMER','http://ao.osa.org/browse.cfm','2008-11-13 01:48:43','AO'),(9,'Appl Phys B','Applied physics. B, Lasers and optics','SPRINGER-VERLAG','http://www.springerlink.com/content/0946-2171/','2008-11-13 01:22:26','APB'),(10,'Mon Not R Astron Soc','MONTHLY NOTICES OF THE ROYAL ASTRONOMICAL SOCIETY','BLACKWELL PUBLISHING LTD','http://www.blackwell-synergy.com/rd.asp?goto=journal&code=MNR','2008-11-13 01:58:07','MNRAS'),(11,'Science','Science','American Association for the Advancement of Science','http://www.aaas.org/','2008-11-13 01:32:40','Science'),(12,'Rev. Sci. Instrum.','Review of Scientific Instruments','American Institute of Physics','http://rsi.aip.org/','2008-11-13 01:37:54','RSI'),(13,'Phys Today','Physics Today','American Institute of Physics ','http://www.physicstoday.org/','2008-11-13 01:39:57','PT'),(14,'New Astronomy','New Astronomy','ELSEVIER SCIENCE BV','http://www.sciencedirect.com/science/journal/13841076','2008-11-13 01:46:06','NA'),(15,'Rev Mod Phys','Reviews of Modern Physics','The American Physical Society','http://rmp.aps.org/','2008-11-13 01:51:18','RMP'),(16,'Optics Express','Optics Express','The Optical Society (OSA)','http://www.opticsinfobase.org/oe/home.cfm','2011-12-19 23:47:51','OE'),(17,'ApJ','The Astrophysical Journal','IOPscience','http://iopscience.iop.org/0004-637X/','2014-05-07 01:00:28','ApJ'),(18,'ApJS','Astrophysical Journal Supplement Series','The American Astronomical Society','http://iopscience.iop.org/journal/0067-0049','2016-07-21 20:24:12','ApJS');
/*!40000 ALTER TABLE `Journal` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01 12:54:08
