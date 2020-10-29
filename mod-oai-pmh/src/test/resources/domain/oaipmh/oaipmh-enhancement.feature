Feature: Test enhancements to oai-pmh

  Background:
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-oai-pmh'               |
      | 'mod-login'                 |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |

    * table userPermissions
      | name                    |
      | 'oai-pmh.all'           |
      | 'configuration.all'     |
      | 'inventory-storage.all' |
      | 'source-storage.all'    |

    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    * configure afterFeature =  function(){ karate.call(destroyData, {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * callonce read('classpath:common/setup-data.feature')
    #=========================SETUP=================================================
    * call resetConfiguration
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario Outline: set errors to 200 and 500 and check Http status in responses <errorCode>
    * def errorsProcessingConfig = <errorCode>
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}

    Given url pmhUrl
    And param verb = 'ListRecords'
    And header Accept = 'text/xml'
    # unsupported metadata prefix
    And param metadataPrefix = 'marc'
    When method GET
    Then status <httpStatus>

    Examples:
      | errorCode | httpStatus |
      | 200       | 200        |
      | 500       | 422        |

  Scenario Outline: check enable and disable OAI service <enableOAIService>
    * def enableOaiServiceConfig = <enableOAIService>
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = generalValue
    * string valueTemplateString = valueTemplate
    * print 'valueTemplate=', valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@GeneralConfig') {id: '#(generalId)', data: '#(valueTemplateString)'}

    Given url pmhUrl
    And param verb = 'ListRecords'
    And header Accept = 'text/xml'
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
    And header Accept = 'text/xml'
    When method GET
    Then status 200

  Scenario: get ListIdentifiers for marc21_withholdings
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200

  Scenario: get GetRecord request for marc21_withholdings
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:test_oaipmh/6b4ae089-e1ee-431f-af83-e1133f8e3da0'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
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
    # first set errors processing config to 500
    * def errorsProcessingConfig = '500'
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param until = '1969-01-01T00:00:00Z'
    And header Accept = 'text/xml'
    When method GET
    Then status 404

  Scenario: check idDoesNotExist error in GetRecord request for marc21_withholdings
     # first set errors processing config to 500
    * def errorsProcessingConfig = '500'
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}
    And param verb = 'GetRecord'
    * def idnfr = 'oai:folio.org:' + testTenant + '/777be1ac-5073-44cc-9925-a6b8955f4a75'
    And param identifier = idnfr
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 404

  Scenario Outline: get resumptionToken for ListRecords and make responses until resumptionToken is present for <prefix>
    # first set maxRecordsPerResponse config to 4
    * def maxRecordsPerResponseConfig = '4'
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = technicalValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@TechnicalConfig') {id: '#(technicalId)', data: '#(valueTemplateString)'}

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    Then match response //resumptionToken == '#notnull'
    * match response //resumptionToken == '#notnull'

    * def totalRecords = 0
    * def resumptionToken = get response //resumptionToken
    * def cnt = get response count(//record)
    * def totalRecords = addVariables(totalRecords, +cnt)
    * print 'current record count = ', cnt

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //resumptionToken == '#notnull'
    * def resumptionToken = get response //resumptionToken
    * def cnt = get response count(//record)
    * def totalRecords = addVariables(totalRecords, +cnt)
    * print 'current record count = ', cnt

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //resumptionToken == '#notnull'
    * def resumptionToken = get response //resumptionToken
    * def cnt = get response count(//record)
    * def totalRecords = addVariables(totalRecords, +cnt)
    * print 'current record count = ', cnt
    * print 'totalRecords = ', totalRecords
    * match totalRecords == 10.0

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'marc21_withholdings' |
      | 'oai_dc'              |

  Scenario: one record has field leader which marked as deleted and record is not displayed because config "deletedRecordsSupport" is "no"
    * def srsId = 'a2d6893e-c6b3-4c95-bec5-8b997aa1776d'
    Given url baseUrl
    And path 'source-storage/records', srsId
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = 'b1fa21b0-bb70-11ea-b3de-0242ac130004'
    * set record.matchedId = 'b97e1068-bb70-11ea-b3de-0242ac130007'
    * set record.parsedRecord.content.leader = '01542xcm a2200361   4500'
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 10

    # set deleted record support to no
    * def deletedRecordsSupportConfig = 'no'
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 9

    #return record to original state
    Given url baseUrl
    And path 'source-storage/records', srsId
    * set record.parsedRecord.content.leader = '01542ccm a2200361   4500'
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

  Scenario: set suppressDiscovery to true and record is absent in response because by default suppressed record processing = false
    * def srsId = '009286d6-f89e-4881-9562-11158f02664a'
    Given url baseUrl
    And path 'source-storage/records', srsId
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = 'e900266a-bb8d-11ea-b3de-0242ac130005'
    * set record.matchedId = 'f41cad98-bb8d-11ea-b3de-0242ac130004'
    * set record.additionalInfo.suppressDiscovery = true
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 9

    #return record to original state
    Given url baseUrl
    And path 'source-storage/records', srsId
    * set record.additionalInfo.suppressDiscovery = false
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

  Scenario: set config "deletedRecordsSupport" by default to "persistent" and find record marked as deleted by header with status = deleted in response
    * def srsId = '8fb19e31-0920-49d7-9438-b573c292b1a6'
    Given url baseUrl
    And path 'source-storage/records', srsId
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = 'b1fa21b0-bb70-11ea-b3de-0242ac130010'
    * set record.matchedId = 'b97e1068-bb70-11ea-b3de-0242ac130004'
    * set record.parsedRecord.content.leader = '01542xcm a2200361   4500'
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 10
    * match response //header[@status='deleted'] == '#notnull'

    #return record to original state
    Given url baseUrl
    And path 'source-storage/records', srsId
    * set record.parsedRecord.content.leader = '01542ccm a2200361   4500'
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

  Scenario: record marc as deleted and suppressDiscovery is true and config "suppressedRecordsProcessing" is true
    * def suppressedRecordsProcessingConfig = 'true'
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}

    * def srsId = '4c0ff739-3f4d-4670-a693-84dd48e31c53'
     #delete record
    Given url baseUrl
    And path 'source-storage/records', srsId
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204


    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 10
    * match response count(//header[@status='deleted']) == 1