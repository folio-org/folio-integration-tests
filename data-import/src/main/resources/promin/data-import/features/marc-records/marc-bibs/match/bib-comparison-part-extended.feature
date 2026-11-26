@parallel=false
Feature: MARC Bib matching with "Only compare part of the value" - extended

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/marc-match-comparison-part-common.feature'
    * configure retry = { count: 30, interval: 5000 }

    * def runId = epoch + randomString(5)
    * def randomDigits = function(n) { var r = ''; for (var i = 0; i < n; i++) { r += Math.floor(Math.random() * 10); } return r; }
    * def digits = epoch + randomDigits(6)
    * def NC = { comparisonPart: 'NUMERICS_ONLY' }
    * def qBeginsOclcNumerics = { qualifierType: 'BEGINS_WITH', qualifierValue: '(OCoLC)', comparisonPart: 'NUMERICS_ONLY' }

  # C1538579 - Numerics only on both sides; the incoming 010 $a starts with Devanagari digits, which
  # Numerics only strips because the digit class is ASCII-only on both the incoming and the stored side.
  @C1538579
  Scenario: Bib is updated on 010 $a with Numerics only on both sides when the incoming value contains Devanagari digits
    * def existingValue = 'a' + digits
    * def incomingValue = '१२३' + digits
    * def title = 'FAT-28498 B-15 ' + runId
    * def updatedTitle = title + ' UPDATED'

    # Steps 1-3: create the bib with the default job profile; 010 $a is "a<digits>"
    * def seeded = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#("FAT28498B15" + runId)', heading: '#(title)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }
    * call read(commonFeature + '@AssertJobLogStatus') { jobExecutionId: '#(seeded.jobExecutionId)', infoField: 'relatedInstanceInfo', expectedStatus: 'CREATED' }
    * call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seeded.instanceId)', field: '010', subfield: 'a', expectedValue: '#(existingValue)' }

    # Steps 4-5: import "१२३<digits>" with the update job profile (010, Ind 1 = *, Ind 2 = *, $a)
    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 B-15 devanagari numerics', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '010', matchSubfield: 'a', ind1: '*', ind2: '*', incomingQualifier: '#(NC)', existingQualifier: '#(NC)' }
    * def jobProfileId = profiles.jobProfileId
    * def incomingFileName = 'FAT-28498-b15-incoming-' + runId
    * call read(commonFeature + '@BuildBibFile') { controlNumber: '#("FAT28498B15" + runId)', heading: '#(updatedTitle)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }
    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.instanceId)', infoField: 'relatedInstanceInfo' }

    # Step 6: 245 $a now ends with "UPDATED"
    * call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seeded.instanceId)', field: '245', subfield: 'a', expectedValue: '#(updatedTitle)' }

  # C1505072 - 035 $a with only a "Contains" qualifier configured on both sides (no "Only compare part of the value")
  @C1505072
  Scenario: MARC Bib is updated on 035 $a with "CONTAINS" qualifier only and no comparison part
    * def profileName = 'C1505072 MARC bib 035 $a on 035 $a using a Contains qualifier only (no Only compare part of the value) - ' + runId
    * def qContains = { qualifierType: 'CONTAINS', qualifierValue: '05012' }
    # Unique digits prefix keeps the values unique per run, while the values still contain "05012"
    * def existingValue1 = '(OCoLC)' + '70050123' + digits
    * def existingValue2 = '(OCoLC)' + '70050999' + digits
    * def incomingValue = existingValue1
    # The 001 value of the generated record is turned into the (non-prefixed) 035 $a on instance creation
    * def controlNumber = 'MDC1505072C'
    * def title = 'Scenario C1505072 ' + runId
    * def updatedTitle = title + ' UPDATED'

    # Steps 1-3: Import The Create Bib File With Two 035 $a Fields Using The Default Create Job Profile
    Given def seedRes = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#(controlNumber)', heading: '#(title)', matchField: '035', matchSubfield: 'a', matchValues: ['#(existingValue1)', '#(existingValue2)'] }
    Then call read(commonFeature + '@AssertJobLogStatus') { jobExecutionId: '#(seedRes.jobExecutionId)', infoField: 'relatedInstanceInfo', expectedStatus: 'CREATED' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(existingValue1)' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(existingValue2)' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(controlNumber)' }

    # Step 4: Import The Update Bib File Using The Match Profile With Contains Qualifier Only
    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: '#(profileName)', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '035', matchSubfield: 'a', ind1: '*', ind2: '*', incomingQualifier: '#(qContains)', existingQualifier: '#(qContains)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'C1505072-update-bib-' + runId
    * def buildRes = call read(commonFeature + '@BuildBibFile') { controlNumber: '#(controlNumber)', heading: '#(updatedTitle)', matchField: '035', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given def importRes = call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match importRes.jobExecution.status == 'COMMITTED'
    # Step 5: Verify SRS and instance statuses are updated in the log entries
    And call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(importRes.jobExecutionId)', externalId: '#(seedRes.instanceId)', infoField: 'relatedInstanceInfo' }
    # Step 6: Verify the 245 $a title now ends with "UPDATED"
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '245', subfield: 'a', expectedValue: '#(updatedTitle)' }

  # C1505073 - 035 $a with both a "Begins with" qualifier and Numerics only configured on both sides
  @C1505073
  Scenario: MARC Bib is updated on 035 $a with "BEGINS_WITH" qualifier and Numerics only on both sides
    * def profileName = 'C1505073 MARC bib 035 $a on 035 $a with both a Begins with qualifier and Numerics only configured - ' + runId
    * def controlNumber = 'C1505073' + runId
    * def otherDigits = epoch + randomDigits(6)
    * def existingValue1 = '(OCoLC)ocn' + digits
    * def existingValue2 = '(OCoLC)ocm' + otherDigits
    * def incomingValue = '(OCoLC)ocm' + digits
    # The FOLIO system normalizes 035 $a values starting with (OCoLC) on instance creation: the ocn/ocm prefixes are removed
    * def normalizedValue1 = '(OCoLC)' + digits
    * def normalizedValue2 = '(OCoLC)' + otherDigits
    * def title = 'Scenario C1505073 ' + runId
    * def updatedTitle = title + ' UPDATED'

    # Steps 1-3: Import MARC-Bib record with two 035 $a fields using the Default Create Job Profile
    Given def seedRes = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#(controlNumber)', heading: '#(title)', matchField: '035', matchSubfield: 'a', matchValues: ['#(existingValue1)', '#(existingValue2)'] }
    Then call read(commonFeature + '@AssertJobLogStatus') { jobExecutionId: '#(seedRes.jobExecutionId)', infoField: 'relatedInstanceInfo', expectedStatus: 'CREATED' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(normalizedValue1)' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(normalizedValue2)' }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: '#(profileName)', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '035', matchSubfield: 'a', ind1: '*', ind2: '*', incomingQualifier: '#(qBeginsOclcNumerics)', existingQualifier: '#(qBeginsOclcNumerics)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'C1505073-update-bib-' + runId
    * def buildRes = call read(commonFeature + '@BuildBibFile') { controlNumber: '#(controlNumber)', heading: '#(updatedTitle)', matchField: '035', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    # Step 4: Import the update MARC-Bib file using the match profile with begins with qualifier and numerics only
    Given def importRes = call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match importRes.jobExecution.status == 'COMMITTED'
    # Step 5: Verify SRS and instance statuses are updated
    And call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(importRes.jobExecutionId)', externalId: '#(seedRes.instanceId)', infoField: 'relatedInstanceInfo' }
    # Step 6: Verify The 245 $a title now ends with "UPDATED"
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '245', subfield: 'a', expectedValue: '#(updatedTitle)' }

  # C1528149 - 035 $a with both an "Ends with" qualifier and Alphanumerics only configured on both sides
  @C1528149
  Scenario: MARC Bib is updated on 035 $a with "ENDS_WITH" qualifier and Alphanumerics Only On Both Sides
    * def profileName = 'C1528149 MARC bib 035 $a on 035 $a with both a Ends with qualifier and Alphanumerics only configured - ' + runId
    * def qEndsAlphanumerics = { qualifierType: 'ENDS_WITH', qualifierValue: '50133', comparisonPart: 'ALPHANUMERICS_ONLY' }
    * def controlNumber = 'C1528149' + runId
    # Unique digits keep the values unique per run, while the matching value still ends with "50133"
    * def existingValue1 = '(OCoLC)' + digits + '50133'
    * def existingValue2 = '(OCoLC)' + digits + '50999'
    # The incoming value contains a space after the prefix, which Alphanumerics only ignores
    * def incomingValue = '(OCoLC) ' + digits + '50133'
    * def title = 'Scenario C1528149 ' + runId
    * def updatedTitle = title + ' UPDATED'

    # Step 1: Import "C1528149-create-bib.mrc" Using The "Default - Create instance and SRS MARC Bib" Job Profile
    Given def seedRes = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#(controlNumber)', heading: '#(title)', matchField: '035', matchSubfield: 'a', matchValues: ['#(existingValue1)', '#(existingValue2)'] }
    # Step 2: Verify Through Log Entries That The Record Was Created
    Then call read(commonFeature + '@AssertJobLogStatus') { jobExecutionId: '#(seedRes.jobExecutionId)', infoField: 'relatedInstanceInfo', expectedStatus: 'CREATED' }
    # Step 3: Verify The Instance And Its MARC Source Contain Both 035 $a Values
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(existingValue1)' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '035', subfield: 'a', expectedValue: '#(existingValue2)' }

    # Preconditions: Create Mapping, Action, Match And Job Profiles
    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: '#(profileName)', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '035', matchSubfield: 'a', ind1: '*', ind2: '*', incomingQualifier: '#(qEndsAlphanumerics)', existingQualifier: '#(qEndsAlphanumerics)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'C1528149-update-bib-' + runId
    * def buildRes = call read(commonFeature + '@BuildBibFile') { controlNumber: '#(controlNumber)', heading: '#(updatedTitle)', matchField: '035', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    # Step 4-6: Import "C1528149-update-bib.mrc" Using The Custom Job Profile and verify the record is updated
    Given def importRes = call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match importRes.jobExecution.status == 'COMMITTED'
    And call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(importRes.jobExecutionId)', externalId: '#(seedRes.instanceId)', infoField: 'relatedInstanceInfo' }
    And call read(commonFeature + '@AssertSourceRecordValue') { recordType: 'MARC_BIB', externalId: '#(seedRes.instanceId)', field: '245', subfield: 'a', expectedValue: '#(updatedTitle)' }
