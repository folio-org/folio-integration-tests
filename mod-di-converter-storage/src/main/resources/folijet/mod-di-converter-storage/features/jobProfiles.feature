Feature: Job Profiles

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*' }
    * configure headers = headersUser

  Scenario: Get all profiles
    Given path 'data-import-profiles', 'jobProfiles'
    When method GET
    Then status 200

  Scenario: Build Profile Snapshot Wrapper POST on /data-import-profiles/jobProfileSnapshots/{profileId}
    * print 'Create mapping, action, match and job profiles, link them accordingly, build profile snapshot wrapper, verify it is successful'

    ## Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Modify MARC Bib",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "MARC_BIBLIOGRAPHIC",
        "description": "",
        "mappingDetails": {
          "name": "marcBib",
          "recordType": "MARC_BIBLIOGRAPHIC",
          "marcMappingDetails": [
            {
              "order": 0,
              "field": {
                "subfields": [
                  {
                    "subaction": "ADD_SUBFIELD",
                    "data": {
                      "text": "Test"
                    },
                    "subfield": "a"
                  },
                  {
                    "subfield": "b",
                    "data": {
                      "text": "Addition"
                    }
                  }
                ],
                "field": "947"
              },
              "action": "ADD"
            }
          ],
          "marcMappingOption": "MODIFY"
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Modify MARC bib",
        "description": "",
        "action": "MODIFY",
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
    Then status 201

    * def actionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: MARC-to-MARC 001 to 001",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def matchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Job profile",
        "description": "",
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

    ## Create profile snapshot wrapper
    Given path '/data-import-profiles/jobProfileSnapshots', jobProfileId
    When method POST
    Then status 201

    * def snapshotProfileId = $.id

    ## Create profile snapshot wrapper
    Given path '/data-import-profiles/jobProfileSnapshots', snapshotProfileId
    When method GET
    Then status 200
    And assert response.contentType == 'JOB_PROFILE'

  Scenario: Should no build profile with static match as primary match
    * print 'Create mapping and action profile, then create match profile with match on static value and try to assemble them in job profile'

    ## Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Modify MARC Bib FAT-136",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "MARC_BIBLIOGRAPHIC",
        "description": "",
        "mappingDetails": {
          "name": "marcBib",
          "recordType": "MARC_BIBLIOGRAPHIC",
          "marcMappingDetails": [
            {
              "order": 0,
              "field": {
                "subfields": [
                  {
                    "subaction": "ADD_SUBFIELD",
                    "data": {
                      "text": "Test"
                    },
                    "subfield": "a"
                  },
                  {
                    "subfield": "b",
                    "data": {
                      "text": "Addition"
                    }
                  }
                ],
                "field": "947"
              },
              "action": "ADD"
            }
          ],
          "marcMappingOption": "MODIFY"
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Modify MARC bib FAT-136",
        "description": "",
        "action": "MODIFY",
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
    Then status 201

    * def actionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And request
    """
    {
      "profile": {
        "name": "MARC-to-MARC 001 to 001 FAT-136",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def matchProfileId = $.id

    ## Create match profile with static value
    Given path 'data-import-profiles/matchProfiles'
    And request
    """
    {
      "profile": {
      "description": "",
        "incomingRecordType": "STATIC_VALUE",
        "matchDetails": [
          {
            "incomingRecordType": "STATIC_VALUE",
            "incomingMatchExpression": {
              "staticValueDetails": {
                "staticValueType": "TEXT",
                "text": "Testing static value",
                "number": "",
                "exactDate": "",
                "fromDate": "",
                "toDate": ""
              },
              "dataValueType": "STATIC_VALUE"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "name": "Static value match profile FAT-136",
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def staticMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Job profile for static value FAT-136",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(staticMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
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

  Scenario: Throw validation exception when modify action is used right after a match
    * print 'Create mapping, action, match and job profiles, link them accordingly, throw validation exception'

    ## Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Modify MARC Bib validation error",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "MARC_BIBLIOGRAPHIC",
        "description": "",
        "mappingDetails": {
          "name": "marcBib",
          "recordType": "MARC_BIBLIOGRAPHIC",
          "marcMappingDetails": [
            {
              "order": 0,
              "field": {
                "subfields": [
                  {
                    "subaction": "ADD_SUBFIELD",
                    "data": {
                      "text": "Test"
                    },
                    "subfield": "a"
                  },
                  {
                    "subfield": "b",
                    "data": {
                      "text": "Addition"
                    }
                  }
                ],
                "field": "947"
              },
              "action": "ADD"
            }
          ],
          "marcMappingOption": "MODIFY"
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Modify MARC bib validation error",
        "description": "",
        "action": "MODIFY",
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
    Then status 201

    * def actionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: MARC-to-MARC 001 to 001 validation error",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def matchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Job profile validation error",
        "description": "",
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
    Then status 422
    And assert response.errors[0].message == 'Modify action cannot be used right after a Match'

  Scenario: Throw validation exception when modify action is used as standalone action
    * print 'Create mapping, action and job profiles, link them accordingly, throw validation exception'

    ## Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-13540: Modify MARC Bib validation error",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "MARC_BIBLIOGRAPHIC",
        "description": "",
        "mappingDetails": {
          "name": "marcBib",
          "recordType": "MARC_BIBLIOGRAPHIC",
          "marcMappingDetails": [
            {
              "order": 0,
              "field": {
                "subfields": [
                  {
                    "subaction": "ADD_SUBFIELD",
                    "data": {
                      "text": "Test"
                    },
                    "subfield": "a"
                  },
                  {
                    "subfield": "b",
                    "data": {
                      "text": "Addition"
                    }
                  }
                ],
                "field": "947"
              },
              "action": "ADD"
            }
          ],
          "marcMappingOption": "MODIFY"
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-13540: Modify MARC bib validation error",
        "description": "",
        "action": "MODIFY",
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
    Then status 201

    * def actionProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-136: Job profile validation error",
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
    Then status 422
    And assert response.errors[0].message == 'Modify action cannot be used as a standalone action'

  Scenario: FAT-13630_1 Validation of Job Profiles without child profiles
    * print 'Create Job profile without child profiles'
    # Create job profile
    * def jobProfileName = "FAT-13630_1: Job profile create"
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 422
    And match response.errors[0].message == 'Job profile does not contain any associations'

  Scenario: FAT-13630_2 Validation of Job Profiles without action profile

    * print 'Create Job profile with match profile which does not contain any action profiles'
    # Create match profile for MARC-to-MARC 010$z field to 010$z field
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13630_2: MARC-to-MARC",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": "z"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "MARC_BIBLIOGRAPHIC",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": "z"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "MARC_BIBLIOGRAPHIC"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileId = $.id

     # Create job profile
    * def jobProfileUpdateName = "FAT-13630_2: Job profile"
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileUpdateName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 422
    And match response.errors[0].message == 'Linked ActionProfile was not found after MatchProfile'

  Scenario: FAT-13630_3 Validation Update Job Profile remove action profile from match profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13630_3: MARC-to-Instance",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": [
              {
                "name": "statisticalCodeIds",
                "enabled": true,
                "path": "instance.statisticalCodeIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "instance.statisticalCodeIds[]",
                    "fields": [
                      {
                        "name": "statisticalCodeId",
                        "enabled": true,
                        "path": "instance.statisticalCodeIds[]",
                        "value": "\"ARL (Collection stats): rmusic - Music sound recordings\"",
                        "acceptedValues": {
                          "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings"
                        }
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def marcToInstanceMappingProfileId = $.id

    # Create action profile for UPDATE Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13630_3: Action Profile",
          "description": "",
          "action": "UPDATE",
          "folioRecord": "INSTANCE"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "ACTION_PROFILE",
            "detailProfileId": "#(marcToInstanceMappingProfileId)",
            "detailProfileType": "MAPPING_PROFILE"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13630_3: Match Profile",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": "z"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields" : [ {
                  "label" : "field",
                  "value" : "instance.identifiers[].value"
                }, {
                  "label" : "identifierTypeId",
                  "value" : "c858e4f2-2b6b-4385-842b-60532ee34abb"
                } ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "INSTANCE"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def instanceMatchProfileId = $.id

    # Create job profile
    * def jobProfileUpdateName = "FAT-13630_3: Job profile"
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileUpdateName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    # Update job profile
    * print 'Update Job profile with remove action profile'
    Given path 'data-import-profiles/jobProfiles', updateJobProfileId
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-13630_3: Job profile update",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [],
      "deletedRelations": [
      {
        "detailProfileId": "fa45f3ec-9b83-11eb-a8b3-0242ac130003",
        "detailProfileType": "ACTION_PROFILE",
        "masterProfileType": "MATCH_PROFILE",
        "masterProfileId": "#(instanceMatchProfileId)"
      }]
    }
    """
    When method PUT
    Then status 422
    And match response.errors[1].message == 'Linked ActionProfile was not found after MatchProfile'

  Scenario: FAT-13630_4 Validation of Job Profiles without actions
    # Create job profile
    * print 'Create Job profile with action profile'
    * def jobProfileName = "FAT-13630_4: Job profile"
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [{
          "detailProfileId": "fa45f3ec-9b83-11eb-a8b3-0242ac130003",
          "detailProfileType": "ACTION_PROFILE",
          "masterProfileType": "JOB_PROFILE"
        }],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def updateJobProfileId = $.id

    # Update job profile
    * print 'Update Job profile with remove action profile'
    * def jobProfileName = "FAT-13630_2: Job profile"
    Given path 'data-import-profiles/jobProfiles', updateJobProfileId
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-13630_4: Job profile update",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [],
      "deletedRelations": [
      {
        "detailProfileId": "fa45f3ec-9b83-11eb-a8b3-0242ac130003",
        "detailProfileType": "ACTION_PROFILE",
        "masterProfileType": "JOB_PROFILE",
        "masterProfileId": "#(updateJobProfileId)"
      }]
    }
    """
    When method PUT
    Then status 422
    And match response.errors[0].message == 'Job profile does not contain any associations'
