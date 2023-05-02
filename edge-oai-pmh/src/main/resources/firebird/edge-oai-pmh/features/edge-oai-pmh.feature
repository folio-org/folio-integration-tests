Feature: edge-oai-pmh features
  Background:
    * url edgeUrl
    * callonce read('init_data/update-configuration.feature@TechnicalConfig')
    * callonce read('init_data/init-edge-oai-pmh.feature')

  Scenario: Check records fields with marc21_withholdings result
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='a'] == 'Københavns Universitet'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='b'] == 'City Campus'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='c'] == 'Datalogisk Institut'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='d'] == 'SECOND FLOOR'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == 'D15.H63 A3 2002'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='f'] == 'call number prefix'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='g'] == 'call number suffix'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='h'] == 'UDC'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='j'] == 'volume'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='k'] == 'enumeration'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='l'] == 'chronology'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='i'] == 'book'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m'] == '645398607547'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='n'] == 'Copy 2'

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri1','uri2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification1','materialsSpecification2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote1','publicNote2']

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'

  Scenario: List records with marc21_withholdings prefix and with from and until param when records exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21_withholdings prefix and with from param when records exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21_withholdings prefix and with until param when records exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21_withholdings prefix and with from param when records does not exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2100-01-01'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0

  Scenario: List records with marc21_withholdings prefix and with from and until param when records does not exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2099-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0

    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '1999-01-10'
    And param until = '2000-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0

  Scenario: List records with marc21 prefix and with from and until param when record exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21 prefix and with from param when records exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21 prefix and with until param when records exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21 prefix and with from and end param when record does not exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '2099-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0

    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '1999-01-10'
    And param until = '2000-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0

  Scenario: Add a new srs record
    * callonce read('init_data/create-instance.feature') { instanceId: '#(instanceId2)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(instanceHrid2)'}
    * callonce read('init_data/create-holding.feature') { holdingId: '#(holdingId2)', instanceId: '#(instanceId2)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(holdingHrid2)'}
    * callonce read('init_data/create-item.feature') { holdingId: '#(holdingId2)', itemId: '#(itemId2)', itemHrid: '#(itemHrid2)', barcode: '#(barcode2)'}
    * callonce read('init_data/create-srs-record.feature') { jobExecutionId: '#(jobExecutionId2)', instanceId: '#(instanceId2)',  recordId: '#(recordId2)', matchedId: '#(matchedId2)'}

  Scenario: List records with marc21_withholdings prefix, from and until param when resumption token exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1
    And def resumptionToken = get response //resumptionToken

    Given path 'oai'
    And param apikey = apikey
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1

  Scenario: List records with marc21 prefix, from and until param when resumption token exist
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    And param until = '2100-01-10'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1
    And def resumptionToken = get response //resumptionToken

    Given path 'oai'
    And param apikey = apikey
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 1