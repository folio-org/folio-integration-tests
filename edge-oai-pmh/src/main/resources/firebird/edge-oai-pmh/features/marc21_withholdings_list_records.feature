Feature: edge-oai-pmh feature
  Background:
    * url edgeUrl
    * callonce read('init_data/init_marc21_withholdings_list_records.feature')

  Scenario: List records in marc21_withholdings format
    Given path 'oai', apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
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

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == 'http://www.loc.gov/catdir/toc/ecip0718/2007020429.html'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='y'] == 'Links available'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == 'Table of contents'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == 'Table of contents only'

  Scenario: List records does not exist for from param
    Given path 'oai', apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2100-01-01'
    When method GET
    Then status 200
    And match response count(response/OAI-PMH/ListRecords) == 0