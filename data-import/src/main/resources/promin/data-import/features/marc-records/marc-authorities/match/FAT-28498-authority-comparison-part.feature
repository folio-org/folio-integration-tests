@parallel=false
Feature: FAT-28498 MARC Authority matching with "Only compare part of the value"

  # Covers MODDICORE-509 / MODSOURCE-1019 for MARC Authority to MARC Authority matching.
  # The fix makes "Only compare part of the value" apply without "Use a qualifier" being set on the
  # same side, and makes the existing-record qualifier apply at all for authorities.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/marc-match-comparison-part-common.feature'
    * configure retry = { count: 30, interval: 5000 }

    # Unique per scenario, so re-runs and parallel jobs never match each other's records
    * def runId = epoch + randomString(5)
    # randomString yields letters only and epoch is second-precision, so a numerics-only scenario
    # would otherwise normalise down to a digit string shared by every run in the same second
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

  # A-3 C1505044 - Same data as A-2, with "Alphanumerics only" on both sides and no
  # qualifier anywhere.
  @C1505044
  Scenario: Authority matches on 010 $a differing only in whitespace using Alphanumerics only on both sides
    * def existingValue = 'n ' + runId
    * def incomingValue = 'n' + runId
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A3" + runId)', heading: '#("FAT-28498 A3 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A3 alphanumerics', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(AC)', existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a3-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A3" + runId)', heading: '#("FAT-28498 A3 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

  # A-4 C1505057 - the second comparison part. The alphabetic LCCN prefixes differ deliberately, so
  # only the numeric portion can match.
  @C1505057
  Scenario: Authority matches on 010 $a with different prefixes using Numerics only on both sides
    * def existingValue = 'no ' + digits
    * def incomingValue = 'sn' + digits
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A4" + runId)', heading: '#("FAT-28498 A4 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A4 numerics', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: '#(NC)', existingQualifier: '#(NC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a4-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A4" + runId)', heading: '#("FAT-28498 A4 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

  # A-12 C1505065 - the comparison part on the existing side only.
  @C1505065
  Scenario: Authority matches on 010 $a with Alphanumerics only on the existing record side only
    * def existingValue = 'n ' + runId
    * def incomingValue = 'n' + runId
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#("FAT28498A12" + runId)', heading: '#("FAT-28498 A12 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(existingValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'FAT-28498 A12 existing only', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ', incomingQualifier: null, existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'FAT-28498-a12-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#("FAT28498A12" + runId)', heading: '#("FAT-28498 A12 " + runId)', matchField: '010', matchSubfield: 'a', matchValues: ['#(incomingValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }

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
