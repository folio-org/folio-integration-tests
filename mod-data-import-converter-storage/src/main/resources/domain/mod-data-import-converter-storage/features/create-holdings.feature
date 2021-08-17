Feature: Create profile for CREATE Holdings

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }
    * configure headers = headersUser

  Scenario: Create MARC-to-Holdings

    ## Create mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And request
      """
      {
        "profile": {
          "name": "Holdings Mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE"
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    ## Create action profile
    Given path '/data-import-profiles/actionProfiles'
    And request
      """
       {
          "profile": {
            "name": "Holdings action profile",
            "description": "",
            "action": "CREATE",
            "folioRecord": "HOLDINGS"
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

    ##Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And request
      """
      {
        "profile": {
          "name": "Holdings job profile",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
        {
          "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(actionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def jobProfileId = $.id

    ##Delete job profile
    Given path 'data-import-profiles/jobProfiles', jobProfileId
    When method DELETE
    Then status 204

    ##Delete action profile
    Given path 'data-import-profiles/actionProfiles', actionProfileId
    When method DELETE
    Then status 204

    ##Delete mapping profile
    Given path 'data-import-profiles/mappingProfiles', mappingProfileId
    When method DELETE
    Then status 204