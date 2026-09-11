@ignore
Feature: Util feature for the MARC-to-MARC "Only compare part of the value" scenarios (FAT-28498)

  # Shared setup for MODDICORE-509 / MODSOURCE-1019 coverage.
  Background:
    * url baseUrl
    * configure retry = { count: 30, interval: 5000 }
    * def javaWriteData = Java.type('test.java.WriteData')
    * def marcConverter = Java.type('test.java.MarcConverter')

    * def defaultAuthorityCreateJobProfileId = '6eefa4c6-bbf7-4845-ad82-de7fc5abd0e3'
    # Shipped "Default - Create MARC Authority" action profile, used for NON_MATCH branches
    * def defaultAuthorityCreateActionProfileId = '7915c72e-c6af-4962-969d-403c7238b051'

    * def buildRecord =
      """
      function(leader, controlNumber, fixed008, matchField, matchSubfield, matchValues, headingTag, headingInd1, heading) {
        var fields = [];
        fields.push({ '001': controlNumber });
        fields.push({ '008': fixed008 });
        for (var i = 0; i < matchValues.length; i++) {
          var subfield = {};
          subfield[matchSubfield] = matchValues[i];
          var field = {};
          field[matchField] = { 'ind1': ' ', 'ind2': ' ', 'subfields': [ subfield ] };
          fields.push(field);
        }
        var headingField = {};
        headingField[headingTag] = { 'ind1': headingInd1, 'ind2': ' ', 'subfields': [ { 'a': heading } ] };
        fields.push(headingField);
        return { 'leader': leader, 'fields': fields };
      }
      """

  @BuildAuthorityFile
  Scenario: Write a MARC Authority file carrying the given match field values
    # parameters: controlNumber, heading, matchField, matchSubfield, matchValues, fileName
    * def recordJson = buildRecord('01012cz  a2200241n  4500', __arg.controlNumber, '201001 n acanaaabn           n aaa     d', __arg.matchField, __arg.matchSubfield, __arg.matchValues, '100', '1', __arg.heading)
    * def binary = marcConverter.convertJsonStringToBinary(JSON.stringify(recordJson))
    * javaWriteData.writeByteArrayToFile(binary, 'target/' + __arg.fileName + '.mrc')

  @BuildBibFile
  Scenario: Write a MARC Bibliographic file carrying the given match field values
    # parameters: controlNumber, heading, matchField, matchSubfield, matchValues, fileName
    * def recordJson = buildRecord('00714cam a2200205 a 4500', __arg.controlNumber, '020805s2002    nyu    j      000 1 eng  ', __arg.matchField, __arg.matchSubfield, __arg.matchValues, '245', '1', __arg.heading)
    * def binary = marcConverter.convertJsonStringToBinary(JSON.stringify(recordJson))
    * javaWriteData.writeByteArrayToFile(binary, 'target/' + __arg.fileName + '.mrc')

  @SeedAuthority
  Scenario: Create one MARC Authority record to act as the existing record
    # parameters: runId, controlNumber, heading, matchField, matchSubfield, matchValues
    # returns: authorityId, authorityRecordId
    * def seedFileName = 'FAT-28498-seed-' + __arg.runId
    * call read('classpath:promin/data-import/global/marc-match-comparison-part-common.feature@BuildAuthorityFile') { controlNumber: '#(__arg.controlNumber)', heading: '#(__arg.heading)', matchField: '#(__arg.matchField)', matchSubfield: '#(__arg.matchSubfield)', matchValues: '#(__arg.matchValues)', fileName: '#(seedFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(seedFileName)', jobName: 'createAuthority', filePathFromSourceRoot: '#("file:target/" + seedFileName + ".mrc")' }
    Then match status != 'ERROR'

    # Wait for the authority to exist and for SRS to have finished indexing it, otherwise the
    # match job that follows can run against a record that is not yet in marc_indexers
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords == 1 && karate.get('response.sourceRecords[0].externalIdsHolder.authorityId') != null
    When method GET
    Then status 200

    * def authorityId = response.sourceRecords[0].externalIdsHolder.authorityId
    * def authorityRecordId = response.sourceRecords[0].recordId
    * print 'FAT-28498 seeded authority', authorityId, 'with', __arg.matchField, __arg.matchSubfield, '=', __arg.matchValues

  @SeedBib
  Scenario: Create one MARC Bibliographic record to act as the existing record
    # parameters: runId, controlNumber, heading, matchField, matchSubfield, matchValues
    # returns: instanceId, bibRecordId
    * def seedFileName = 'FAT-28498-seed-bib-' + __arg.runId
    * call read('classpath:promin/data-import/global/marc-match-comparison-part-common.feature@BuildBibFile') { controlNumber: '#(__arg.controlNumber)', heading: '#(__arg.heading)', matchField: '#(__arg.matchField)', matchSubfield: '#(__arg.matchSubfield)', matchValues: '#(__arg.matchValues)', fileName: '#(seedFileName)' }

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(seedFileName)', jobName: 'createInstance', filePathFromSourceRoot: '#("file:target/" + seedFileName + ".mrc")' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords == 1 && karate.get('response.sourceRecords[0].externalIdsHolder.instanceId') != null
    When method GET
    Then status 200

    * def instanceId = response.sourceRecords[0].externalIdsHolder.instanceId
    * def bibRecordId = response.sourceRecords[0].recordId
    * print 'FAT-28498 seeded bib', instanceId, 'with', __arg.matchField, __arg.matchSubfield, '=', __arg.matchValues

  @CreateUpdateJobProfile
  Scenario: Create a MARC-to-MARC job profile that updates the matched record
    # parameters: runId, profileName, recordType, mappingDetailsName, matchField, matchSubfield,
    #             ind1, ind2, incomingQualifier, existingQualifier
    # returns: jobProfileId, matchProfileId

    * def recordType = __arg.recordType
    * def incomingQualifier = __arg.incomingQualifier
    * def existingQualifier = __arg.existingQualifier
    * def incomeField = __arg.matchField
    * def existingField = __arg.matchField
    * def incomeSubField = __arg.matchSubfield
    * def existingSubField = __arg.matchSubfield
    * def ind1 = __arg.ind1
    * def ind2 = __arg.ind2

    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(__arg.profileName + ' - mapping ' + __arg.runId)",
          "incomingRecordType": "#(recordType)",
          "existingRecordType": "#(recordType)",
          "description": "FAT-28498 MARC-to-MARC update",
          "mappingDetails": {
            "name": "#(__arg.mappingDetailsName)",
            "recordType": "#(recordType)",
            "marcMappingDetails": [],
            "marcMappingOption": "UPDATE"
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(__arg.profileName + ' - action ' + __arg.runId)",
          "action": "UPDATE",
          "folioRecord": "#(recordType)",
          "description": "FAT-28498 MARC-to-MARC update"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "ACTION_PROFILE",
            "detailProfileId": "#(mappingProfileId)",
            "detailProfileType": "MAPPING_PROFILE"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def actionProfileId = $.id

    * def matchProfileName = __arg.profileName + ' - match ' + __arg.runId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/match-profile-with-qualifier.json')
    When method POST
    Then status 201
    * def matchProfileId = $.id
    * def nonMatchActionProfileId = karate.get('__arg.nonMatchActionProfileId')
    * def jobProfileTemplate = nonMatchActionProfileId ? 'profiles/job-profile-with-non-match.json' : 'profiles/job-profile.json'
    * def jobProfileName = __arg.profileName + ' - job ' + __arg.runId
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request read(samplePath + jobProfileTemplate)
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * print 'FAT-28498 created update job profile', jobProfileId, 'matching', __arg.matchField, __arg.matchSubfield

  @AssertMarcUpdated
  Scenario: Assert the import updated the expected existing record
    # parameters: jobExecutionId, externalId, infoField ('relatedAuthorityInfo' or 'relatedInstanceInfo')
    Given path 'metadata-provider/jobLogEntries', __arg.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 1 && karate.get('response.entries[0].sourceRecordActionStatus') != null
    When method GET
    Then status 200
    * def entry = response.entries[0]
    * print 'FAT-28498 job log entry:', entry
    * def relatedInfo = entry[__arg.infoField]
    And match entry.sourceRecordActionStatus == 'UPDATED'
    And match relatedInfo.idList contains __arg.externalId

  @AssertMarcNotMatched
  Scenario: Assert the import matched nothing, so the existing record was left untouched
    # parameters: jobExecutionId
    Given path 'metadata-provider/jobLogEntries', __arg.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 1 && karate.get('response.entries[0].sourceRecordActionStatus') != null
    When method GET
    Then status 200
    * def entry = response.entries[0]
    * print 'FAT-28498 job log entry:', entry
    And match entry.sourceRecordActionStatus == 'DISCARDED'

  @AssertMarcCreatedAsDuplicate
  Scenario: Assert the import created a new record instead of updating the existing one
    # parameters: jobExecutionId, existingExternalId, infoField
    Given path 'metadata-provider/jobLogEntries', __arg.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 1 && karate.get('response.entries[0].sourceRecordActionStatus') != null
    When method GET
    Then status 200
    * def entry = response.entries[0]
    * print 'FAT-28498 job log entry:', entry
    * def relatedInfo = entry[__arg.infoField]
    And match entry.sourceRecordActionStatus == 'CREATED'
    And match relatedInfo.actionStatus == 'CREATED'
    * def createdId = relatedInfo.idList[0]
    And match createdId != null
    And match createdId != __arg.existingExternalId
    * print 'FAT-28498 duplicate created:', createdId, 'alongside existing:', __arg.existingExternalId
