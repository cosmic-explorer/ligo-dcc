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
-- Table structure for table `RemoteUser`
--

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
(1,'stuart.anderson@LIGO.ORG',1,'stuart.anderson@LIGO.ORG'),
(2,'melody.araya@LIGO.ORG',2,'melody.araya@LIGO.ORG'),
(3,'veronica.kondrashov@LIGO.ORG',3,'veronica.kondrashov@LIGO.ORG'),
(4,'philippe.grassia@LIGO.ORG',4,'philippe.grassia@LIGO.ORG'),
(5,'alveera.khan@LIGO.ORG',5,'alveera.khan@LIGO.ORG'),
(6,'pgrassia',6,'pgrassia@caltech.edu');

/*!40000 ALTER TABLE `RemoteUser` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01  1:27:34
