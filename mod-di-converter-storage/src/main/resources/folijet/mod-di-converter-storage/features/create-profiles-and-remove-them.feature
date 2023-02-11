Feature: Create job profile for CREATE

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }
    * configure headers = headersUser

  Scenario: Create Job Profile for create Instance, Holdings, Item
  .
    ## Create mapping profile for Instance
    Given path 'data-import-profiles/mappingProfiles'
    And request
      """
      {
        "profile": {
          "name": "Instance Mapping profile FAT-936",
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

    * def mappingProfileInstanceId = $.id

    ## Create action profile for Instance
    Given path 'data-import-profiles/actionProfiles'
    And request
      """
      {
        "profile": {
         "name": "Instance action profile FAT-936",
          "description": "",
          "action": "CREATE",
          "folioRecord": "INSTANCE"
        },
        "addedRelations": [
          {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileInstanceId)",
          "detailProfileType": "MAPPING_PROFILE"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def actionProfileInstanceId = $.id

    ## Create mapping profile for Holdings
    Given path 'data-import-profiles/mappingProfiles'
    And request
      """
      {
        "profile": {
          "name": "Holdings Mapping profile FAT-936",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
          "name": "instance",
          "recordType": "HOLDINGS"
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def mappingProfileHoldingsId = $.id

    ## Create action profile for Holdings
    Given path '/data-import-profiles/actionProfiles'
    And request
      """
       {
          "profile": {
            "name": "Holdings action profile FAT-936",
            "description": "",
            "action": "CREATE",
            "folioRecord": "HOLDINGS"
          },
          "addedRelations": [
          {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileHoldingsId)",
          "detailProfileType": "MAPPING_PROFILE"
          }
          ],
          "deletedRelations": []
       }
      """
    When method POST
    Then status 201

    * def actionProfileHoldingsId = $.id

    ## Create mapping profile for Item
    Given path 'data-import-profiles/mappingProfiles'
    And request
      """
      {
        "profile": {
          "name": "Item Mapping profile FAT-936",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "ITEM",
          "description": "",
          "mappingDetails": {
          "name": "instance",
          "recordType": "ITEM"
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def mappingProfileItemId = $.id

    ## Create action profile for Item
    Given path 'data-import-profiles/actionProfiles'
    And request
      """
      {
      "profile": {
         "name": "Item action profile FAT-936",
         "description": "",
         "action": "CREATE",
         "folioRecord": "ITEM"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "ACTION_PROFILE",
            "detailProfileId": "#(mappingProfileItemId)",
            "detailProfileType": "MAPPING_PROFILE"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def actionProfileItemId = $.id

    ##Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And request
      """
      {
        "profile": {
          "name": "Job profile FAT-936",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(actionProfileInstanceId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(actionProfileHoldingsId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(actionProfileItemId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 2
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
    Given path 'data-import-profiles/actionProfiles', actionProfileInstanceId
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/actionProfiles', actionProfileHoldingsId
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/actionProfiles', actionProfileItemId
    When method DELETE
    Then status 204

    ##Delete mapping profile
    Given path 'data-import-profiles/mappingProfiles', mappingProfileInstanceId
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/mappingProfiles', mappingProfileHoldingsId
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/mappingProfiles', mappingProfileItemId
    When method DELETE
    Then status 204