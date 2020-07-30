Feature: Test new oai-pmh functionality

  Background:
    * def pmhUrl = baseUrl +'/oai/records'
    * url pmhUrl
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/xml', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario Outline: set errors to 200 and 500 and check Http status in responses <errorCode>
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200
    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
       "module" : "OAIPMH",
       "configName" : "behavior",
       "enabled" : true,
       "value" : "{\"deletedRecordsSupport\":\"no\",\"suppressedRecordsProcessing\":\"false\",\"errorsProcessing\":\"<errorCode>\"}"
    }
    """
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc'
    When method GET
    Then status <httpStatus>

    Examples:
      | errorCode | httpStatus |
      | 200       | 200        |
      | 500       | 422        |

  Scenario Outline: check enable and disable OAI service
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==general'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "module" : "OAIPMH",
      "configName" : "general",
      "enabled" : true,
      "value" : "{\"administratorEmail\":\"oai-pmh@folio.org\",\"repositoryName\":\"FOLIO_OAI_Repository\",\"enableOaiService\":\"<enableOAIService>\",\"timeGranularity\":\"YYYY-MM-DDThh:mm:ssZ\",\"baseUrl\":\"http://folio.org/oai\"}"
    }
    """
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status <httpStatus>

    Examples:
      | enableOAIService | httpStatus |
      | false            | 503        |
      | true             | 200        |

  Scenario: get ListRecords for marc21_withholdings
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 200

  Scenario: get ListIdentifiers for marc21_withholdings
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 200

  Scenario: get GetRecord request for marc21_withholdings
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:test_oaipmh/6b4ae089-e1ee-431f-af83-e1133f8e3da0'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 200

    # Unhappy path cases

  Scenario: check badArgument in GetRecord request without identifier for marc21_withholdings
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 400

  Scenario: check badArgument in GetRecord request with invalid identifier for marc21_withholdings
    And param verb = 'GetRecord'
    And param identifier = 'invalid'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 400

  Scenario: check badArgument in ListRecords with invalid from for marc21_withholdings
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument in ListRecords with invalid resumptionToken for marc21_withholdings
    And param verb = 'ListRecords'
    And param resumptionToken = 'junk'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 400

  Scenario: check badArgument in ListRecords with invalid until for marc21_withholdings
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param until = 'junk'
    When method GET
    Then status 400

    #Checking for version 2.0 specific exceptions

  Scenario: check badArgument in ListRecords with invalid format date for marc21_withholdings
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = '2002-02-05'
    And param until = '2002-02-06T05:35:00Z'
    When method GET
    Then status 400

  Scenario: check noRecordsMatch in ListRecords request for marc21_withholdings
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param until = '1969-01-01T00:00:00Z'
    When method GET
    Then status 404

  Scenario: check idDoesNotExist error in GetRecord request for marc21_withholdings
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:test_oaipmh/777be1ac-5073-44cc-9925-a6b8955f4a75'
    And param metadataPrefix = 'marc21_withholdings'
    When method GET
    Then status 404

  Scenario: get resumptionToken and make responses until resumptionToken is present
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==technical'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And request
    """
    {
        "module" : "OAIPMH",
        "configName" : "technical",
        "enabled" : true,
        "value" : "{\"maxRecordsPerResponse\": \"4\",\"enableValidation\":\"false\",\"formattedOutput\":\"false\"}"
    }
    """
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    When method GET
    Then status 200
    Then match response //resumptionToken[@completeListSize='10'] == '#notnull'
    * match response //resumptionToken[@cursor='0'] == '#notnull'

    * def resumptionToken = get response //resumptionToken

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    When method GET
    Then status 200
    * match response //resumptionToken[@cursor='4'] == '#notnull'

    * def resumptionToken2 = get response //resumptionToken

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken2
    When method GET
    Then status 200
    * match response //resumptionToken[@cursor='8'] == '#notnull'

  Scenario: one record has field leader which marked as deleted and record is not displayed because config "deletedRecordsSupport" is "no"
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==technical'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
        "module" : "OAIPMH",
        "configName" : "technical",
        "enabled" : true,
        "value" : "{\"maxRecordsPerResponse\": \"100\",\"enableValidation\":\"false\",\"formattedOutput\":\"false\"}"
    }
    """
    When method PUT
    Then status 204

    Given path 'source-storage/records'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = 'aa1df976-bb70-11ea-b3de-0242ac130004'
    * set record.externalIdsHolder.instanceId = 'b1fa21b0-bb70-11ea-b3de-0242ac130004'
    * set record.matchedId = 'b97e1068-bb70-11ea-b3de-0242ac130004'
    * set record.parsedRecord.content.leader = '01542xcm a2200361   4500'
    And request record
    When method POST
    Then status 201

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    When method GET
    Then status 200
    * match response count(//record) == 10

  Scenario: set suppressDiscovery to true and record is absent in response
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = 'ccc35ac6-bb8d-11ea-b3de-0242ac130004'
    * set record.externalIdsHolder.instanceId = 'e900266a-bb8d-11ea-b3de-0242ac130004'
    * set record.matchedId = 'f41cad98-bb8d-11ea-b3de-0242ac130004'
    * set record.additionalInfo.suppressDiscovery = true
    And request record
    When method POST
    Then status 201

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    When method GET
    Then status 200
    * match response count(//record) == 10

  Scenario: set config "deletedRecordsSupport" to "transient" and find record marked as deleted by header with status = deleted in response
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200
    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And request
    """
    {
       "module" : "OAIPMH",
       "configName" : "behavior",
       "enabled" : true,
       "value" : "{\"deletedRecordsSupport\":\"transient\",\"suppressedRecordsProcessing\":\"false\",\"errorsProcessing\":\"200\"}"
    }
    """
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    When method GET
    Then status 200
    * match response count(//record) == 11
    * match response //header[@status='deleted'] == '#notnull'

  Scenario: record marc as deleted and suppressDiscovery is true and config "suppressedRecordsProcessing" is true
    Given url baseUrl
    And path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And request
    """
    {
       "module" : "OAIPMH",
       "configName" : "behavior",
       "enabled" : true,
       "value" : "{\"deletedRecordsSupport\":\"transient\",\"suppressedRecordsProcessing\":\"true\",\"errorsProcessing\":\"500\"}"
    }
    """
    When method PUT
    Then status 204

    Given path 'source-storage/records'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = '1ae24758-bb9d-11ea-b3de-0242ac130004'
    * set record.externalIdsHolder.instanceId = '2aa223a2-bb9d-11ea-b3de-0242ac130004'
    * set record.matchedId = '32f8b160-bb9d-11ea-b3de-0242ac130004'
    * set record.parsedRecord.content.leader = '01542dcm a2200361   4500'
    * set record.additionalInfo.suppressDiscovery = true
    And request record
    When method POST
    Then status 201

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    When method GET
    Then status 200
    * match response count(//record) == 13
    * match response count(//header[@status='deleted']) == 2
