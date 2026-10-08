@parallel=false
Feature: MARC Authority matching with "Only compare part of the value" - extended

  # Covers MODDICORE-509 / MODSOURCE-1019 for MARC Authority to MARC Authority matching.

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
    * def qBeginsOclc = { qualifierType: 'BEGINS_WITH', qualifierValue: '(OCoLC)' }
    * def qBeginsOclcNumerics = { qualifierType: 'BEGINS_WITH', qualifierValue: '(OCoLC)', comparisonPart: 'NUMERICS_ONLY' }

  # A-1 C350723 - baseline.
  @C350723
  Scenario: Authority matches on 010 $a with neither option selected
    * def value = 'n' + runId
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A1" + runId)', heading: '#("FAT-28498 A1 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(value)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A1 baseline', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: null, existingQualifier: null }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a1-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A1" + runId)', heading: '#("FAT-28498 A1 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(value)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

  # A-2 C1505056 - negative baseline. The two 010 $a values differ
  # only by one space and no option is selected, so they must not match.
  @C1505056
  Scenario: Authority does not match on 010 $a differing only in whitespace and a duplicate is created
    * def existingValue = 'n ' + runId
    * def incomingValue = 'n' + runId
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A2" + runId)', heading: '#("FAT-28498 A2 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A2 no options', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: null, existingQualifier: null, nonMatchActionProfileId: '7915c72e-c6af-4962-969d-403c7238b051' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a2-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A2" + runId)', heading: '#("FAT-28498 A2 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcCreatedAsDuplicate') { jobExecutionId: '#(jobExecutionId)', existingExternalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

  # A-9 C1505062 - qualifier and comparison part together on 035 $a.
  @C1505062
  Scenario: Authority matches on 035 $a with a qualifier and Numerics only on both sides
    * def otherDigits = epoch + randomDigits(6)
    * def existingValues = ['#("(OCoLC)ocn" + digits)', '#("(OCoLC)ocm" + otherDigits)']
    * def incomingValue = '(OCoLC)ocm' + digits
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A9" + runId)', heading: '#("FAT-28498 A9 " + runId)', matchField: '035', matchSubfield: 'a', matchValues: '#(existingValues)' }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A9 qualifier and numerics', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '035', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(qBeginsOclcNumerics)', existingQualifier: '#(qBeginsOclcNumerics)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a9-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A9" + runId)', heading: '#("FAT-28498 A9 " + runId)', matchField: '035', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

  @C1538563
  Scenario: Authority is not updated on 010 $a with numerics only incoming and alphanumerics only existing and no qualifier
    * def profileName = 'C1538563 MARC authority 010 $a on 010 $a - Numerics only incoming, Alphanumerics only existing, no qualifier (negative)' + runId
    * def matchValue = 'n79139105 '
    * def controlNumber = 'C1538563' + runId
    * def heading = 'Test case: C1538563 ' + runId

    * def seedRes = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#(controlNumber)', heading: '#(heading)', matchField: '010', matchSubfield: 'a', matchValues: ['#(matchValue)'] }
    * def authorityId = seedRes.authorityId

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: '#(profileName)', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(NC)', existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'C1538563-incoming-authority-' + runId
    * def res = call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#(controlNumber)', heading: '#(heading)', matchField: '010', matchSubfield: 'a', matchValues: ['#(matchValue)'], fileName: '#(incomingFileName)' }

    * def importRes = call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    * match importRes.jobExecution.status == 'COMMITTED'

    * call read(commonFeature + '@AssertMarcNotMatched') { jobExecutionId: '#(importRes.jobExecutionId)' }

    Given path 'authority-storage/authorities', authorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.id == authorityId

  @C1538565
  Scenario: Authority Records Are Updated On 010 $a With Numerics Only On Both Sides And Devanagari Digits In Incoming
    * def profileName = 'C1538565 MARC authority 010 $a on 010 $a - Numerics only both sides, incoming contains Devanagari digits'
    * def devanagariContent = '१२३'
    * def firstMatchValue = 'n79139107'
    * def secondMatchValue = 'ts 79139108'
    * def firstUpdateValue = devanagariContent + '79139107'
    * def secondUpdateValue = 'na 79139108'
    * def firstControlNumber = 'C1538565A' + runId
    * def secondControlNumber = 'C1538565B' + runId
    * def firstHeading = 'Test case: C1538565 first ' + runId
    * def secondHeading = 'Test case: C1538565 second ' + runId

    * def createFileName = 'C1538565-create-authority-' + runId
    * def createRecords = [{ controlNumber: '#(firstControlNumber)', heading: '#(firstHeading)', matchValue: '#(firstMatchValue)' }, { controlNumber: '#(secondControlNumber)', heading: '#(secondHeading)', matchValue: '#(secondMatchValue)' }]
    * def buildRes = call read(commonFeature + '@BuildMultiAuthoritiesFile') { records: '#(createRecords)', matchField: '010', matchSubfield: 'a', fileName: '#(createFileName)' }

    Given def createRes = call read(utilFeature + '@ImportRecord') { fileName: '#(createFileName)', jobName: 'createAuthority', filePathFromSourceRoot: '#("file:target/" + createFileName + ".mrc")' }
    Then match createRes.jobExecution.status == 'COMMITTED'
    * def createJobExecutionId = createRes.jobExecutionId

    # Find the imported MARC Authority records and verify their 010 $a values
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = createJobExecutionId
    And headers headersUser
    And retry until response.totalRecords == 2 && karate.get('response.sourceRecords[0].externalIdsHolder.authorityId') != null && karate.get('response.sourceRecords[1].externalIdsHolder.authorityId') != null
    When method GET
    Then status 200
    And def firstRecord = response.sourceRecords.find(r => r.order == 0)
    And def secondRecord = response.sourceRecords.find(r => r.order == 1)
    And match karate.jsonPath(firstRecord, "$.parsedRecord.content.fields[*]['010'].subfields[*].a")[0] == firstMatchValue
    And match karate.jsonPath(secondRecord, "$.parsedRecord.content.fields[*]['010'].subfields[*].a")[0] == secondMatchValue
    And def firstAuthorityId = karate.get('firstRecord.externalIdsHolder.authorityId')
    And def secondAuthorityId = karate.get('secondRecord.externalIdsHolder.authorityId')
    And assert firstAuthorityId != null
    And assert secondAuthorityId != null

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: '#(profileName)', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(NC)', existingQualifier: '#(NC)' }
    * def jobProfileId = profiles.jobProfileId

    * def updateFileName = 'C1538565-update-authority-' + runId
    * def updatedFirstHeading = firstHeading + ' UPDATED'
    * def updatedSecondHeading = secondHeading + ' UPDATED'
    * def updateRecords = [{ controlNumber: '#(firstControlNumber)', heading: '#(updatedFirstHeading)', matchValue: '#(firstUpdateValue)' }, { controlNumber: '#(secondControlNumber)', heading: '#(updatedSecondHeading)', matchValue: '#(secondUpdateValue)' }]
    * def buildRes = call read(commonFeature + '@BuildMultiAuthoritiesFile') { records: '#(updateRecords)', matchField: '010', matchSubfield: 'a', fileName: '#(updateFileName)' }

    Given def updateRes = call read(utilFeature + '@ImportRecord') { fileName: '#(updateFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + updateFileName + ".mrc")' }
    Then match updateRes.jobExecution.status == 'COMMITTED'
    And call read(commonFeature + '@AssertMarcUpdatedMultiple') { jobExecutionId: '#(updateRes.jobExecutionId)', expectedCount: 2, externalIds: ['#(firstAuthorityId)', '#(secondAuthorityId)'], infoField: 'relatedAuthorityInfo' }
    And call read(commonFeature + '@AssertAuthorityHeading') { authorityId: '#(firstAuthorityId)', expectedHeading: '#(updatedFirstHeading)' }
    And call read(commonFeature + '@AssertAuthorityHeading') { authorityId: '#(secondAuthorityId)', expectedHeading: '#(updatedSecondHeading)' }
