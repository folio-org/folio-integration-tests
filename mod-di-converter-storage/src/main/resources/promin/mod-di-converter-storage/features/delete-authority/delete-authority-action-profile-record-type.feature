@parallel=false
Feature: Settings - Delete action profile is only allowed for MARC Authority

  # UXPROD-4627 - delete authority records via data import.
  # An action profile with the DELETE action can only be created for the MARC Authority record type.

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Identifies everything this run creates, so parallel runs and re-runs never collide on profile names
    * def runId = randomMillis() + random_string()

  @C1453730
  Scenario: Action profile creation is rejected when Delete action is used with non-MARC Authority record type
    # Precondition: an "Update MARC bibliographic record" field mapping profile, MARC bibliographic to MARC bibliographic with Update action
    * def mappingProfileName = 'FAT-28854 update MARC bibliographic record ' + runId
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "MARC_BIBLIOGRAPHIC",
          "mappingDetails": {
            "name": "marcBib",
            "recordType": "MARC_BIBLIOGRAPHIC",
            "mappingFields": [],
            "marcMappingDetails": [{ "order": 0, "field": { "field": "010", "indicator1": "*", "indicator2": "*", "subfields": [{ "subfield": "*" }] } }],
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

    # Step 1: POST a DELETE action profile for MARC_BIBLIOGRAPHIC linked to the mapping profile
    * def actionProfileName = 'Delete MARC authority records test3 ' + runId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(actionProfileName)",
          "description": "",
          "action": "DELETE",
          "folioRecord": "MARC_BIBLIOGRAPHIC"
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
    Then status 422
    # The Update mapping profile also breaks the action/mapping type rule, so only the Delete error is checked
    And match response.errors[*].message contains 'Action profile with DELETE action is only allowed for MARC_AUTHORITY record type'

    # The action profile is not created
    Given path 'data-import-profiles/actionProfiles'
    And param query = 'name=="' + actionProfileName + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0
