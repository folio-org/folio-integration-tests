Feature: Test quickMARC

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    #waiting for all modules to be launched, this sleep allows to avoid creating a phantom instance in the mod-inventory
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * eval sleep(60000)

  Scenario: import MARC record
    ## Create instance type
    Given path 'instance-types',
    And headers headersUser
    And request
    """
    {
      "name" : "proceedings",
      "code" : "zzz",
      "source" : "rdacontent"
    }
    """
    When method post
    Then status 201

    ## Upload marc file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "summerland.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:domain/mod-quick-marc/features/setup/samples/summerland.mrc')
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = false
    And headers headersUser
    And request
    """
    {
      "uploadDefinition": '#(uploadDefinition)',
      "jobProfileInfo": {
        "id": "6409dcff-71fa-433a-bc6a-e70ad38a9604",
        "name": "CLI Create MARC Bibs and Instances",
        "dataType": "MARC"
      }
    }
    """
    When method post
    Then status 204

    ## Retrieve marc record
    Given path '/source-storage/source-records'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200