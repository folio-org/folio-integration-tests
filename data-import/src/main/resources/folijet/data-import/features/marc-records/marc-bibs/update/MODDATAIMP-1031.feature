Feature: MODDATAIMP-1031

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario:  MODDATAIMP-1031 Modify action to remove 999 field and create Instance
    * print 'Modify action to remove 999 field and create Instance'

    # Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODDATAIMP-1031 remove 999 field",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "MARC_BIBLIOGRAPHIC",
          "mappingDetails": {
            "name": "marcBib",
            "recordType": "MARC_BIBLIOGRAPHIC",
            "mappingFields": [],
            "marcMappingDetails": [
              {
                "order": 0,
                "action": "DELETE",
                "field": {
                  "field": "999",
                  "indicator1": "*",
                  "indicator2": "*",
                  "subfields": [
                    {
                      "subfield": "*"
                    }
                  ]
                }
              }
            ],
            "marcMappingOption": "MODIFY"
          },
          "hidden": false,
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def marcToMarcMappingProfileId = $.id

    # Create action profile for MODIFY MARC bib
    * def mappingProfileEntityId = marcToMarcMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'MODIFY'
    * def folioRecord = 'MARC_BIBLIOGRAPHIC'
    * def userStoryNumber = 'MODDATAIMP-1031'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def marcBibActionProfileId = $.id

    # Create job profile - Modify MacrBib and create Instance
    * def defaultJActionProfileId = 'fa45f3ec-9b83-11eb-a8b3-0242ac130003'
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODDATAIMP-1031: Remove 999 and create instance",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(marcBibActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(defaultJActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Import file and create instance
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'MODDATAIMP-1031', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instances
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def sourceRecordId = response.entries[0].sourceRecordId
