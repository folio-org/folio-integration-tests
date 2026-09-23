@parallel=false
Feature: Settings - profiles for deleting MARC Authority records

  # UXPROD-4627 - delete authority records via data import.
  # Covers the Settings > Data import rules around the shipped "Default - Delete MARC Authority records"
  # profiles: the default match profile stays editable, and a Delete MARC Authority action is only
  # accepted in the for-matches branch of a MARC Authority to MARC Authority match, as the only action there.

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * def settingsCommon = 'classpath:promin/mod-di-converter-storage/features/delete-authority/delete-authority-profiles-common.feature'

    # Shipped "Default - Delete MARC Authority records" profiles
    * def defaultDeleteAuthorityActionProfileId = 'fabd9a3e-33c3-49b7-864d-c5af830d9990'
    * def defaultDeleteAuthorityMatchProfileId = '4be5d1d2-1f5a-42ff-a9bd-fc90609d94b6'

    * def invalidPlacementMessage = 'Delete MARC-AUTHORITY action profile must be placed in the for-matches branch of a match profile for MARC-AUTHORITY to MARC-AUTHORITY matching'
    * def nextToOtherActionsMessage = 'Delete MARC-AUTHORITY action profile cannot be placed next to other action profiles in the for-matches branch'

    # Identifies everything this run creates, so parallel runs and re-runs never collide on profile names
    * def runId = randomMillis() + random_string()

    # 010 $a match point used by the match profiles the scenarios create
    * def matchPoint010a = [{ label: 'field', value: '010' }, { label: 'indicator1', value: '' }, { label: 'indicator2', value: '' }, { label: 'recordSubfield', value: 'a' }]

    * def jobToMatchRelation = function(matchProfileId) { return { masterProfileId: null, masterProfileType: 'JOB_PROFILE', detailProfileId: matchProfileId, detailProfileType: 'MATCH_PROFILE', order: 0 } }
    * def jobToActionRelation = function(actionProfileId) { return { masterProfileId: null, masterProfileType: 'JOB_PROFILE', detailProfileId: actionProfileId, detailProfileType: 'ACTION_PROFILE', order: 0 } }
    * def matchToActionRelation = function(matchProfileId, actionProfileId, reactTo, order) { return { masterProfileId: matchProfileId, masterProfileType: 'MATCH_PROFILE', detailProfileId: actionProfileId, detailProfileType: 'ACTION_PROFILE', reactTo: reactTo, order: order } }

  @C1453728
  Scenario: "Default - Delete MARC Authority records" match profile can be edited and changes are saved
    # Step 1: open the "Default - Delete MARC Authority records" match profile
    Given path 'data-import-profiles/matchProfiles', defaultDeleteAuthorityMatchProfileId
    And headers headersUser
    When method GET
    Then status 200
    * def originalProfile = response
    And match originalProfile.name == 'Default - Delete MARC Authority records'

    * configure afterScenario = function() { karate.call(settingsCommon + '@RestoreMatchProfile', { profile: originalProfile, headersUser: headersUser }) }

    # Steps 2-5: edit Name and Description, change incoming and existing MARC Authority from 999 ff $s to 010 * * $a
    * copy editedProfile = originalProfile
    * def editedName = originalProfile.name + ' - edited'
    * def editedDescription = originalProfile.description + ' - edited'
    * set editedProfile.name = editedName
    * set editedProfile.description = editedDescription
    * def matchPoint = [{ label: 'field', value: '010' }, { label: 'indicator1', value: '*' }, { label: 'indicator2', value: '*' }, { label: 'recordSubfield', value: 'a' }]
    * set editedProfile.matchDetails[0].incomingMatchExpression.fields = matchPoint
    * set editedProfile.matchDetails[0].existingMatchExpression.fields = matchPoint

    # Step 6: save the profile
    Given path 'data-import-profiles/matchProfiles', defaultDeleteAuthorityMatchProfileId
    And headers headersUser
    And request { profile: '#(editedProfile)', addedRelations: [], deletedRelations: [] }
    When method PUT
    Then status 200

    # The profile shows the updated Name, Description and structure
    Given path 'data-import-profiles/matchProfiles', defaultDeleteAuthorityMatchProfileId
    And headers headersUser
    When method GET
    Then status 200
    And match response.name == editedName
    And match response.description == editedDescription
    And match response.incomingRecordType == 'MARC_AUTHORITY'
    And match response.existingRecordType == 'MARC_AUTHORITY'
    And match response.matchDetails[0].incomingMatchExpression.fields == matchPoint
    And match response.matchDetails[0].existingMatchExpression.fields == matchPoint

  @C1453729
  Scenario: Job profile creation is rejected when Delete MARC Authority action is placed in invalid configurations
    # Precondition: a MARC Authority to MARC Authority match profile, 010 to 010 $a
    * def recordType = 'MARC_AUTHORITY'
    * def matchProfileName = 'FAT-28854 authority match ' + runId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(matchProfileName)",
          "description": "",
          "incomingRecordType": "#(recordType)",
          "existingRecordType": "#(recordType)",
          "matchDetails": [{
            "matchCriterion": "EXACTLY_MATCHES",
            "incomingRecordType": "#(recordType)",
            "existingRecordType": "#(recordType)",
            "incomingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" },
            "existingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" }
          }]
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def authorityMatchProfileId = $.id

    # Precondition: a non-MARC Authority match profile, MARC bib 010 to 010 $a
    * def recordType = 'MARC_BIBLIOGRAPHIC'
    * def matchProfileName = 'FAT-28854 bib match ' + runId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(matchProfileName)",
          "description": "",
          "incomingRecordType": "#(recordType)",
          "existingRecordType": "#(recordType)",
          "matchDetails": [{
            "matchCriterion": "EXACTLY_MATCHES",
            "incomingRecordType": "#(recordType)",
            "existingRecordType": "#(recordType)",
            "incomingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" },
            "existingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" }
          }]
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def bibMatchProfileId = $.id

    # Precondition: a non-Delete action profile - "Update MARC authority"
    * def mappingProfileName = 'FAT-28854 update MARC authority mapping ' + runId
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "description": "",
          "incomingRecordType": "MARC_AUTHORITY",
          "existingRecordType": "MARC_AUTHORITY",
          "mappingDetails": { "name": "marcAuthority", "recordType": "MARC_AUTHORITY", "mappingFields": [], "marcMappingDetails": [], "marcMappingOption": "UPDATE" }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    * def actionProfileName = 'FAT-28854 update MARC authority ' + runId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": { "name": "#(actionProfileName)", "description": "", "action": "UPDATE", "folioRecord": "MARC_AUTHORITY" },
        "addedRelations": [{ "masterProfileId": null, "masterProfileType": "ACTION_PROFILE", "detailProfileId": "#(mappingProfileId)", "detailProfileType": "MAPPING_PROFILE", "order": 0 }],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def updateAuthorityActionProfileId = $.id

    # The job profile layouts built across the steps
    * def deleteWithoutMatch = ([jobToActionRelation(defaultDeleteAuthorityActionProfileId)])
    * def updateThenDeleteForMatches = ([jobToMatchRelation(authorityMatchProfileId), matchToActionRelation(authorityMatchProfileId, updateAuthorityActionProfileId, 'MATCH', 0), matchToActionRelation(authorityMatchProfileId, defaultDeleteAuthorityActionProfileId, 'MATCH', 1)])
    * def deleteForNonMatches = ([jobToMatchRelation(authorityMatchProfileId), matchToActionRelation(authorityMatchProfileId, updateAuthorityActionProfileId, 'MATCH', 0), matchToActionRelation(authorityMatchProfileId, defaultDeleteAuthorityActionProfileId, 'NON_MATCH', 0)])
    * def deleteUnderBibMatch = ([jobToMatchRelation(bibMatchProfileId), matchToActionRelation(bibMatchProfileId, defaultDeleteAuthorityActionProfileId, 'MATCH', 0)])
    * def deleteUnderAuthorityMatch = ([jobToMatchRelation(authorityMatchProfileId), matchToActionRelation(authorityMatchProfileId, defaultDeleteAuthorityActionProfileId, 'MATCH', 0)])

    * def jobProfileName = 'FAT-28854 delete job profile ' + runId
    * def newJobProfile = { name: '#(jobProfileName)', description: '', dataType: 'MARC' }
    * def countJobProfiles = function() { return karate.call(settingsCommon + '@CountJobProfilesByName', { name: jobProfileName, headersUser: headersUser }).totalRecords }

    # Steps 1-2: "Default - Delete MARC Authority records" directly in the Overview, no match profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: '#(newJobProfile)', addedRelations: '#(deleteWithoutMatch)', deletedRelations: [] }
    When method POST
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match countJobProfiles() == 0

    # Steps 3-5: "Update MARC authority" and then "Default - Delete MARC Authority records" in the for-matches branch
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: '#(newJobProfile)', addedRelations: '#(updateThenDeleteForMatches)', deletedRelations: [] }
    When method POST
    Then status 422
    And match response.errors[*].message contains nextToOtherActionsMessage
    And match countJobProfiles() == 0

    # Steps 6-7: "Update MARC authority" in the for-matches branch, "Default - Delete MARC Authority records" in the for-non-matches branch
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: '#(newJobProfile)', addedRelations: '#(deleteForNonMatches)', deletedRelations: [] }
    When method POST
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match countJobProfiles() == 0

    # Steps 9-10: "Default - Delete MARC Authority records" in the for-matches branch of a non-MARC Authority match profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: '#(newJobProfile)', addedRelations: '#(deleteUnderBibMatch)', deletedRelations: [] }
    When method POST
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match countJobProfiles() == 0

    # Step 11: "Default - Delete MARC Authority records" in the for-matches branch of a MARC Authority match profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: '#(newJobProfile)', addedRelations: '#(deleteUnderAuthorityMatch)', deletedRelations: [] }
    When method POST
    Then status 201
    * def jobProfileId = response.id
    # The saved associations, which an edit has to name in deletedRelations to replace the layout
    * def savedRelations = response.addedRelations
    And match countJobProfiles() == 1

    # Step 12: repeat steps 1-11 editing the created job profile
    * def editedJobProfile = { id: '#(jobProfileId)', name: '#(jobProfileName)', description: '', dataType: 'MARC' }
    * def getJobProfileLayout = function() { return karate.call(settingsCommon + '@GetJobProfileLayout', { jobProfileId: jobProfileId, headersUser: headersUser }).layout }
    * def savedLayout = getJobProfileLayout()
    And match savedLayout == { matchProfileId: '#(authorityMatchProfileId)', actions: [{ actionProfileId: '#(defaultDeleteAuthorityActionProfileId)', reactTo: 'MATCH' }] }

    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    And request { profile: '#(editedJobProfile)', addedRelations: '#(deleteWithoutMatch)', deletedRelations: '#(savedRelations)' }
    When method PUT
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match getJobProfileLayout() == savedLayout

    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    And request { profile: '#(editedJobProfile)', addedRelations: '#(updateThenDeleteForMatches)', deletedRelations: '#(savedRelations)' }
    When method PUT
    Then status 422
    And match response.errors[*].message contains nextToOtherActionsMessage
    And match getJobProfileLayout() == savedLayout

    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    And request { profile: '#(editedJobProfile)', addedRelations: '#(deleteForNonMatches)', deletedRelations: '#(savedRelations)' }
    When method PUT
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match getJobProfileLayout() == savedLayout

    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    And request { profile: '#(editedJobProfile)', addedRelations: '#(deleteUnderBibMatch)', deletedRelations: '#(savedRelations)' }
    When method PUT
    Then status 422
    And match response.errors[*].message contains invalidPlacementMessage
    And match getJobProfileLayout() == savedLayout

    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    And request { profile: '#(editedJobProfile)', addedRelations: '#(deleteUnderAuthorityMatch)', deletedRelations: '#(savedRelations)' }
    When method PUT
    Then status 200
    And match getJobProfileLayout() == savedLayout

  @C1453731
  Scenario: Job profile with Delete MARC Authority action correctly placed in for-matches branch is accepted
    # Precondition: a MARC Authority to MARC Authority match profile, 010 to 010 $a
    * def recordType = 'MARC_AUTHORITY'
    * def matchProfileName = 'FAT-28854 authority match ' + runId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(matchProfileName)",
          "description": "",
          "incomingRecordType": "#(recordType)",
          "existingRecordType": "#(recordType)",
          "matchDetails": [{
            "matchCriterion": "EXACTLY_MATCHES",
            "incomingRecordType": "#(recordType)",
            "existingRecordType": "#(recordType)",
            "incomingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" },
            "existingMatchExpression": { "dataValueType": "VALUE_FROM_RECORD", "fields": "#(matchPoint010a)" }
          }]
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileId = $.id

    # Steps 1-2: MARC Authority match with "Default - Delete MARC Authority records" in the for-matches branch
    * def jobProfileName = 'FAT-28854 delete for matches ' + runId
    * def relations = ([jobToMatchRelation(matchProfileId), matchToActionRelation(matchProfileId, defaultDeleteAuthorityActionProfileId, 'MATCH', 0)])
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request { profile: { name: '#(jobProfileName)', description: '', dataType: 'MARC' }, addedRelations: '#(relations)', deletedRelations: [] }
    When method POST
    Then status 201

    # The new job profile is visible in the Job profiles list
    Given path 'data-import-profiles/jobProfiles'
    And param query = 'name=="' + jobProfileName + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.jobProfiles[0].name == jobProfileName
