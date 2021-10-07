Feature: Data Import integration tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * def randomNumber = callonce random

  Scenario: FAT-940 Match MARC-to-MARC and update Instances, Holdings, and Items 2
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
{
  "profile": {
    "name": "FAT-940: MARC-to-Instance mapping profile",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "INSTANCE",
    "description": "",
    "mappingDetails": {
      "name": "instance",
      "recordType": "INSTANCE",
      "mappingFields": [
        {
          "name": "staffSuppress",
          "enabled": true,
          "path": "instance.staffSuppress",
          "value": "",
          "subfields": [],
          "booleanFieldAction": "ALL_TRUE"
        },
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
                  "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                  "acceptedValues": {
                    "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
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

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
{
  "profile": {
    "name": "FAT-940: MARC-to-Holdings mapping profile",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "HOLDINGS",
    "description": "",
    "mappingDetails": {
      "name": "holdings",
      "recordType": "HOLDINGS",
      "mappingFields": [
        {
          "name": "formerIds",
          "enabled": true,
          "path": "holdings.formerIds[]",
          "value": "",
          "subfields": [],
          "repeatableFieldAction": "DELETE_EXISTING"
        },
        {
          "name": "statisticalCodeIds",
          "enabled": true,
          "path": "holdings.statisticalCodeIds[]",
          "value": "",
          "subfields": [],
          "repeatableFieldAction": "DELETE_EXISTING"
        },
        {
          "name": "shelvingTitle",
          "enabled": true,
          "path": "holdings.shelvingTitle",
          "value": "\"test\"",
          "subfields": []
        },
        {
          "name": "callNumberPrefix",
          "enabled": true,
          "path": "holdings.callNumberPrefix",
          "value": "\"test\"",
          "subfields": []
        },
        {
          "name": "callNumberSuffix",
          "enabled": true,
          "path": "holdings.callNumberSuffix",
          "value": "\"test\"",
          "subfields": []
        },
        {
          "name": "retentionPolicy",
          "enabled": true,
          "path": "holdings.retentionPolicy",
          "value": "\"test\"",
          "subfields": []
        },
        {
          "name": "notes",
          "enabled": true,
          "path": "holdings.notes[]",
          "value": "",
          "subfields": [
            {
              "order": 0,
              "path": "holdings.notes[]",
              "fields": [
                {
                  "name": "noteType",
                  "enabled": true,
                  "path": "holdings.notes[].holdingsNoteTypeId",
                  "value": "\"Action note\"",
                  "acceptedValues": {
                    "d6510242-5ec3-42ed-b593-3585d2e48fd6": "Action note"
                  }
                },
                {
                  "name": "note",
                  "enabled": true,
                  "path": "holdings.notes[].note",
                  "value": "\"some notes\""
                },
                {
                  "name": "staffOnly",
                  "enabled": true,
                  "path": "holdings.notes[].staffOnly",
                  "value": null,
                  "booleanFieldAction": "ALL_TRUE"
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

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
//TODO
    """
    When method POST
    Then status 201

    * def marcToItemMappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
//TODO
    """
    When method POST
    Then status 201

    * def marcBibActionProfileId = $.id

    ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: Update Instance action profile",
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

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
"""
# TODO need to validate
"""
    When method POST
    Then status 201

    * def jobProfileId = $.id

    ## Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
"""
//TODO
"""
    When method POST
    Then status 201
    And match $.status == 'NEW'

    * def fileDefinitionId = $.id

    ## Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:domain/data-import/samples/FAT-939.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

    ## Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    ## Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    ##should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
"""
{
"fileDefinitionId": "#(fileDefinitionId)",
"jobProfileId": "#(defaultJobProfileId)"
}
"""
    When method POST
    Then status 204

    ## Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    ## Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200

    * def downloadLink = $.link

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200