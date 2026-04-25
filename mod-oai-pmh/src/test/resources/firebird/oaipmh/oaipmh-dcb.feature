@parallel=false
Feature: Test DCB instance and holdings

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    #=========================SETUP=================================================
    * call resetConfiguration
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Add DCB instance and holdings
    * url baseUrl
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    * def instance = read('classpath:samples/dcb_instance.json')
    And request instance
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    * def holding = read('classpath:samples/dcb_holdings.json')
    And request holding
    When method POST
    Then status 201

  Scenario: Set records source to Inventory
    * def recordsSourceConfig = "Inventory"
    * call read('classpath:firebird/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * def valueTemplateString = valueTemplate
    * print 'valueTemplateDcb=', valueTemplate
    * call read('classpath:firebird/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}

  Scenario: Get GetRecord request for DCB instance with marc21_withholdings metadata prefix
    * url pmhUrl
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/9d1b77e4-f02e-4b7f-b296-3f2042ddac54'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def responseString = karate.toString(response)
    And match responseString contains 'No matching identifier in repository.'

  Scenario: Get GetRecord request for DCB instance with marc21 metadata prefix
    * url pmhUrl
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/9d1b77e4-f02e-4b7f-b296-3f2042ddac54'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def responseString = karate.toString(response)
    And match responseString contains 'No matching identifier in repository.'

  Scenario: Get ListRecords request for DCB instance with marc21_withholdings metadata prefix
    * url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def listRecordsNode = karate.xmlPath(response, '//*[local-name()="ListRecords"]')
    * def listRecordsString = karate.toString(listRecordsNode)
    And match listRecordsString !contains '9d1b77e4-f02e-4b7f-b296-3f2042ddac54'
    And match listRecordsString !contains 'DCB'

  Scenario: Get ListRecords request for DCB instance with marc21 metadata prefix
    * url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def listRecordsNode = karate.xmlPath(response, '//*[local-name()="ListRecords"]')
    * def listRecordsString = karate.toString(listRecordsNode)
    And match listRecordsString !contains '9d1b77e4-f02e-4b7f-b296-3f2042ddac54'
    And match listRecordsString !contains 'DCB'
