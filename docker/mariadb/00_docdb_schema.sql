-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: dcc_docdb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Author`
--

DROP TABLE IF EXISTS `Author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Author` (
  `AuthorID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) NOT NULL,
  `MiddleInitials` varchar(16) DEFAULT NULL,
  `LastName` varchar(100) NOT NULL,
  `InstitutionID` int(11) NOT NULL DEFAULT '0',
  `Active` int(11) DEFAULT '1',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `AuthorAbbr` varchar(10) DEFAULT NULL COMMENT 'Used in the Old DCC',
  `FullAuthorName` varchar(256) DEFAULT NULL COMMENT 'Used in the Old DCC',
  PRIMARY KEY (`AuthorID`),
  KEY `Name` (`LastName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Author`
--

LOCK TABLES `Author` WRITE;
/*!40000 ALTER TABLE `Author` DISABLE KEYS */;
/*!40000 ALTER TABLE `Author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AuthorGroupDefinition`
--

DROP TABLE IF EXISTS `AuthorGroupDefinition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AuthorGroupDefinition` (
  `AuthorGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupName` varchar(32) NOT NULL,
  `Description` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`AuthorGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuthorGroupDefinition`
--

LOCK TABLES `AuthorGroupDefinition` WRITE;
/*!40000 ALTER TABLE `AuthorGroupDefinition` DISABLE KEYS */;
/*!40000 ALTER TABLE `AuthorGroupDefinition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AuthorGroupList`
--

DROP TABLE IF EXISTS `AuthorGroupList`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AuthorGroupList` (
  `AuthorGroupListID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupID` int(11) NOT NULL,
  `AuthorID` int(11) NOT NULL,
  PRIMARY KEY (`AuthorGroupListID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuthorGroupList`
--

LOCK TABLES `AuthorGroupList` WRITE;
/*!40000 ALTER TABLE `AuthorGroupList` DISABLE KEYS */;
/*!40000 ALTER TABLE `AuthorGroupList` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AuthorHint`
--

DROP TABLE IF EXISTS `AuthorHint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AuthorHint` (
  `AuthorHintID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionTalkID` int(11) DEFAULT NULL,
  `AuthorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`AuthorHintID`),
  KEY `SessionTalkID` (`SessionTalkID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuthorHint`
--

LOCK TABLES `AuthorHint` WRITE;
/*!40000 ALTER TABLE `AuthorHint` DISABLE KEYS */;
/*!40000 ALTER TABLE `AuthorHint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Conference`
--

DROP TABLE IF EXISTS `Conference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Conference` (
  `ConferenceID` int(11) NOT NULL AUTO_INCREMENT,
  `Location` varchar(64) NOT NULL DEFAULT '',
  `URL` varchar(240) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Title` varchar(128) DEFAULT NULL,
  `Preamble` text,
  `Epilogue` text,
  `ShowAllTalks` int(11) DEFAULT NULL,
  `EventGroupID` int(11) DEFAULT NULL,
  `LongDescription` text,
  `AltLocation` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ConferenceID`),
  KEY `StartDate` (`StartDate`),
  KEY `EndDate` (`EndDate`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Conference`
--

LOCK TABLES `Conference` WRITE;
/*!40000 ALTER TABLE `Conference` DISABLE KEYS */;
/*!40000 ALTER TABLE `Conference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ConfigSetting`
--

DROP TABLE IF EXISTS `ConfigSetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ConfigSetting` (
  `ConfigSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `Project` varchar(32) DEFAULT NULL,
  `ConfigGroup` varchar(64) DEFAULT NULL,
  `Sub1Group` varchar(64) DEFAULT NULL,
  `Sub2Group` varchar(64) DEFAULT NULL,
  `Sub3Group` varchar(64) DEFAULT NULL,
  `Sub4Group` varchar(64) DEFAULT NULL,
  `ForeignID` int(11) DEFAULT NULL,
  `Value` varchar(64) DEFAULT NULL,
  `Sub1Value` varchar(64) DEFAULT NULL,
  `Sub2Value` varchar(64) DEFAULT NULL,
  `Sub3Value` varchar(64) DEFAULT NULL,
  `Sub4Value` varchar(64) DEFAULT NULL,
  `Sub5Value` varchar(64) DEFAULT NULL,
  `Description` text,
  `Constrained` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ConfigSettingID`),
  KEY `ConfigGroup` (`ConfigGroup`),
  KEY `Sub1Group` (`Sub1Group`),
  KEY `ForeignID` (`ForeignID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ConfigSetting`
--

LOCK TABLES `ConfigSetting` WRITE;
/*!40000 ALTER TABLE `ConfigSetting` DISABLE KEYS */;
/*!40000 ALTER TABLE `ConfigSetting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ConfigValue`
--

DROP TABLE IF EXISTS `ConfigValue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ConfigValue` (
  `ConfigValueID` int(11) NOT NULL AUTO_INCREMENT,
  `ConfigSettingID` int(11) DEFAULT NULL,
  `Value` varchar(64) DEFAULT NULL,
  `Description` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ConfigValueID`),
  KEY `ConfigSettingID` (`ConfigSettingID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ConfigValue`
--

LOCK TABLES `ConfigValue` WRITE;
/*!40000 ALTER TABLE `ConfigValue` DISABLE KEYS */;
/*!40000 ALTER TABLE `ConfigValue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocXRef`
--

DROP TABLE IF EXISTS `DocXRef`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocXRef` (
  `DocXRefID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `DocumentID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Version` int(11) DEFAULT NULL,
  `Project` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`DocXRefID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `DocumentID` (`DocumentID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocXRef`
--

LOCK TABLES `DocXRef` WRITE;
/*!40000 ALTER TABLE `DocXRef` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocXRef` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Document`
--

DROP TABLE IF EXISTS `Document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Document` (
  `DocumentID` int(11) NOT NULL AUTO_INCREMENT,
  `RequesterID` int(11) NOT NULL DEFAULT '0',
  `RequestDate` datetime DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DocHash` char(32) DEFAULT NULL,
  `Alias` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`DocumentID`),
  KEY `Requester` (`RequesterID`),
  KEY `Alias` (`Alias`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Document`
--

LOCK TABLES `Document` WRITE;
/*!40000 ALTER TABLE `Document` DISABLE KEYS */;
/*!40000 ALTER TABLE `Document` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocumentFile`
--

DROP TABLE IF EXISTS `DocumentFile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocumentFile` (
  `DocFileID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT '0',
  `FileName` varchar(255) NOT NULL DEFAULT '',
  `Date` datetime DEFAULT NULL,
  `RootFile` tinyint(4) DEFAULT '1',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Description` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`DocFileID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentFile`
--

LOCK TABLES `DocumentFile` WRITE;
/*!40000 ALTER TABLE `DocumentFile` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentFile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocumentReview`
--

DROP TABLE IF EXISTS `DocumentReview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocumentReview` (
  `DocReviewID` int(11) NOT NULL AUTO_INCREMENT,
  `DocumentID` int(11) NOT NULL,
  `VersionNumber` int(11) NOT NULL,
  `ReviewState` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0=NOT_SUBMITTED; 1=RECEIVED; 2=UNDER_REVIEW; 3=ACCEPTED; 4= WITHDRAWN',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Obsolete` tinyint(4) DEFAULT '0',
  `EmployeeNumber` int(11) NOT NULL COMMENT 'Actor',
  PRIMARY KEY (`DocReviewID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentReview`
--

LOCK TABLES `DocumentReview` WRITE;
/*!40000 ALTER TABLE `DocumentReview` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentReview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocumentRevision`
--

DROP TABLE IF EXISTS `DocumentRevision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocumentRevision` (
  `DocRevID` int(11) NOT NULL AUTO_INCREMENT,
  `DocumentID` int(11) NOT NULL DEFAULT 0,
  `SubmitterID` int(11) NOT NULL DEFAULT 0,
  `DocumentTitle` varchar(255) NOT NULL DEFAULT '',
  `PublicationInfo` text DEFAULT NULL,
  `VersionNumber` int(11) NOT NULL DEFAULT 0,
  `Abstract` text DEFAULT NULL,
  `RevisionDate` datetime DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Obsolete` tinyint(4) DEFAULT 0,
  `Keywords` varchar(400) DEFAULT NULL,
  `Note` text DEFAULT NULL,
  `Demanaged` int(11) DEFAULT NULL,
  `DocTypeID` int(11) DEFAULT NULL,
  `QAcheck` tinyint(4) DEFAULT 0 COMMENT 'flag when QA verifies rev',
  `Migrated` int(11) DEFAULT 0 COMMENT '0=not_migrated 1=created 2=updated',
  `ParallelSignoff` int(11) unsigned DEFAULT 0,
  PRIMARY KEY (`DocRevID`),
  KEY `DocumentID` (`DocumentID`),
  KEY `DocumentTitle` (`DocumentTitle`),
  KEY `VersionNumber` (`VersionNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentRevision`
--

LOCK TABLES `DocumentRevision` WRITE;
/*!40000 ALTER TABLE `DocumentRevision` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentRevision` ENABLE KEYS */;
UNLOCK TABLES;

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
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `NextDocNumber` int(11) DEFAULT NULL,
  PRIMARY KEY (`DocTypeID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentType`
--

LOCK TABLES `DocumentType` WRITE;
/*!40000 ALTER TABLE `DocumentType` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocumentTypeSecurity`
--

DROP TABLE IF EXISTS `DocumentTypeSecurity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DocumentTypeSecurity` (
  `DocTypeSecID` int(11) NOT NULL AUTO_INCREMENT,
  `DocTypeID` int(11) NOT NULL,
  `GroupID` int(11) NOT NULL,
  `IncludeType` int(11) DEFAULT '1' COMMENT '0 = exclude, 1 = include',
  PRIMARY KEY (`DocTypeSecID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentTypeSecurity`
--

LOCK TABLES `DocumentTypeSecurity` WRITE;
/*!40000 ALTER TABLE `DocumentTypeSecurity` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentTypeSecurity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EmailUser`
--

DROP TABLE IF EXISTS `EmailUser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EmailUser` (
  `EmailUserID` int(11) NOT NULL AUTO_INCREMENT,
  `Username` char(255) NOT NULL,
  `Password` char(32) NOT NULL DEFAULT '',
  `Name` char(255) NOT NULL,
  `EmailAddress` char(255) NOT NULL,
  `PreferHTML` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CanSign` int(11) NOT NULL DEFAULT '0',
  `Verified` int(11) NOT NULL DEFAULT '0',
  `AuthorID` int(11) NOT NULL DEFAULT '0',
  `EmployeeNumber` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EmailUser`
--

LOCK TABLES `EmailUser` WRITE;
/*!40000 ALTER TABLE `EmailUser` DISABLE KEYS */;
/*!40000 ALTER TABLE `EmailUser` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EventGroup`
--

DROP TABLE IF EXISTS `EventGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EventGroup` (
  `EventGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) NOT NULL DEFAULT '',
  `LongDescription` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`EventGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EventGroup`
--

LOCK TABLES `EventGroup` WRITE;
/*!40000 ALTER TABLE `EventGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `EventGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EventTopic`
--

DROP TABLE IF EXISTS `EventTopic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EventTopic` (
  `EventTopicID` int(11) NOT NULL AUTO_INCREMENT,
  `TopicID` int(11) NOT NULL DEFAULT '0',
  `EventID` int(11) NOT NULL DEFAULT '0',
  `SessionID` int(11) NOT NULL DEFAULT '0',
  `SessionSeparatorID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`EventTopicID`),
  KEY `Topic` (`TopicID`),
  KEY `Event` (`EventID`),
  KEY `Session` (`SessionID`),
  KEY `SepKey` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EventTopic`
--

LOCK TABLES `EventTopic` WRITE;
/*!40000 ALTER TABLE `EventTopic` DISABLE KEYS */;
/*!40000 ALTER TABLE `EventTopic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ExternalDocDB`
--

DROP TABLE IF EXISTS `ExternalDocDB`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ExternalDocDB` (
  `ExternalDocDBID` int(11) NOT NULL AUTO_INCREMENT,
  `Project` varchar(32) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `PublicURL` varchar(255) DEFAULT NULL,
  `PrivateURL` varchar(255) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ExternalDocDBID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ExternalDocDB`
--

LOCK TABLES `ExternalDocDB` WRITE;
/*!40000 ALTER TABLE `ExternalDocDB` DISABLE KEYS */;
/*!40000 ALTER TABLE `ExternalDocDB` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GroupHierarchy`
--

DROP TABLE IF EXISTS `GroupHierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GroupHierarchy` (
  `HierarchyID` int(11) NOT NULL AUTO_INCREMENT,
  `ChildID` int(11) NOT NULL DEFAULT '0',
  `ParentID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`HierarchyID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GroupHierarchy`
--

LOCK TABLES `GroupHierarchy` WRITE;
/*!40000 ALTER TABLE `GroupHierarchy` DISABLE KEYS */;
/*!40000 ALTER TABLE `GroupHierarchy` ENABLE KEYS */;
UNLOCK TABLES;

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
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`InstitutionID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Institution`
--

LOCK TABLES `Institution` WRITE;
/*!40000 ALTER TABLE `Institution` DISABLE KEYS */;
/*!40000 ALTER TABLE `Institution` ENABLE KEYS */;
UNLOCK TABLES;

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
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Acronym` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`JournalID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Journal`
--

LOCK TABLES `Journal` WRITE;
/*!40000 ALTER TABLE `Journal` DISABLE KEYS */;
/*!40000 ALTER TABLE `Journal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Keyword`
--

DROP TABLE IF EXISTS `Keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Keyword` (
  `KeywordID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) DEFAULT NULL,
  `LongDescription` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`KeywordID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Keyword`
--

LOCK TABLES `Keyword` WRITE;
/*!40000 ALTER TABLE `Keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `Keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `KeywordGroup`
--

DROP TABLE IF EXISTS `KeywordGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KeywordGroup` (
  `KeywordGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) DEFAULT NULL,
  `LongDescription` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`KeywordGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `KeywordGroup`
--

LOCK TABLES `KeywordGroup` WRITE;
/*!40000 ALTER TABLE `KeywordGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `KeywordGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `KeywordGrouping`
--

DROP TABLE IF EXISTS `KeywordGrouping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KeywordGrouping` (
  `KeywordGroupingID` int(11) NOT NULL AUTO_INCREMENT,
  `KeywordGroupID` int(11) DEFAULT NULL,
  `KeywordID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`KeywordGroupingID`),
  KEY `KeywordID` (`KeywordID`),
  KEY `KeywordGroupID` (`KeywordGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `KeywordGrouping`
--

LOCK TABLES `KeywordGrouping` WRITE;
/*!40000 ALTER TABLE `KeywordGrouping` DISABLE KEYS */;
/*!40000 ALTER TABLE `KeywordGrouping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MeetingModify`
--

DROP TABLE IF EXISTS `MeetingModify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MeetingModify` (
  `MeetingModifyID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`MeetingModifyID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MeetingModify`
--

LOCK TABLES `MeetingModify` WRITE;
/*!40000 ALTER TABLE `MeetingModify` DISABLE KEYS */;
/*!40000 ALTER TABLE `MeetingModify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MeetingOrder`
--

DROP TABLE IF EXISTS `MeetingOrder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MeetingOrder` (
  `MeetingOrderID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionOrder` int(11) DEFAULT NULL,
  `SessionID` int(11) DEFAULT NULL,
  `SessionSeparatorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`MeetingOrderID`),
  KEY `SessionID` (`SessionID`),
  KEY `SessionSeparatorID` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MeetingOrder`
--

LOCK TABLES `MeetingOrder` WRITE;
/*!40000 ALTER TABLE `MeetingOrder` DISABLE KEYS */;
/*!40000 ALTER TABLE `MeetingOrder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MeetingSecurity`
--

DROP TABLE IF EXISTS `MeetingSecurity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MeetingSecurity` (
  `MeetingSecurityID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`MeetingSecurityID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MeetingSecurity`
--

LOCK TABLES `MeetingSecurity` WRITE;
/*!40000 ALTER TABLE `MeetingSecurity` DISABLE KEYS */;
/*!40000 ALTER TABLE `MeetingSecurity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Moderator`
--

DROP TABLE IF EXISTS `Moderator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Moderator` (
  `ModeratorID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorID` int(11) NOT NULL DEFAULT '0',
  `EventID` int(11) NOT NULL DEFAULT '0',
  `SessionID` int(11) NOT NULL DEFAULT '0',
  `SessionSeparatorID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ModeratorID`),
  KEY `Author` (`AuthorID`),
  KEY `Event` (`EventID`),
  KEY `Session` (`SessionID`),
  KEY `SepKey` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Moderator`
--

LOCK TABLES `Moderator` WRITE;
/*!40000 ALTER TABLE `Moderator` DISABLE KEYS */;
/*!40000 ALTER TABLE `Moderator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notification`
--

DROP TABLE IF EXISTS `Notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Notification` (
  `NotificationID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `Type` varchar(32) DEFAULT NULL,
  `ForeignID` int(11) DEFAULT NULL,
  `Period` varchar(32) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `TextKey` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`NotificationID`),
  KEY `EmailUserID` (`EmailUserID`),
  KEY `ForeignID` (`ForeignID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notification`
--

LOCK TABLES `Notification` WRITE;
/*!40000 ALTER TABLE `Notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `Notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RemoteUser`
--

DROP TABLE IF EXISTS `RemoteUser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RemoteUser` (
  `RemoteUserID` int(11) NOT NULL AUTO_INCREMENT,
  `RemoteUserName` char(255) NOT NULL,
  `EmailUserID` int(11) NOT NULL DEFAULT '0',
  `EmailAddress` char(255) NOT NULL,
  PRIMARY KEY (`RemoteUserID`),
  KEY `Name` (`RemoteUserName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RemoteUser`
--

LOCK TABLES `RemoteUser` WRITE;
/*!40000 ALTER TABLE `RemoteUser` DISABLE KEYS */;
/*!40000 ALTER TABLE `RemoteUser` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionAuthor`
--

DROP TABLE IF EXISTS `RevisionAuthor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionAuthor` (
  `RevAuthorID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT '0',
  `AuthorID` int(11) NOT NULL DEFAULT '0',
  `AuthorOrder` int(11) DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`RevAuthorID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `AuthorID` (`AuthorID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionAuthor`
--

LOCK TABLES `RevisionAuthor` WRITE;
/*!40000 ALTER TABLE `RevisionAuthor` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionAuthor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionAuthorGroup`
--

DROP TABLE IF EXISTS `RevisionAuthorGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionAuthorGroup` (
  `RevAuthorGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupID` int(11) NOT NULL,
  `DocRevID` int(11) NOT NULL,
  PRIMARY KEY (`RevAuthorGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionAuthorGroup`
--

LOCK TABLES `RevisionAuthorGroup` WRITE;
/*!40000 ALTER TABLE `RevisionAuthorGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionAuthorGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionEvent`
--

DROP TABLE IF EXISTS `RevisionEvent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionEvent` (
  `RevEventID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT '0',
  `ConferenceID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`RevEventID`),
  KEY `MinorTopicID` (`ConferenceID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionEvent`
--

LOCK TABLES `RevisionEvent` WRITE;
/*!40000 ALTER TABLE `RevisionEvent` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionEvent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionModify`
--

DROP TABLE IF EXISTS `RevisionModify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionModify` (
  `RevModifyID` int(11) NOT NULL AUTO_INCREMENT,
  `GroupID` int(11) DEFAULT NULL,
  `DocRevID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`RevModifyID`),
  KEY `GroupID` (`GroupID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionModify`
--

LOCK TABLES `RevisionModify` WRITE;
/*!40000 ALTER TABLE `RevisionModify` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionModify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionReference`
--

DROP TABLE IF EXISTS `RevisionReference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionReference` (
  `ReferenceID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `JournalID` int(11) DEFAULT NULL,
  `Volume` char(32) DEFAULT NULL,
  `Page` char(32) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReferenceID`),
  KEY `JournalID` (`JournalID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionReference`
--

LOCK TABLES `RevisionReference` WRITE;
/*!40000 ALTER TABLE `RevisionReference` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionReference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionSecurity`
--

DROP TABLE IF EXISTS `RevisionSecurity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionSecurity` (
  `RevSecurityID` int(11) NOT NULL AUTO_INCREMENT,
  `GroupID` int(11) NOT NULL DEFAULT '0',
  `DocRevID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`RevSecurityID`),
  KEY `Grp` (`GroupID`),
  KEY `Revision` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionSecurity`
--

LOCK TABLES `RevisionSecurity` WRITE;
/*!40000 ALTER TABLE `RevisionSecurity` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionSecurity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RevisionTopic`
--

DROP TABLE IF EXISTS `RevisionTopic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RevisionTopic` (
  `RevTopicID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `TopicID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`RevTopicID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `TopicID` (`TopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RevisionTopic`
--

LOCK TABLES `RevisionTopic` WRITE;
/*!40000 ALTER TABLE `RevisionTopic` DISABLE KEYS */;
/*!40000 ALTER TABLE `RevisionTopic` ENABLE KEYS */;
UNLOCK TABLES;

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
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CanCreate` int(11) DEFAULT '0',
  `CanAdminister` int(11) DEFAULT '0',
  `CanView` int(11) DEFAULT '1',
  `CanConfig` int(11) DEFAULT '0',
  `DisplayInList` int(11) NOT NULL DEFAULT '1' COMMENT '0=don''t_display 1=display 2=force_display_in_specific_list ',
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SecurityGroup`
--

LOCK TABLES `SecurityGroup` WRITE;
/*!40000 ALTER TABLE `SecurityGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `SecurityGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Session`
--

DROP TABLE IF EXISTS `Session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Session` (
  `SessionID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Description` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Location` varchar(128) DEFAULT NULL,
  `AltLocation` varchar(255) DEFAULT NULL,
  `ShowAllTalks` int(11) DEFAULT '0',
  PRIMARY KEY (`SessionID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Session`
--

LOCK TABLES `Session` WRITE;
/*!40000 ALTER TABLE `Session` DISABLE KEYS */;
/*!40000 ALTER TABLE `Session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SessionOrder`
--

DROP TABLE IF EXISTS `SessionOrder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SessionOrder` (
  `SessionOrderID` int(11) NOT NULL AUTO_INCREMENT,
  `TalkOrder` int(11) DEFAULT NULL,
  `SessionTalkID` int(11) DEFAULT NULL,
  `TalkSeparatorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`SessionOrderID`),
  KEY `SessionTalkID` (`SessionTalkID`),
  KEY `TalkSeparatorID` (`TalkSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SessionOrder`
--

LOCK TABLES `SessionOrder` WRITE;
/*!40000 ALTER TABLE `SessionOrder` DISABLE KEYS */;
/*!40000 ALTER TABLE `SessionOrder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SessionSeparator`
--

DROP TABLE IF EXISTS `SessionSeparator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SessionSeparator` (
  `SessionSeparatorID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Description` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Location` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`SessionSeparatorID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SessionSeparator`
--

LOCK TABLES `SessionSeparator` WRITE;
/*!40000 ALTER TABLE `SessionSeparator` DISABLE KEYS */;
/*!40000 ALTER TABLE `SessionSeparator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SessionTalk`
--

DROP TABLE IF EXISTS `SessionTalk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SessionTalk` (
  `SessionTalkID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionID` int(11) DEFAULT NULL,
  `DocumentID` int(11) DEFAULT NULL,
  `Confirmed` int(11) DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `HintTitle` varchar(128) DEFAULT NULL,
  `Note` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`SessionTalkID`),
  KEY `SessionID` (`SessionID`),
  KEY `DocumentID` (`DocumentID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SessionTalk`
--

LOCK TABLES `SessionTalk` WRITE;
/*!40000 ALTER TABLE `SessionTalk` DISABLE KEYS */;
/*!40000 ALTER TABLE `SessionTalk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Signature`
--

DROP TABLE IF EXISTS `Signature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Signature` (
  `SignatureID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `SignoffID` int(11) DEFAULT NULL,
  `Note` text,
  `Signed` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`SignatureID`),
  KEY `EmailUserID` (`EmailUserID`),
  KEY `SignoffID` (`SignoffID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Signature`
--

LOCK TABLES `Signature` WRITE;
/*!40000 ALTER TABLE `Signature` DISABLE KEYS */;
/*!40000 ALTER TABLE `Signature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Signoff`
--

DROP TABLE IF EXISTS `Signoff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Signoff` (
  `SignoffID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `Note` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`SignoffID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Signoff`
--

LOCK TABLES `Signoff` WRITE;
/*!40000 ALTER TABLE `Signoff` DISABLE KEYS */;
/*!40000 ALTER TABLE `Signoff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SignoffDependency`
--

DROP TABLE IF EXISTS `SignoffDependency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SignoffDependency` (
  `SignoffDependencyID` int(11) NOT NULL AUTO_INCREMENT,
  `SignoffID` int(11) DEFAULT NULL,
  `PreSignoffID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`SignoffDependencyID`),
  KEY `SignoffID` (`SignoffID`),
  KEY `PreSignoffID` (`PreSignoffID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SignoffDependency`
--

LOCK TABLES `SignoffDependency` WRITE;
/*!40000 ALTER TABLE `SignoffDependency` DISABLE KEYS */;
/*!40000 ALTER TABLE `SignoffDependency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Suppress`
--

DROP TABLE IF EXISTS `Suppress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Suppress` (
  `SuppressID` int(11) NOT NULL AUTO_INCREMENT,
  `SecurityGroupID` int(11) NOT NULL DEFAULT '0',
  `Type` varchar(32) DEFAULT NULL,
  `ForeignID` int(11) DEFAULT NULL,
  `TextKey` varchar(255) DEFAULT NULL,
  `ViewSetting` varchar(32) DEFAULT NULL,
  `ModifySetting` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`SuppressID`),
  KEY `SecurityGroup` (`SecurityGroupID`),
  KEY `Type` (`Type`),
  KEY `ForeignID` (`ForeignID`),
  KEY `TextKey` (`TextKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Suppress`
--

LOCK TABLES `Suppress` WRITE;
/*!40000 ALTER TABLE `Suppress` DISABLE KEYS */;
/*!40000 ALTER TABLE `Suppress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TalkSeparator`
--

DROP TABLE IF EXISTS `TalkSeparator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TalkSeparator` (
  `TalkSeparatorID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionID` int(11) DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Note` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TalkSeparatorID`),
  KEY `SessionID` (`SessionID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TalkSeparator`
--

LOCK TABLES `TalkSeparator` WRITE;
/*!40000 ALTER TABLE `TalkSeparator` DISABLE KEYS */;
/*!40000 ALTER TABLE `TalkSeparator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Topic`
--

DROP TABLE IF EXISTS `Topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Topic` (
  `TopicID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(64) DEFAULT '',
  `LongDescription` text,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Topic`
--

LOCK TABLES `Topic` WRITE;
/*!40000 ALTER TABLE `Topic` DISABLE KEYS */;
/*!40000 ALTER TABLE `Topic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TopicHierarchy`
--

DROP TABLE IF EXISTS `TopicHierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TopicHierarchy` (
  `TopicHierarchyID` int(11) NOT NULL AUTO_INCREMENT,
  `TopicID` int(11) NOT NULL DEFAULT '0',
  `ParentTopicID` int(11) NOT NULL DEFAULT '0',
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TopicHierarchyID`),
  KEY `Topic` (`TopicID`),
  KEY `Parent` (`ParentTopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TopicHierarchy`
--

LOCK TABLES `TopicHierarchy` WRITE;
/*!40000 ALTER TABLE `TopicHierarchy` DISABLE KEYS */;
/*!40000 ALTER TABLE `TopicHierarchy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TopicHint`
--

DROP TABLE IF EXISTS `TopicHint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TopicHint` (
  `TopicHintID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionTalkID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `TopicID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`TopicHintID`),
  KEY `SessionTalkID` (`SessionTalkID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TopicHint`
--

LOCK TABLES `TopicHint` WRITE;
/*!40000 ALTER TABLE `TopicHint` DISABLE KEYS */;
/*!40000 ALTER TABLE `TopicHint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UsersGroup`
--

DROP TABLE IF EXISTS `UsersGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UsersGroup` (
  `UsersGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`UsersGroupID`),
  KEY `EmailUserID` (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UsersGroup`
--

LOCK TABLES `UsersGroup` WRITE;
/*!40000 ALTER TABLE `UsersGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `UsersGroup` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-11-15 12:17:24
