Feature: Test DataImport
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

  Scenario: Upload MARC file

    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "test.mrc"
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
    And request read('samples/test.mrc')
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200


   @Undefined
   Scenario: FAT-937 Upload MARC file and Create Instance, Holdings, Items
     * print 'Create JobProfile, upload file, check log'

   @Undefined
   Scenario: FAT-939 Modify MARC_Bib, update Instances, Holdings, and Items
     * print 'Match MARC-to-MARC, modify MARC_Bib and update Instance, Holdings, and Items'

   @Undefined
   Scenario: FAT-940 Match MARC-to-MARC and update Instances, Holdings, and Items
     * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

