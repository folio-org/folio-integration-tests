Feature: Setup MARC-to-MARC Update Job Profile

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: Create job profile for MARC-MARC record replacement/overlay
    * def profileName = __arg.profileName

    # Create MARC-to-MARC mapping profile with UPDATE action
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "MARC_BIBLIOGRAPHIC",
          "description": "MARC-to-MARC update mapping profile for record replacement/overlay",
          "mappingDetails": {
            "name": "marcBib",
            "recordType": "MARC_BIBLIOGRAPHIC",
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

    # Create action profile with UPDATE action
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "action": "UPDATE",
          "folioRecord": "MARC_BIBLIOGRAPHIC",
          "description": "Action profile for MARC-MARC update"
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

    # Create match profile for MARC-MARC matching
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "description": "MARC-MARC match profile by 999ff$i",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [ {
            "incomingRecordType" : "MARC_BIBLIOGRAPHIC",
            "existingRecordType" : "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression" : {
              "dataValueType" : "VALUE_FROM_RECORD",
              "fields" : [ {
                "label" : "field",
                "value" : "999"
              }, {
                "label" : "indicator1",
                "value" : "f"
              }, {
                "label" : "indicator2",
                "value" : "f"
              }, {
                "label" : "recordSubfield",
                "value" : "i"
              } ]
            },
            "existingMatchExpression" : {
              "dataValueType" : "VALUE_FROM_RECORD",
              "fields" : [ {
                "label" : "field",
                "value" : "999"
              }, {
                "label" : "indicator1",
                "value" : "f"
              }, {
                "label" : "indicator2",
                "value" : "f"
              }, {
                "label" : "recordSubfield",
                "value" : "i"
              } ]
            },
            "matchCriterion" : "EXACTLY_MATCHES"
          } ]
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "description": "Job profile for MARC-MARC record replacement/overlay",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(matchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(actionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def updateJobProfileId = $.id
