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
