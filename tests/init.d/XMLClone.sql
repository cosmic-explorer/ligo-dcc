INSERT INTO `Document` (`DocumentID`, `RequesterID`, `RequestDate`, `TimeStamp`, `DocHash`, `Alias`) 
       VALUES (164724,262,'2020-12-09 13:06:06','2020-12-09 21:06:06','1607547908-873619','G2000007');
INSERT INTO `DocumentRevision` (`DocRevID`, `DocumentID`, `SubmitterID`, `DocumentTitle`, `PublicationInfo`, `VersionNumber`, `Abstract`, `RevisionDate`, `TimeStamp`, `Obsolete`, `Keywords`, `Note`, `Demanaged`, `DocTypeID`, `QAcheck`, `Migrated`, `ParallelSignoff`) 
       VALUES (476869,164724,262,'Testing Parallel Signoff','',0,'','2020-12-09 13:06:06','2020-12-09 21:06:06',0,'','',NULL,5,0,0,1);
INSERT INTO `Signoff` (`SignoffID`, `DocRevID`, `Note`, `TimeStamp`) 
       VALUES (27734,476869,NULL,'2020-12-09 21:06:06'),
              (27735,476869,NULL,'2020-12-09 21:06:06'),
              (27736,476869,NULL,'2020-12-09 21:06:06');


