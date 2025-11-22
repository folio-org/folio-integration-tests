@parallel=false
Feature: Additional ListRecords tests when source is Inventory

  Background:
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: C375198: ListRecords: Added FOLIO instances with holdings are harvested
    * url baseUrl

    # Update configuration: recordsSource = 'Inventory', suppressedRecordsProcessing = 'true', support deleted = 'No'
    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def config = get $.configurationSettings[0]
    And match config.configName == 'behavior'
    * def value = config.configValue
    * set value.recordsSource = 'Inventory'
    * set value.suppressedRecordsProcessing = 'true'
    * set value.deletedRecordsSupport = 'No'
    * def updatedValue = value;
    * set config.configValue = updatedValue
    Given path '/oai-pmh/configuration-settings', config.id
    And request config
    When method PUT
    Then status 200

    # Add instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/c375/instance-C375198.json')
    And request instance
    When method POST
    Then status 201

    # Add holding
    Given path 'holdings-storage/holdings'
    * def holding = read('classpath:samples/c375/holding-C375198.json')
    And request holding
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='245']/subfield[@code='a'] == 'Test resource title'
    * match response //datafield[@tag='336']/subfield[@code='a'] == 'text'
    * match response //datafield[@tag='952']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999']/subfield[@code='i'] == '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    * match response //datafield[@tag='999']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'

  Scenario: C375199: ListRecords: FOLIO instances with added Holdings are harvested
    * url baseUrl

    # Add holding
    Given path 'holdings-storage/holdings'
    * def holding = read('classpath:samples/c375/holding2-C375198.json')
    And request holding
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 2
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 2
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1

    # Remove holdings
    Given url baseUrl
    Given path 'holdings-storage/holdings', '54032151-39a5-4cef-8810-5350eb316300'
    When method DELETE
    Then status 204
    Given path 'holdings-storage/holdings', '65032151-39a5-4cef-8810-5350eb316300'
    When method DELETE
    Then status 204

  Scenario: C375200: ListRecords: FOLIO instances with Holdings are harvested - holdings Transfer suppressed
    * url baseUrl

    # Add holding
    Given path 'holdings-storage/holdings'
    * def holding = read('classpath:samples/c375/holding_suppressed-C375198.json')
    And request holding
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'SECOND FLOOR'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='f'] == 'gf'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='g'] == 'as'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='h'] == 'LC Modified'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='y'] == 'link text 1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='3'] == '1.2014 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='u'] == 'https://search.proquest.com/publication/55555'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='z'] == 'note 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='y'] == 'link text 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='3'] == '1.2009 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='u'] == 'https://search.proquest.com/publication/44444'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='z'] == 'note 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='y'] == 'link text 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='3'] == '1.2008 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='u'] == 'https://search.proquest.com/publication/33333'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='z'] == 'note 4'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='y'] == 'link text 4'

    # Remove holding
    Given url baseUrl
    Given path 'holdings-storage/holdings', '77032151-39a5-4cef-8810-5350eb316300'
    When method DELETE
    Then status 204

  Scenario: C375203: ListRecords: FOLIO instances are harvested – Instance Transfer suppressed
    * url baseUrl

    # Remove instance
    Given url baseUrl
    Given path 'instance-storage/instances', '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    When method DELETE
    Then status 204

    # Add instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/c375/instance-suppressed-C375203.json')
    And request instance
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '1'

    # Remove instance
    Given url baseUrl
    Given path 'instance-storage/instances', '88896bc1-6dab-4bee-8c9d-67170c7c2858'
    When method DELETE
    Then status 204

  Scenario: C375207: ListRecords: FOLIO instances with added Holdings are harvested with start and end date
    * url baseUrl

    # Add instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/c375/instance-C375198.json')
    And request instance
    When method POST
    Then status 201

    # Add holding
    Given path 'holdings-storage/holdings'
    * def holding = read('classpath:samples/c375/holding_not-suppressed-C375207.json')
    And request holding
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'SECOND FLOOR'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='f'] == 'gf'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='g'] == 'as'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='h'] == 'LC Modified'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='y'] == 'link text 1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='3'] == '1.2014 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='u'] == 'https://search.proquest.com/publication/55555'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='z'] == 'note 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='y'] == 'link text 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='3'] == '1.2009 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='u'] == 'https://search.proquest.com/publication/44444'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='z'] == 'note 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='y'] == 'link text 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='3'] == '1.2008 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='u'] == 'https://search.proquest.com/publication/33333'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='z'] == 'note 4'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='y'] == 'link text 4'

  Scenario: C375208: ListRecords: FOLIO instances with changed Holdings are harvested with start and end date
    * url baseUrl

    # Change holding
    Given path 'holdings-storage/holdings', '77032151-39a5-4cef-8810-5350eb316300'
    * def holding = read('classpath:samples/c375/holding_not-suppressed-updated-C375208.json')
    And request holding
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'MAIN LIBRARY'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='f'] == 'gf'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='g'] == 'as'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='h'] == 'LC Modified'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='y'] == 'link text 1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='3'] == '1.2014 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='u'] == 'https://search.proquest.com/publication/55555'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='z'] == 'note 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='y'] == 'link text 2 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='3'] == '1.2009 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='u'] == 'https://search.proquest.com/publication/44444'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='z'] == 'note 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='y'] == 'link text 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='3'] == '1.2008 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='u'] == 'https://search.proquest.com/publication/33333'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='z'] == 'note 4 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='y'] == 'link text 4'

  Scenario: C375209: ListRecords: FOLIO instances with changed Items are harvested with start and end date
    * url baseUrl

    # Add item
    Given path 'item-storage/items'
    * def item = read('classpath:samples/c375/item-C375209.json')
    And request item
    When method POST
    Then status 201

    # Change item
    Given path 'item-storage/items', 'f8b6d973-60d4-41ce-a57b-a3884471a6d6'
    * def itemUpdated = read('classpath:samples/c375/item-updated-C375209.json')
    And request itemUpdated
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'SECOND FLOOR'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='f'] == 'gf'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='g'] == 'as'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='h'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='l'] == '1986:Jan.-June updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='y'] == 'link text 1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='3'] == '1.2014 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='u'] == 'https://search.proquest.com/publication/55555'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='z'] == 'note 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='y'] == 'link text 2 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='3'] == '1.2009 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='u'] == 'https://search.proquest.com/publication/44444'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='z'] == 'note 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='y'] == 'link text 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='3'] == '1.2008 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='u'] == 'https://search.proquest.com/publication/33333'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='z'] == 'note 4 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='y'] == 'link text 4'

  Scenario: C375212: ListRecords: FOLIO instances with changed Items are harvested with start and end date – Transfer suppressed
    * url baseUrl

    # Change item - set suppressed
    Given path 'item-storage/items', 'f8b6d973-60d4-41ce-a57b-a3884471a6d6'
    * def itemUpdated = read('classpath:samples/c375/item-updated-suppressed-C375212.json')
    And request itemUpdated
    When method PUT
    Then status 204

    # Change holding
    Given path 'holdings-storage/holdings', '77032151-39a5-4cef-8810-5350eb316300'
    * def holding = read('classpath:samples/c375/holding_not-suppressed-updated-no-electr-acc-C375212.json')
    And request holding
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'SECOND FLOOR'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='f'] == 'gf'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='g'] == 'as'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='h'] == 'LC Modified'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='l'] == '1986:Jan.-June updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='y'] == 'link text 1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='3'] == '1.2014 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='u'] == 'https://search.proquest.com/publication/55555'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='z'] == 'note 2'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='8']/subfield[@code='y'] == 'link text 2 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='3'] == '1.2009 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='u'] == 'https://search.proquest.com/publication/44444'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='z'] == 'note 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='2']/subfield[@code='y'] == 'link text 3'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='3'] == '1.2008 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='t'] == '1'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='u'] == 'https://search.proquest.com/publication/33333'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='z'] == 'note 4 updated'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='y'] == 'link text 4'

  Scenario: C375938: ListRecords: FOLIO edited instances are harvested with start and end date (marc21)
    * url baseUrl

    Given path 'instance-storage/instances', '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def instanceVersion = $._version

    # Change instance
    Given path 'instance-storage/instances', '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    * def instanceUpdated = read('classpath:samples/c375/instance-updated-C375938.json')
    * set instanceUpdated._version = instanceVersion
    And request instanceUpdated
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //datafield[@tag='245' and @ind1='0' and @ind2='0']/subfield[@code='a'] == 'Test resource title UPDATED'

  Scenario: C375940: ListRecords: FOLIO instances with added Items are harvested with start and end date
    * url baseUrl

    # Remove item
    Given url baseUrl
    Given path 'item-storage/items', 'f8b6d973-60d4-41ce-a57b-a3884471a6d6'
    When method DELETE
    Then status 204

    # Remove holding
    Given url baseUrl
    Given path 'holdings-storage/holdings', '77032151-39a5-4cef-8810-5350eb316300'
    When method DELETE
    Then status 204

    # Add holding
    Given path 'holdings-storage/holdings'
    * def holding = read('classpath:samples/c375/holding-C375198.json')
    And request holding
    When method POST
    Then status 201

    # Add item
    Given path 'item-storage/items'
    * def item = read('classpath:samples/c375/item-C375940.json')
    And request item
    When method POST
    Then status 201

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'MAIN LIBRARY'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'

  Scenario: C375944: ListRecords: FOLIO instances with changed Items are harvested with start and end date (SRS+Inventory)
    * url baseUrl

    # Update configuration: recordsSource = 'SRS+Inventory'
    Given path '/oai-pmh/configuration-settings'
    And param query = 'configName==behavior'
    When method GET
    Then status 200
    * def config = get $.configurationSettings[0]
    And match config.configName == 'behavior'
    * def value = config.configValue
    * set value.recordsSource = 'Source record storage and Inventory'
    * def updatedValue = value;
    * set config.configValue = updatedValue
    Given path '/oai-pmh/configuration-settings', config.id
    And request config
    When method PUT
    Then status 200

    # Change item
    Given path 'item-storage/items', 'f8b6d973-60d4-41ce-a57b-a3884471a6d6'
    * def itemUpdated = read('classpath:samples/c375/item-updated-C375940.json')
    And request itemUpdated
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # First is marc record
    * match response count(//record) == 10
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 10
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 9
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 10
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] ==['0','0','0','0','0','0','0','0','0','0']
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='1']/subfield[@code='t'] ==['0','0','0','0','0','0','0','0','0']
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] ==['0','0','0','0','0','0','0','0','0','0']
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] ==['Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet','Københavns Universitet']
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] ==['City Campus','City Campus','City Campus','City Campus','City Campus','City Campus','City Campus','City Campus','City Campus','City Campus']
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] ==['Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut','Datalogisk Institut']
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] ==['SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR','SECOND FLOOR']
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] ==['D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002','LC Modified','D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002']

  Scenario: C375974: ListRecords: FOLIO edited instances with holdings are harvested with start and end date
    * url baseUrl

    # Update configuration: recordsSource = 'Inventory'
    Given path '/oai-pmh/configuration-settings'
    And param query = 'configName==behavior'
    When method GET
    Then status 200
    * def config = get $.configurationSettings[0]
    And match config.configName == 'behavior'
    * def value = config.configValue
    * set value.recordsSource = 'Inventory'
    * def updatedValue = value;
    * set config.configValue = updatedValue
    Given path '/oai-pmh/configuration-settings', config.id
    And request config
    When method PUT
    Then status 200

    # Remove item
    Given path 'item-storage/items', 'f8b6d973-60d4-41ce-a57b-a3884471a6d6'
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def instanceVersion = $._version

    # Change instance
    Given path 'instance-storage/instances', '71a96bc1-6dab-4bee-8c9d-67170c7c2858'
    * def instanceUpdated = read('classpath:samples/c375/instance-updated-C375974.json')
    * set instanceUpdated._version = instanceVersion
    And request instanceUpdated
    When method PUT
    Then status 204

    # Harvest
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # First is marc record
    * match response count(//record) == 1
    * match response count(//datafield[@tag='952' and @ind1='f' and @ind2='f']) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1
    * match response count(//datafield[@tag='999' and @ind1='f' and @ind2='f']) == 1
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='999' and @ind1='f' and @ind2='f']/subfield[@code='t'] == '0'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='a'] == 'Københavns Universitet'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='b'] == 'City Campus'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='c'] == 'Datalogisk Institut'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='d'] == 'SECOND FLOOR'
    * match response //datafield[@tag='952' and @ind1='f' and @ind2='f']/subfield[@code='e'] == 'LC Modified'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='3'] == '1.2012 -'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='u'] == 'https://search.proquest.com/publication/1396348'
    * match response //datafield[@tag='856' and @ind1='4' and @ind2='0']/subfield[@code='z'] == 'via ProQuest, the last 12 months are not available due to an embargo'