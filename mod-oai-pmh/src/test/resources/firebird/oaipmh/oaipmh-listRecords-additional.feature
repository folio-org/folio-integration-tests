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
    * configure afterFeature =  function(){ karate.call('classpath:common/destroy-data.feature', {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * callonce read('classpath:global/init_data/srs_init_data_single.feature')
    * callonce read('classpath:global/init_data/mod_configuration_init_support_suppressed_deleted.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data_single.feature')
    #=========================SETUP=================================================
    * call resetConfiguration
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: get ListRecords for marc21_withholdings - check data fields
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * def res = get response //datafield[@tag='952']/subfield[@code='a']
    * match res == 'Københavns Universitet'
    * def res = get response //datafield[@tag='952']/subfield[@code='b']
    * match res == 'City Campus'
    * def res = get response //datafield[@tag='952']/subfield[@code='c']
    * match res == 'Datalogisk Institut'
    * def res = get response //datafield[@tag='952']/subfield[@code='d']
    * match res == 'SECOND FLOOR'
    * def res = get response //datafield[@tag='952']/subfield[@code='e']
    * match res == 'D15.H63 A3 2002'
    * def res = get response //datafield[@tag='952']/subfield[@code='f']
    * match res == 'pref'
    * def res = get response //datafield[@tag='952']/subfield[@code='g']
    * match res == 'suff'
    * def res = get response //datafield[@tag='952']/subfield[@code='h']
    * match res == 'LC Modified'
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * def res = get response //datafield[@tag='856']/subfield[@code='u']
    * match res == 'http://www.jstor.com'
    * def res = get response //datafield[@tag='856']/subfield[@code='y']
    * match res == 'Link text'
    * def res = get response //datafield[@tag='856']/subfield[@code='3']
    * match res == '1984-'
    * def res = get response //datafield[@tag='856']/subfield[@code='z']
    * match res == 'Most recent 4 years not available.'

    # check 856 field indicators for other electronic access relationship types
    * def holdingsId = 'e8e3db08-dc39-48ea-a3db-08dc3958eafb'
    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 1
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'ef03d582-219c-4221-8635-bc92f1107021'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 2
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2=' ']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 3
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 4
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'f5d0068e-6272-458e-8a81-b85e7b9a14aa'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 5
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * remove holding.electronicAccess[0].relationshipId
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2=' ']) == 1

    # restore holdings record's initial electronic access relationshipId
    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 6
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = '3b430592-2e09-4b48-9a0c-0636d66b9fb3'
    And request holding
    When method PUT
    Then status 204

  Scenario: harvest suppressed record for marc21_withholdings - check data fields
    * def srsId = 'a2d6893e-c6b3-4c95-bec5-8b997aa1776d'
    Given url baseUrl
    And path 'source-storage/records', srsId
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set record.matchedId = '332473da-b180-11ea-b3de-0242ac130004'
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
    * match response count(//record) == 1
    * def res = get response //datafield[@tag='952']/subfield[@code='a']
    * match res == 'Københavns Universitet'
    * def res = get response //datafield[@tag='952']/subfield[@code='b']
    * match res == 'City Campus'
    * def res = get response //datafield[@tag='952']/subfield[@code='c']
    * match res == 'Datalogisk Institut'
    * def res = get response //datafield[@tag='952']/subfield[@code='d']
    * match res == 'SECOND FLOOR'
    * def res = get response //datafield[@tag='952']/subfield[@code='e']
    * match res == 'D15.H63 A3 2002'
    * def res = get response //datafield[@tag='952']/subfield[@code='f']
    * match res == 'pref'
    * def res = get response //datafield[@tag='952']/subfield[@code='g']
    * match res == 'suff'
    * def res = get response //datafield[@tag='952']/subfield[@code='h']
    * match res == 'LC Modified'
    * def res = get response //datafield[@tag='952']/subfield[@code='t']
    * match res == '1'
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='1']) == 1
    * def res = get response //datafield[@tag='856']/subfield[@code='u']
    * match res == 'http://www.jstor.com'
    * def res = get response //datafield[@tag='856']/subfield[@code='y']
    * match res == 'Link text'
    * def res = get response //datafield[@tag='856']/subfield[@code='3']
    * match res == '1984-'
    * def res = get response //datafield[@tag='856']/subfield[@code='z']
    * match res == 'Most recent 4 years not available.'
    * def res = get response //datafield[@tag='856']/subfield[@code='t']
    * match res == '1'
    * def res = get response //datafield[@tag='999']/subfield[@code='t']
    * match res == '1'

    # check 856 field indicators for other electronic access relationship types
    * def holdingsId = 'e8e3db08-dc39-48ea-a3db-08dc3958eafb'
    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 7
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'ef03d582-219c-4221-8635-bc92f1107021'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='8']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 8
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2=' ']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 9
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='2']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 10
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = 'f5d0068e-6272-458e-8a81-b85e7b9a14aa'
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2='0']) == 1

    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 11
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * remove holding.electronicAccess[0].relationshipId
    And request holding
    When method PUT
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 1
    * match response count(//datafield[@tag='856' and @ind1='4' and @ind2=' ']) == 1

    # restore holdings record's initial electronic access relationshipId
    Given url baseUrl
    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding._version = 12
    * set holding.id = holdingId
    * set holding.instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * set holding.hrid = 'inst000000000145'
    * set holding.electronicAccess[0].relationshipId = '3b430592-2e09-4b48-9a0c-0636d66b9fb3'
    And request holding
    When method PUT
    Then status 204

    #return record to original state
    Given url baseUrl
    And path 'source-storage/records', srsId
    * set record.additionalInfo.suppressDiscovery = false
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

  Scenario: Deleted SRS and FOLIO holdings are harvested for marc21_withholdings
    * def srsId = '8fb19e31-0920-49d7-9438-b573c292b1a6'
    * def instanceId = '2dc09555-18c4-4ff6-8d9b-b0f5233c5e50'
    * def holdingsId = 'b7412cd7-3ed8-4747-a8fd-773df2bfe9c6'
    * def hrid = 'inst000000000171'
    # add SRS record
    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = instanceId
    * set record.matchedId = 'c09bbbed-3524-45df-bc55-eea0cf617c33'
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201
    # add instance
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = hrid
    And request instance
    When method POST
    Then status 201
    # add holdings record
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingsId
    * set holding.instanceId = instanceId
    * set holding.hrid = hrid
    And request holding
    When method POST
    Then status 201
    # add item
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def item = read('classpath:samples/item.json')
    * set item.id = 'fb8fa3dd-49fb-4d7a-b72d-0a652722bef4'
    * set item.holdingsRecordId = holdingsId
    * set item.hrid = hrid
    And request item
    When method POST
    Then status 201


    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 2

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 2

  Scenario: Added SRS instances are harvested (marc21 and marc21_withholdings)
    * def srsId = '8fb19e31-0920-49d7-9438-b573c292b1a6'
    * def instanceId = '2dc09555-18c4-4ff6-8d9b-b0f5233c5e50'
    * def holdingsId = 'b7412cd7-3ed8-4747-a8fd-773df2bfe9c6'
    * def hrid = 'inst000000000171'
    # add SRS record
    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = instanceId
    * set record.matchedId = 'c09bbbed-3524-45df-bc55-eea0cf617c33'
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201
    # add instance
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = hrid
    And request instance
    When method POST
    Then status 201
    # add holdings record
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingsId
    * set holding.instanceId = instanceId
    * set holding.hrid = hrid
    And request holding
    When method POST
    Then status 201
    # add item
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def item = read('classpath:samples/item.json')
    * set item.id = 'fb8fa3dd-49fb-4d7a-b72d-0a652722bef4'
    * set item.holdingsRecordId = holdingsId
    * set item.hrid = hrid
    And request item
    When method POST
    Then status 201


    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 2

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 2