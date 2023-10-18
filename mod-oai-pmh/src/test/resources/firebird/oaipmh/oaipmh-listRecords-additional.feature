Feature: Additional ListRecords tests

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
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data_single.feature')
    #=========================SETUP=================================================
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
    # No display constant generated
    * def holdingsId = 'e8e3db08-dc39-48ea-a3db-08dc3958eafb'
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # No information provided
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # Related resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # Resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # No relationship type
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # restore holdings record's initial electronic access relationshipId - Version of resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    * def instanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'
    Given url baseUrl
    And path 'instance-storage/instances', instanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = 'inst000000000145'
    * set instance.discoverySuppress = true
    * set instance._version = 15
    And request instance
    When method PUT
    Then status 204

    Given url pmhUrl
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
    # No display constant generated
    * def holdingsId = 'e8e3db08-dc39-48ea-a3db-08dc3958eafb'
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # No information provided
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # Related resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # Resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # No relationship type
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    # restore holdings record's initial electronic access relationship - Version of resource
    Given url baseUrl
    And path 'holdings-storage/holdings', holdingsId
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

    #return records to original state
    Given url baseUrl
    And path 'source-storage/records', srsId
    * set record.additionalInfo.suppressDiscovery = false
    And request record
    And header Accept = 'application/json'
    When method PUT
    Then status 200

    Given url baseUrl
    And path 'instance-storage/instances', instanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    * set instance._version = 28
    * set instance.discoverySuppress = false
    And request instance
    When method PUT
    Then status 204

  Scenario: Deleted SRS and FOLIO holdings are harvested for marc21_withholdings
    * def instanceId = 'c4fcefd5-f007-47d3-9817-143c0f9487b5'
    * def holdingsId = '3138ad30-0030-463b-98a0-82910e377749'
    * def hrid = 'inst000000000172'
    # add instance
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = hrid
    * set instance.source = 'FOLIO'
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

    # delete item and holdings records
    Given path 'item-storage/items', '645549b1-2a73-4251-b8bb-39598f773a93'
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', 'e8e3db08-dc39-48ea-a3db-08dc3958eafb'
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', holdingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = testUserToken
    When method DELETE
    Then status 204

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 2

  Scenario: Added SRS instances are harvested (marc21 and marc21_withholdings)
    * def srsId = '8f7e9a7d-591a-4fea-b0cc-99e1e4670112'
    * def instanceId = '210b93ce-805c-46b3-93a4-1156ffa21c79'
    * def holdingsId = '287a956d-1afe-4845-aa62-eb91476492c6'
    * def hrid = 'inst000000000173'
    # add SRS record
    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = srsId
    * set record.externalIdsHolder.instanceId = instanceId
    * set record.matchedId = '204707ef-d503-4a26-afd7-e16ef63cff9c'
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
    * set item.id = 'c9ca871e-2de1-4169-93d2-f8429e7be3af'
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
    * match response count(//record) == 3

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//record) == 3