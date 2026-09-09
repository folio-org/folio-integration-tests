@parallel=false
Feature: FAT-28498 MARC Bib matching with "Only compare part of the value"

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/marc-match-comparison-part-common.feature'
    * configure retry = { count: 30, interval: 5000 }

    * def runId = epoch + randomString(5)
    * def AC = { comparisonPart: 'ALPHANUMERICS_ONLY' }

  # B-2 C1505070 - The two 010 $a values differ only by one space and
  # "Alphanumerics only" is set on both sides with no qualifier anywhere.
  @C1505070
  Scenario: Bib matches on 010 $a differing only in whitespace using Alphanumerics only on both sides
    * def existingValue = 'a ' + runId
    * def incomingValue = 'a' + runId
    * def seeded = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#("FAT28498B2" + runId)', heading: '#("FAT-28498 B2 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 B2 alphanumerics', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(AC)', existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-b2-incoming-' + runId
    * call read(commonFeature + '@BuildBibFile') { controlNumber: '#("FAT28498B2" + runId)', heading: '#("FAT-28498 B2 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.instanceId)', infoField: 'relatedInstanceInfo' }
