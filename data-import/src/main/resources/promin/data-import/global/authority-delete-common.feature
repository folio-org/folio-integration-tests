@ignore
Feature: Util feature for the Delete MARC Authority data import scenarios (FAT-26991)

  # Shared setup for the four "Delete MARC Authority" match-point tests. Callers are expected to
  # have called global/auth.feature and global/common-functions.feature first, so that headersUser
  # and utilFeature are in scope.

  Background:
    * url baseUrl
    * configure retry = { count: 30, interval: 5000 }
    * def javaWriteData = Java.type('test.java.WriteData')
    * def marcConverter = Java.type('test.java.MarcConverter')
    * def seedResource = samplePath + 'mrc-files/FAT-26991-authorities.mrc'
    * def seedLinkedControlNumber = '13389'
    * def seedUnlinkedControlNumber = '2426190'
    * def seedNonMatchControlNumber = '7394284'

    * def defaultAuthorityCreateJobProfileId = '6eefa4c6-bbf7-4845-ad82-de7fc5abd0e3'
    * def defaultCreateInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'
    # Shipped "Default - Delete MARC Authority records" action profile.
    * def defaultDeleteAuthorityActionProfileId = 'fabd9a3e-33c3-49b7-864d-c5af830d9990'

    # Data export does not guarantee the order of the records it returns, so records are always
    # located by their 001 rather than by position.
    * def findRecordByControlNumber =
      """
      function(sourceRecords, controlNumber) {
        for (var i = 0; i < sourceRecords.length; i++) {
          var fields = sourceRecords[i].parsedRecord.content.fields;
          for (var j = 0; j < fields.length; j++) {
            if (fields[j]['001'] == controlNumber) {
              return sourceRecords[i];
            }
          }
        }
        return null;
      }
      """

  @SeedAuthorities
  Scenario: Import three MARC authority records - two to be matched and deleted, one to be left alone
    # parameters: runId
    # returns: linkedAuthorityId/linkedRecordId/linkedControlNumber,
    #          unlinkedAuthorityId/unlinkedRecordId/unlinkedControlNumber,
    #          nonMatchAuthorityId/nonMatchRecordId/nonMatchControlNumber

    # Every run gets its own 001 and 010 $a. Data import matches on those fields, so records left
    # behind by an earlier run against the same tenant would otherwise produce multiple matches.
    * def linkedControlNumber = 'FAT26991L' + __arg.runId
    * def unlinkedControlNumber = 'FAT26991U' + __arg.runId
    * def nonMatchControlNumber = 'FAT26991N' + __arg.runId
    * def linkedLccn = 'fat26991l' + __arg.runId
    * def unlinkedLccn = 'fat26991u' + __arg.runId
    # nonMatchLccnOverride lets a caller seed a second authority carrying an 010 $a that already
    # exists, so that an incoming record with that value produces a "multiple matches" error
    * def passedParams = karate.get('__arg', {})
    * def nonMatchLccn = passedParams.nonMatchLccnOverride ? passedParams.nonMatchLccnOverride : ('fat26991n' + __arg.runId)

    * def seedFile = read(seedResource)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, seedLinkedControlNumber, '001', ' ', linkedControlNumber)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, linkedControlNumber, '010', 'a', linkedLccn)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, seedUnlinkedControlNumber, '001', ' ', unlinkedControlNumber)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, unlinkedControlNumber, '010', 'a', unlinkedLccn)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, seedNonMatchControlNumber, '001', ' ', nonMatchControlNumber)
    * def seedFile = javaWriteData.setFieldValueByControlNumber(seedFile, nonMatchControlNumber, '010', 'a', nonMatchLccn)

    * def seedFileName = 'FAT-26991-seed-' + __arg.runId
    * javaWriteData.writeByteArrayToFile(seedFile, 'target/' + seedFileName + '.mrc')

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(seedFileName)', jobName: 'createAuthority', filePathFromSourceRoot: '#("file:target/" + seedFileName + ".mrc")' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords == 3 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0 && karate.sizeOf(response.sourceRecords[1].externalIdsHolder) > 0 && karate.sizeOf(response.sourceRecords[2].externalIdsHolder) > 0
    When method GET
    Then status 200

    * def linkedRecord = findRecordByControlNumber(response.sourceRecords, linkedControlNumber)
    * def unlinkedRecord = findRecordByControlNumber(response.sourceRecords, unlinkedControlNumber)
    * def nonMatchRecord = findRecordByControlNumber(response.sourceRecords, nonMatchControlNumber)
    * match linkedRecord != null
    * match unlinkedRecord != null
    * match nonMatchRecord != null

    * def linkedAuthorityId = linkedRecord.externalIdsHolder.authorityId
    * def linkedRecordId = linkedRecord.recordId
    * def unlinkedAuthorityId = unlinkedRecord.externalIdsHolder.authorityId
    * def unlinkedRecordId = unlinkedRecord.recordId
    * def nonMatchAuthorityId = nonMatchRecord.externalIdsHolder.authorityId
    * def nonMatchRecordId = nonMatchRecord.recordId

    * print 'Seeded authorities - linked:', linkedAuthorityId, 'unlinked:', unlinkedAuthorityId, 'nonMatch:', nonMatchAuthorityId

  @CreateDeleteJobProfile
  Scenario: Create a job profile that deletes matched MARC authority records
    # parameters: runId, profileName, matchField, matchSubfield, ind1, ind2
    # returns: jobProfileId

    * def recordType = 'MARC_AUTHORITY'
    * def matchProfileName = __arg.profileName + ' - match profile ' + __arg.runId
    * def incomeField = __arg.matchField
    * def existingField = __arg.matchField
    * def incomeSubField = __arg.matchSubfield
    * def existingSubField = __arg.matchSubfield
    * def ind1 = __arg.ind1
    * def ind2 = __arg.ind2

    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    * def matchProfileId = $.id

    # Delete action reacting to MATCH, so non-matched incoming records are simply discarded
    * def jobProfileName = __arg.profileName + ' - job profile ' + __arg.runId
    * def actionProfileId = defaultDeleteAuthorityActionProfileId
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * print 'Created delete job profile:', jobProfileId, 'matching on', __arg.matchField, __arg.matchSubfield

  @LinkBibToAuthority
  Scenario: Import a MARC bib record and link its 100 field to the given authority
    # parameters: runId, authorityId, authorityNaturalId
    # returns: instanceId, bibParsedRecordId

    * def bibControlNumber = 'FAT26991BIB' + __arg.runId
    * def bibTitle = 'FAT-26991 linked bib ' + __arg.runId
    * def bibJson =
      """
      {
        "leader": "00714cam a2200205 a 4500",
        "fields": [
          { "001": "#(bibControlNumber)" },
          { "008": "020805s2002    nyu    j      000 1 eng  " },
          { "100": { "ind1": "1", "ind2": " ", "subfields": [ { "a": "Kirby, Jack" } ] } },
          { "245": { "ind1": "1", "ind2": "0", "subfields": [ { "a": "#(bibTitle)" } ] } }
        ]
      }
      """
    * def bibBinary = marcConverter.convertJsonStringToBinary(JSON.stringify(bibJson))
    * def bibFileName = 'FAT-26991-bib-' + __arg.runId
    * javaWriteData.writeByteArrayToFile(bibBinary, 'target/' + bibFileName + '.mrc')

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(bibFileName)', jobName: 'createInstance', filePathFromSourceRoot: '#("file:target/" + bibFileName + ".mrc")' }
    Then match status != 'ERROR'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') == 'CREATED'
    When method GET
    Then status 200
    * def instanceId = response.entries[0].relatedInstanceInfo.idList[0]

    # Retrieve the bib through quickMARC and link its 100 field to the authority
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def bibRecord = response

    * def linkedContent = '$a Kirby, Jack $0 ' + __arg.authorityNaturalId + ' $9 ' + __arg.authorityId
    * def linkedField = { "tag": "100", "content": "#(linkedContent)", "indicators": ["1", "\\"], "isProtected": false, "linkDetails": { "authorityId": "#(__arg.authorityId)", "authorityNaturalId": "#(__arg.authorityNaturalId)", "linkingRuleId": 1, "status": "NEW" } }
    * bibRecord.fields = bibRecord.fields.filter(f => f.tag != '100')
    * bibRecord.fields.push(linkedField)
    * set bibRecord._actionType = 'edit'

    Given path 'records-editor/records', bibRecord.parsedRecordId
    And headers headersUser
    And request bibRecord
    When method PUT
    Then status 202
    * def bibParsedRecordId = bibRecord.parsedRecordId

    # The link is created asynchronously by mod-entities-links
    Given path 'links/instances', instanceId
    And headers headersUser
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.links[0].authorityId == __arg.authorityId

    * print 'Linked bib instance', instanceId, 'to authority', __arg.authorityId
