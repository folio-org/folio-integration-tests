@parallel=false
Feature: FAT-28498 MARC Authority matching with "Only compare part of the value"

  # Covers MODDICORE-509 / MODSOURCE-1019 for MARC Authority to MARC Authority matching.
  # This file holds the scenarios TestRail classifies as Critical Path.
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
