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
-- Table structure for table `DocumentType`
--

DROP TABLE IF EXISTS `DocumentType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocumentType` (
  `DocTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortType` varchar(32) DEFAULT NULL,
  `LongType` varchar(255) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `NextDocNumber` int(11) DEFAULT NULL,
  PRIMARY KEY (`DocTypeID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentType`
--

LOCK TABLES `DocumentType` WRITE;
/*!40000 ALTER TABLE `DocumentType` DISABLE KEYS */;
INSERT INTO `DocumentType` VALUES (1,'C - Contractual or procurement','Contractual or procurement related documents such as RFPs, source selection reports, SOWs, invoices, and all correspondence with contractors','2019-12-23 19:59:25',394),(2,'D - Drawings','Engineering Drawings, CAD outputs','2019-12-17 15:54:32',631),(4,'E - Engineering documents','Engineering documents such as material lists, specifications, documents submitted to internal PDRs, parts lists, DCNs and process travelers','2019-12-23 19:40:49',400),(5,'G - Presentations (eg Graphics)','Viewgraphs for presentations, photos, multimedia, sketches, etc','2019-12-30 20:50:59',2390),(6,'L - Letters and Memos','General correspondence (letters, memos, faxes) that do not belong in another category','2019-12-19 23:33:07',520),(7,'M - Management or Policy','Policy or management documents such as the Project Management Plan or Publication Policy','2019-12-19 22:24:37',209),(8,'P - Publications','Formal physics or technical notes intended for publication and reviewed by a committee; student theses','2019-12-27 00:40:23',396),(9,'S - Serial numbers','Serial Numbers for LIGO Equipment','2019-12-05 01:20:10',832),(10,'T - Technical notes','Technical notes used internally or released but not intended for publication and not considered reviewed','2019-12-24 23:44:09',906),(11,'F - Forms and Templates','Forms and Templates','2019-11-13 23:00:26',16),(12,'Q - Quality Assurance documents','Quality Assurance documents','2019-12-23 20:54:03',29),(13,'X - Safety Incident Reports','Safety Incident Reports','2019-11-08 21:42:34',51),(14,'R - Operations Change Requests','Operations Change Order Requests','2019-12-18 00:34:21',92),(15,'A - Acquisitions','Property Acquisitions','2019-12-19 19:22:19',485);
/*!40000 ALTER TABLE `DocumentType` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01 22:07:13
