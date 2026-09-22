@parallel=false
Feature: MARC Authority matching on 001 with "Only compare part of the value"

  # 001 is matched differently from other fields: without a comparison part it is looked up directly
  # against the record's external hrid, which for authorities is the raw incoming 001 - LCCN padding
  # included. With a comparison part configured the match has to go through marc_indexers instead so
  # the stored value can be normalised too (MODSOURCE-1019 follow-up to MODDICORE-509).

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/marc-match-comparison-part-common.feature'
    * configure retry = { count: 30, interval: 5000 }

    * def runId = epoch + randomString(5)
    * def AC = { comparisonPart: 'ALPHANUMERICS_ONLY' }

    * def paddedValue = 'n ' + runId + ' '
    * def compactValue = 'n' + runId
    * def heading = 'MODSOURCE-1019 ' + runId
    * def updatedHeading = heading + ' UPDATED'

  # C1538655 - baseline. No options, identical 001 including its trailing space. Exercises the
  # direct external-hrid lookup.
  @C1538655
  Scenario: Authority is updated when 001 control numbers match exactly
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#(paddedValue)', heading: '#(heading)', matchField: '001', matchSubfield: '', matchValues: ['#(paddedValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'MODSOURCE-1019 A-23 001 exact', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '001', matchSubfield: '', ind1: '', ind2: '', incomingQualifier: null, existingQualifier: null }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'MODSOURCE-1019-a23-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#(paddedValue)', heading: '#(updatedHeading)', matchField: '001', matchSubfield: '', matchValues: ['#(paddedValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }
    * call read(commonFeature + '@AssertAuthorityHeading') { authorityId: '#(seeded.authorityId)', expectedHeading: '#(updatedHeading)' }

  # C1538657 - Alphanumerics only on both sides, identical padded values. Fails when only the
  # incoming side is normalised: "n<id>" is then compared against a stored "n <id> ".
  @C1538657
  Scenario: Authority is updated on 001 with Alphanumerics only when both values have whitespace
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#(paddedValue)', heading: '#(heading)', matchField: '001', matchSubfield: '', matchValues: ['#(paddedValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'MODSOURCE-1019 A-25 001 alphanumerics', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '001', matchSubfield: '', ind1: '', ind2: '', incomingQualifier: '#(AC)', existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'MODSOURCE-1019-a25-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#(paddedValue)', heading: '#(updatedHeading)', matchField: '001', matchSubfield: '', matchValues: ['#(paddedValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }
    * call read(commonFeature + '@AssertAuthorityHeading') { authorityId: '#(seeded.authorityId)', expectedHeading: '#(updatedHeading)' }

  # C1538658 - Alphanumerics only on both sides, incoming 001 without whitespace.
  @C1538658
  Scenario: Authority is updated on 001 with Alphanumerics only when the incoming value has no whitespace
    * def seeded = call read(commonFeature + '@SeedAuthority') { runId: '#(runId)', controlNumber: '#(paddedValue)', heading: '#(heading)', matchField: '001', matchSubfield: '', matchValues: ['#(paddedValue)'] }

    * def profiles = call read(commonFeature + '@CreateUpdateJobProfile') { runId: '#(runId)', profileName: 'MODSOURCE-1019 A-26 001 alphanumerics', recordType: 'MARC_AUTHORITY', mappingDetailsName: 'marcAuthority', matchField: '001', matchSubfield: '', ind1: '', ind2: '', incomingQualifier: '#(AC)', existingQualifier: '#(AC)' }
    * def jobProfileId = profiles.jobProfileId

    * def incomingFileName = 'MODSOURCE-1019-a26-incoming-' + runId
    * call read(commonFeature + '@BuildAuthorityFile') { controlNumber: '#(compactValue)', heading: '#(updatedHeading)', matchField: '001', matchSubfield: '', matchValues: ['#(compactValue)'], fileName: '#(incomingFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(incomingFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + incomingFileName + ".mrc")' }
    Then match status != 'ERROR'
    * call read(commonFeature + '@AssertMarcUpdated') { jobExecutionId: '#(jobExecutionId)', externalId: '#(seeded.authorityId)', infoField: 'relatedAuthorityInfo' }
    * call read(commonFeature + '@AssertAuthorityHeading') { authorityId: '#(seeded.authorityId)', expectedHeading: '#(updatedHeading)' }
