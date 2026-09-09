@parallel=false
Feature: FAT-28498 MARC Bib matching with "Only compare part of the value"

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/marc-match-comparison-part-common.feature'
    * configure retry = { count: 30, interval: 5000 }

    * def runId = epoch + randomString(5)
    * def randomDigits = function(n) { var r = ''; for (var i = 0; i < n; i++) { r += Math.floor(Math.random() * 10); } return r; }
    * def digits = epoch + randomDigits(6)

    * def AC = { comparisonPart: 'ALPHANUMERICS_ONLY' }
    * def NC = { comparisonPart: 'NUMERICS_ONLY' }

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

  # B-3 C1505071 - Numerics only on both sides.
  @C1505071
  Scenario: Bib matches on 010 $a with an alphabetic prefix on the incoming side using Numerics only
    * def existingValue = digits
    * def incomingValue = 'ca ' + digits
    * def seeded = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#("FAT28498B3" + runId)', heading: '#("FAT-28498 B3 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 B3 numerics', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(NC)', existingQualifier: '#(NC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-b3-incoming-' + runId
    * call read(commonFeature + '@BuildBibFile') { controlNumber: '#("FAT28498B3" + runId)', heading: '#("FAT-28498 B3 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.instanceId)', infoField: 'relatedInstanceInfo' }

  # B-7 C1505074 - Numerics only on the incoming side only.
  @C1505074
  Scenario: Bib matches on 010 $a with Numerics only on the incoming record side only
    * def existingValue = digits
    * def incomingValue = 'n ' + digits
    * def seeded = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#("FAT28498B7" + runId)', heading: '#("FAT-28498 B7 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 B7 incoming only', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(NC)', existingQualifier: null }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-b7-incoming-' + runId
    * call read(commonFeature + '@BuildBibFile') { controlNumber: '#("FAT28498B7" + runId)', heading: '#("FAT-28498 B7 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.instanceId)', infoField: 'relatedInstanceInfo' }

  # B-8 C1528147 - Alphanumerics only on the existing side only.
  @C1528147
  Scenario: Bib matches on 010 $a with Alphanumerics only on the existing record side only
    * def existingValue = 'na ' + runId + ' '
    * def incomingValue = 'na' + runId
    * def seeded = call read(commonFeature + '@SeedBib') { runId: '#(runId)', controlNumber: '#("FAT28498B8" + runId)', heading: '#("FAT-28498 B8 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 B8 existing only', recordType: 'MARC_BIBLIOGRAPHIC', mappingDetailsName: 'marcBib', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: null, existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-b8-incoming-' + runId
    * call read(commonFeature + '@BuildBibFile') { controlNumber: '#("FAT28498B8" + runId)', heading: '#("FAT-28498 B8 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.instanceId)', infoField: 'relatedInstanceInfo' }
