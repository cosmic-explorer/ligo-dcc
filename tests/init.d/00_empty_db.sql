-- MariaDB dump 10.17  Distrib 10.5.5-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: dcc_docdb
-- ------------------------------------------------------
-- Server version	10.4.17-MariaDB-log
--
-- Table structure for table `Author`
--
DROP TABLE IF EXISTS `Author`;
CREATE TABLE `Author` (
  `AuthorID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) NOT NULL,
  `MiddleInitials` varchar(16) DEFAULT NULL,
  `LastName` varchar(100) NOT NULL,
  `InstitutionID` int(11) NOT NULL DEFAULT 0,
  `Active` int(11) DEFAULT 1,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `AuthorAbbr` varchar(10) DEFAULT NULL COMMENT 'Used in the Old DCC',
  `FullAuthorName` varchar(256) DEFAULT NULL COMMENT 'Used in the Old DCC',
  PRIMARY KEY (`AuthorID`),
  KEY `Name` (`LastName`)
) ENGINE=InnoDB AUTO_INCREMENT=8136 DEFAULT CHARSET=latin1;
--
-- Table structure for table `AuthorGroupDefinition`
--
DROP TABLE IF EXISTS `AuthorGroupDefinition`;
CREATE TABLE `AuthorGroupDefinition` (
  `AuthorGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupName` varchar(32) NOT NULL,
  `Description` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`AuthorGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
--
-- Table structure for table `AuthorGroupList`
--
DROP TABLE IF EXISTS `AuthorGroupList`;
CREATE TABLE `AuthorGroupList` (
  `AuthorGroupListID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupID` int(11) NOT NULL,
  `AuthorID` int(11) NOT NULL,
  PRIMARY KEY (`AuthorGroupListID`)
) ENGINE=InnoDB AUTO_INCREMENT=1805 DEFAULT CHARSET=latin1;
--
-- Table structure for table `AuthorHint`
--
DROP TABLE IF EXISTS `AuthorHint`;
CREATE TABLE `AuthorHint` (
  `AuthorHintID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionTalkID` int(11) DEFAULT NULL,
  `AuthorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`AuthorHintID`),
  KEY `SessionTalkID` (`SessionTalkID`)
) ENGINE=InnoDB AUTO_INCREMENT=22409 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Conference`
--
DROP TABLE IF EXISTS `Conference`;
CREATE TABLE `Conference` (
  `ConferenceID` int(11) NOT NULL AUTO_INCREMENT,
  `Location` varchar(64) NOT NULL DEFAULT '',
  `URL` varchar(240) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Title` varchar(128) DEFAULT NULL,
  `Preamble` text DEFAULT NULL,
  `Epilogue` text DEFAULT NULL,
  `ShowAllTalks` int(11) DEFAULT NULL,
  `EventGroupID` int(11) DEFAULT NULL,
  `LongDescription` text DEFAULT NULL,
  `AltLocation` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ConferenceID`),
  KEY `StartDate` (`StartDate`),
  KEY `EndDate` (`EndDate`)
) ENGINE=InnoDB AUTO_INCREMENT=1056 DEFAULT CHARSET=latin1;
--
-- Table structure for table `ConfigSetting`
--
DROP TABLE IF EXISTS `ConfigSetting`;
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
  `Description` text DEFAULT NULL,
  `Constrained` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ConfigSettingID`),
  KEY `ConfigGroup` (`ConfigGroup`),
  KEY `Sub1Group` (`Sub1Group`),
  KEY `ForeignID` (`ForeignID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
--
-- Table structure for table `ConfigValue`
--
DROP TABLE IF EXISTS `ConfigValue`;
CREATE TABLE `ConfigValue` (
  `ConfigValueID` int(11) NOT NULL AUTO_INCREMENT,
  `ConfigSettingID` int(11) DEFAULT NULL,
  `Value` varchar(64) DEFAULT NULL,
  `Description` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ConfigValueID`),
  KEY `ConfigSettingID` (`ConfigSettingID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocXRef`
--
DROP TABLE IF EXISTS `DocXRef`;
CREATE TABLE `DocXRef` (
  `DocXRefID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `DocumentID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Version` int(11) DEFAULT NULL,
  `Project` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`DocXRefID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `DocumentID` (`DocumentID`)
) ENGINE=InnoDB AUTO_INCREMENT=680361 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Document`
--
DROP TABLE IF EXISTS `Document`;
CREATE TABLE `Document` (
  `DocumentID` int(11) NOT NULL AUTO_INCREMENT,
  `RequesterID` int(11) NOT NULL DEFAULT 0,
  `RequestDate` datetime DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `DocHash` char(32) DEFAULT NULL,
  `Alias` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`DocumentID`),
  KEY `Requester` (`RequesterID`),
  KEY `Alias` (`Alias`)
) ENGINE=InnoDB AUTO_INCREMENT=164740 DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocumentFile`
--
DROP TABLE IF EXISTS `DocumentFile`;
CREATE TABLE `DocumentFile` (
  `DocFileID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT 0,
  `FileName` varchar(255) NOT NULL DEFAULT '',
  `Date` datetime DEFAULT NULL,
  `RootFile` tinyint(4) DEFAULT 1,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Description` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`DocFileID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=792561 DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocumentReview`
--
DROP TABLE IF EXISTS `DocumentReview`;
CREATE TABLE `DocumentReview` (
  `DocReviewID` int(11) NOT NULL AUTO_INCREMENT,
  `DocumentID` int(11) NOT NULL,
  `VersionNumber` int(11) NOT NULL,
  `ReviewState` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0=NOT_SUBMITTED; 1=RECEIVED; 2=UNDER_REVIEW; 3=ACCEPTED; 4= WITHDRAWN',
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Obsolete` tinyint(4) DEFAULT 0,
  `EmployeeNumber` int(11) NOT NULL COMMENT 'Actor',
  PRIMARY KEY (`DocReviewID`)
) ENGINE=InnoDB AUTO_INCREMENT=10453 DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocumentRevision`
--
DROP TABLE IF EXISTS `DocumentRevision`;
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
) ENGINE=InnoDB AUTO_INCREMENT=476887 DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocumentType`
--
DROP TABLE IF EXISTS `DocumentType`;
CREATE TABLE `DocumentType` (
  `DocTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortType` varchar(32) DEFAULT NULL,
  `LongType` varchar(255) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `NextDocNumber` int(11) DEFAULT NULL,
  PRIMARY KEY (`DocTypeID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
--
-- Table structure for table `DocumentTypeSecurity`
--
DROP TABLE IF EXISTS `DocumentTypeSecurity`;
CREATE TABLE `DocumentTypeSecurity` (
  `DocTypeSecID` int(11) NOT NULL AUTO_INCREMENT,
  `DocTypeID` int(11) NOT NULL,
  `GroupID` int(11) NOT NULL,
  `IncludeType` int(11) DEFAULT 1 COMMENT '0 = exclude, 1 = include',
  PRIMARY KEY (`DocTypeSecID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
--
-- Table structure for table `EmailUser`
--
DROP TABLE IF EXISTS `EmailUser`;
CREATE TABLE `EmailUser` (
  `EmailUserID` int(11) NOT NULL AUTO_INCREMENT,
  `Username` char(255) NOT NULL,
  `Password` char(32) NOT NULL DEFAULT '',
  `Name` char(255) NOT NULL,
  `EmailAddress` char(255) NOT NULL,
  `PreferHTML` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `CanSign` int(11) NOT NULL DEFAULT 0,
  `Verified` int(11) NOT NULL DEFAULT 0,
  `AuthorID` int(11) NOT NULL DEFAULT 0,
  `EmployeeNumber` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=4667 DEFAULT CHARSET=latin1;
--
-- Table structure for table `EventGroup`
--
DROP TABLE IF EXISTS `EventGroup`;
CREATE TABLE `EventGroup` (
  `EventGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) NOT NULL DEFAULT '',
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`EventGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
--
-- Table structure for table `EventTopic`
--
DROP TABLE IF EXISTS `EventTopic`;
CREATE TABLE `EventTopic` (
  `EventTopicID` int(11) NOT NULL AUTO_INCREMENT,
  `TopicID` int(11) NOT NULL DEFAULT 0,
  `EventID` int(11) NOT NULL DEFAULT 0,
  `SessionID` int(11) NOT NULL DEFAULT 0,
  `SessionSeparatorID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`EventTopicID`),
  KEY `Topic` (`TopicID`),
  KEY `Event` (`EventID`),
  KEY `Session` (`SessionID`),
  KEY `SepKey` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=23771 DEFAULT CHARSET=latin1;
--
-- Table structure for table `ExternalDocDB`
--
DROP TABLE IF EXISTS `ExternalDocDB`;
CREATE TABLE `ExternalDocDB` (
  `ExternalDocDBID` int(11) NOT NULL AUTO_INCREMENT,
  `Project` varchar(32) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `PublicURL` varchar(255) DEFAULT NULL,
  `PrivateURL` varchar(255) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ExternalDocDBID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
--
-- Table structure for table `GroupHierarchy`
--
DROP TABLE IF EXISTS `GroupHierarchy`;
CREATE TABLE `GroupHierarchy` (
  `HierarchyID` int(11) NOT NULL AUTO_INCREMENT,
  `ChildID` int(11) NOT NULL DEFAULT 0,
  `ParentID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`HierarchyID`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Institution`
--
DROP TABLE IF EXISTS `Institution`;
CREATE TABLE `Institution` (
  `InstitutionID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortName` varchar(40) NOT NULL DEFAULT '',
  `LongName` varchar(80) NOT NULL DEFAULT '',
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`InstitutionID`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Journal`
--
DROP TABLE IF EXISTS `Journal`;
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
--
-- Table structure for table `Keyword`
--
DROP TABLE IF EXISTS `Keyword`;
CREATE TABLE `Keyword` (
  `KeywordID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) DEFAULT NULL,
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`KeywordID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
--
-- Table structure for table `KeywordGroup`
--
DROP TABLE IF EXISTS `KeywordGroup`;
CREATE TABLE `KeywordGroup` (
  `KeywordGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(32) DEFAULT NULL,
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`KeywordGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
--
-- Table structure for table `KeywordGrouping`
--
DROP TABLE IF EXISTS `KeywordGrouping`;
CREATE TABLE `KeywordGrouping` (
  `KeywordGroupingID` int(11) NOT NULL AUTO_INCREMENT,
  `KeywordGroupID` int(11) DEFAULT NULL,
  `KeywordID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`KeywordGroupingID`),
  KEY `KeywordID` (`KeywordID`),
  KEY `KeywordGroupID` (`KeywordGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
--
-- Table structure for table `MeetingModify`
--
DROP TABLE IF EXISTS `MeetingModify`;
CREATE TABLE `MeetingModify` (
  `MeetingModifyID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`MeetingModifyID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=10140 DEFAULT CHARSET=latin1;
--
-- Table structure for table `MeetingOrder`
--
DROP TABLE IF EXISTS `MeetingOrder`;
CREATE TABLE `MeetingOrder` (
  `MeetingOrderID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionOrder` int(11) DEFAULT NULL,
  `SessionID` int(11) DEFAULT NULL,
  `SessionSeparatorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`MeetingOrderID`),
  KEY `SessionID` (`SessionID`),
  KEY `SessionSeparatorID` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=4964 DEFAULT CHARSET=latin1;
--
-- Table structure for table `MeetingSecurity`
--
DROP TABLE IF EXISTS `MeetingSecurity`;
CREATE TABLE `MeetingSecurity` (
  `MeetingSecurityID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`MeetingSecurityID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=11064 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Moderator`
--
DROP TABLE IF EXISTS `Moderator`;
CREATE TABLE `Moderator` (
  `ModeratorID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorID` int(11) NOT NULL DEFAULT 0,
  `EventID` int(11) NOT NULL DEFAULT 0,
  `SessionID` int(11) NOT NULL DEFAULT 0,
  `SessionSeparatorID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ModeratorID`),
  KEY `Author` (`AuthorID`),
  KEY `Event` (`EventID`),
  KEY `Session` (`SessionID`),
  KEY `SepKey` (`SessionSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=28123 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RemoteUser`
--
DROP TABLE IF EXISTS `RemoteUser`;
CREATE TABLE `RemoteUser` (
  `RemoteUserID` int(11) NOT NULL AUTO_INCREMENT,
  `RemoteUserName` char(255) NOT NULL,
  `EmailUserID` int(11) NOT NULL DEFAULT 0,
  `EmailAddress` char(255) NOT NULL,
  PRIMARY KEY (`RemoteUserID`),
  KEY `Name` (`RemoteUserName`)
) ENGINE=InnoDB AUTO_INCREMENT=4650 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionAuthor`
--
DROP TABLE IF EXISTS `RevisionAuthor`;
CREATE TABLE `RevisionAuthor` (
  `RevAuthorID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT 0,
  `AuthorID` int(11) NOT NULL DEFAULT 0,
  `AuthorOrder` int(11) DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`RevAuthorID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `AuthorID` (`AuthorID`)
) ENGINE=InnoDB AUTO_INCREMENT=927881 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionAuthorGroup`
--
DROP TABLE IF EXISTS `RevisionAuthorGroup`;
CREATE TABLE `RevisionAuthorGroup` (
  `RevAuthorGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `AuthorGroupID` int(11) NOT NULL,
  `DocRevID` int(11) NOT NULL,
  PRIMARY KEY (`RevAuthorGroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=21578 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionEvent`
--
DROP TABLE IF EXISTS `RevisionEvent`;
CREATE TABLE `RevisionEvent` (
  `RevEventID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT 0,
  `ConferenceID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`RevEventID`),
  KEY `MinorTopicID` (`ConferenceID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=68676 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionModify`
--
DROP TABLE IF EXISTS `RevisionModify`;
CREATE TABLE `RevisionModify` (
  `RevModifyID` int(11) NOT NULL AUTO_INCREMENT,
  `GroupID` int(11) DEFAULT NULL,
  `DocRevID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`RevModifyID`),
  KEY `GroupID` (`GroupID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=764752 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionReference`
--
DROP TABLE IF EXISTS `RevisionReference`;
CREATE TABLE `RevisionReference` (
  `ReferenceID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `JournalID` int(11) DEFAULT NULL,
  `Volume` char(32) DEFAULT NULL,
  `Page` char(32) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ReferenceID`),
  KEY `JournalID` (`JournalID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=507 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionSecurity`
--
DROP TABLE IF EXISTS `RevisionSecurity`;
CREATE TABLE `RevisionSecurity` (
  `RevSecurityID` int(11) NOT NULL AUTO_INCREMENT,
  `GroupID` int(11) NOT NULL DEFAULT 0,
  `DocRevID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`RevSecurityID`),
  KEY `Grp` (`GroupID`),
  KEY `Revision` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=765338 DEFAULT CHARSET=latin1;
--
-- Table structure for table `RevisionTopic`
--
DROP TABLE IF EXISTS `RevisionTopic`;
CREATE TABLE `RevisionTopic` (
  `RevTopicID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `TopicID` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`RevTopicID`),
  KEY `DocRevID` (`DocRevID`),
  KEY `TopicID` (`TopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=753555 DEFAULT CHARSET=latin1;
--
-- Table structure for table `SecurityGroup`
--
DROP TABLE IF EXISTS `SecurityGroup`;
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
--
-- Table structure for table `Session`
--
DROP TABLE IF EXISTS `Session`;
CREATE TABLE `Session` (
  `SessionID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Description` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Location` varchar(128) DEFAULT NULL,
  `AltLocation` varchar(255) DEFAULT NULL,
  `ShowAllTalks` int(11) DEFAULT 0,
  PRIMARY KEY (`SessionID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=4894 DEFAULT CHARSET=latin1;
--
-- Table structure for table `SessionOrder`
--
DROP TABLE IF EXISTS `SessionOrder`;
CREATE TABLE `SessionOrder` (
  `SessionOrderID` int(11) NOT NULL AUTO_INCREMENT,
  `TalkOrder` int(11) DEFAULT NULL,
  `SessionTalkID` int(11) DEFAULT NULL,
  `TalkSeparatorID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`SessionOrderID`),
  KEY `SessionTalkID` (`SessionTalkID`),
  KEY `TalkSeparatorID` (`TalkSeparatorID`)
) ENGINE=InnoDB AUTO_INCREMENT=16691 DEFAULT CHARSET=latin1;
--
-- Table structure for table `SessionSeparator`
--
DROP TABLE IF EXISTS `SessionSeparator`;
CREATE TABLE `SessionSeparator` (
  `SessionSeparatorID` int(11) NOT NULL AUTO_INCREMENT,
  `ConferenceID` int(11) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Description` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Location` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`SessionSeparatorID`),
  KEY `ConferenceID` (`ConferenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=latin1;
--
-- Table structure for table `SessionTalk`
--
DROP TABLE IF EXISTS `SessionTalk`;
CREATE TABLE `SessionTalk` (
  `SessionTalkID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionID` int(11) DEFAULT NULL,
  `DocumentID` int(11) DEFAULT NULL,
  `Confirmed` int(11) DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `HintTitle` varchar(128) DEFAULT NULL,
  `Note` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`SessionTalkID`),
  KEY `SessionID` (`SessionID`),
  KEY `DocumentID` (`DocumentID`)
) ENGINE=InnoDB AUTO_INCREMENT=16386 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Signature`
--
DROP TABLE IF EXISTS `Signature`;
CREATE TABLE `Signature` (
  `SignatureID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `SignoffID` int(11) DEFAULT NULL,
  `Note` text DEFAULT NULL,
  `Signed` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`SignatureID`),
  KEY `EmailUserID` (`EmailUserID`),
  KEY `SignoffID` (`SignoffID`)
) ENGINE=InnoDB AUTO_INCREMENT=27769 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Signoff`
--
DROP TABLE IF EXISTS `Signoff`;
CREATE TABLE `Signoff` (
  `SignoffID` int(11) NOT NULL AUTO_INCREMENT,
  `DocRevID` int(11) DEFAULT NULL,
  `Note` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`SignoffID`),
  KEY `DocRevID` (`DocRevID`)
) ENGINE=InnoDB AUTO_INCREMENT=27769 DEFAULT CHARSET=latin1;
--
-- Table structure for table `SignoffDependency`
--
DROP TABLE IF EXISTS `SignoffDependency`;
CREATE TABLE `SignoffDependency` (
  `SignoffDependencyID` int(11) NOT NULL AUTO_INCREMENT,
  `SignoffID` int(11) DEFAULT NULL,
  `PreSignoffID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`SignoffDependencyID`),
  KEY `SignoffID` (`SignoffID`),
  KEY `PreSignoffID` (`PreSignoffID`)
) ENGINE=InnoDB AUTO_INCREMENT=27769 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Suppress`
--
DROP TABLE IF EXISTS `Suppress`;
CREATE TABLE `Suppress` (
  `SuppressID` int(11) NOT NULL AUTO_INCREMENT,
  `SecurityGroupID` int(11) NOT NULL DEFAULT 0,
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
--
-- Table structure for table `TalkSeparator`
--
DROP TABLE IF EXISTS `TalkSeparator`;
CREATE TABLE `TalkSeparator` (
  `TalkSeparatorID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionID` int(11) DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `Note` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`TalkSeparatorID`),
  KEY `SessionID` (`SessionID`)
) ENGINE=InnoDB AUTO_INCREMENT=286 DEFAULT CHARSET=latin1;
--
-- Table structure for table `Topic`
--
DROP TABLE IF EXISTS `Topic`;
CREATE TABLE `Topic` (
  `TopicID` int(11) NOT NULL AUTO_INCREMENT,
  `ShortDescription` varchar(64) DEFAULT '',
  `LongDescription` text DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`TopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=latin1;
--
-- Table structure for table `TopicHierarchy`
--
DROP TABLE IF EXISTS `TopicHierarchy`;
CREATE TABLE `TopicHierarchy` (
  `TopicHierarchyID` int(11) NOT NULL AUTO_INCREMENT,
  `TopicID` int(11) NOT NULL DEFAULT 0,
  `ParentTopicID` int(11) NOT NULL DEFAULT 0,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`TopicHierarchyID`),
  KEY `Topic` (`TopicID`),
  KEY `Parent` (`ParentTopicID`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=latin1;
--
-- Table structure for table `TopicHint`
--
DROP TABLE IF EXISTS `TopicHint`;
CREATE TABLE `TopicHint` (
  `TopicHintID` int(11) NOT NULL AUTO_INCREMENT,
  `SessionTalkID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `TopicID` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`TopicHintID`),
  KEY `SessionTalkID` (`SessionTalkID`)
) ENGINE=InnoDB AUTO_INCREMENT=6539 DEFAULT CHARSET=latin1;
--
-- Table structure for table `UsersGroup`
--
DROP TABLE IF EXISTS `UsersGroup`;
CREATE TABLE `UsersGroup` (
  `UsersGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUserID` int(11) DEFAULT NULL,
  `GroupID` int(11) DEFAULT NULL,
  `TimeStamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`UsersGroupID`),
  KEY `EmailUserID` (`EmailUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=10731 DEFAULT CHARSET=latin1;
-- Dump completed on 2020-12-09 22:06:05
