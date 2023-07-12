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

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri1','uri2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification1','materialsSpecification2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7', 'publicNote8','publicNote1','publicNote2']

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == 'Version of component part(s) of resource'

  Scenario: ListRecords: SRS Verify that changes to holdings are triggering harvesting records with marc21_withholdings
    * url baseUrl
    Given path 'holdings-storage/holdings', holdingId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def holding = response
    * set holding.electronicAccess[] = {"uri" : "uri3","linkText" : "No information provided updated","materialsSpecification" : "materialsSpecification3","publicNote" : "publicNote3","relationshipId" : "f5d0068e-6272-458e-8a81-b85e7b9a14aa"}
    Given path 'holdings-storage/holdings', holdingId
    And header x-okapi-token = okapiTokenAdmin
    And request holding
    When method PUT
    Then status 204
    * url edgeUrl
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
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == 'Version of component part(s) of resource'

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri1','uri2','uri3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification1','materialsSpecification2','materialsSpecification3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7', 'publicNote8','publicNote1','publicNote2','publicNote3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated']

  Scenario: ListRecords: SRS Verify that changes to items are triggering harvesting records with marc21_withholdings
    * url baseUrl
    Given path 'item-storage/items', itemId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def item = response
    * set item.electronicAccess[] = {"uri": "uri9","linkText": "Version of component part(s) of resource updated","materialsSpecification": "materialsSpecification9","publicNote": "publicNote9","relationshipId": "f0d0068e-6272-458e-8a81-b85e7b9a14aa"}
    Given path 'item-storage/items', itemId
    And header x-okapi-token = okapiTokenAdmin
    And request item
    When method PUT
    Then status 204
    * url edgeUrl
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
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri9','uri1','uri2','uri3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification9','materialsSpecification1','materialsSpecification2','materialsSpecification3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7', 'publicNote8','publicNote9','publicNote1','publicNote2','publicNote3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == ['Version of component part(s) of resource','Version of component part(s) of resource updated']

  Scenario: ListRecords: SRS: Verify that changes to instances are triggering harvesting by verb=ListRecords with marc21_withholdings
    * url baseUrl
    Given path 'records-editor/records'
    And param externalId = instanceId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def instance = response
    * def newField = { "tag": "245", "indicators": [ "\\", "\\" ], "content": "$a New test field", "isProtected":false }
    * instance.fields.push(newField)
    * set instance._actionType = 'edit'
    * set instance $.relatedRecordVersion = '1'
    * set instance.externalHrid = 'inst000000000145'
    * set instance.parsedRecordId = instanceId
    Given path 'records-editor/records', instanceId
    And header x-okapi-token = okapiTokenAdmin
    And request instance
    When method PUT
    Then status 202
    * url edgeUrl
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
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri9','uri1','uri2','uri3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification9','materialsSpecification1','materialsSpecification2','materialsSpecification3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7', 'publicNote8','publicNote9','publicNote1','publicNote2','publicNote3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == ['Version of component part(s) of resource','Version of component part(s) of resource updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == 'New test field'

  Scenario: ListRecords: SRS: Verify that adding a new item to the existing instance is triggering harvesting records with marc21_withholdings
    * url baseUrl
    Given path 'item-storage/items'
    And header x-okapi-token = okapiTokenAdmin
    * def item = read('classpath:samples/item2.json')
    And request item
    When method POST
    Then status 201
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri9','uri13','uri1','uri2','uri3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification9','materialsSpecification3','materialsSpecification1','materialsSpecification2','materialsSpecification3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7', 'publicNote8','publicNote9','publicNote3','publicNote1','publicNote2','publicNote3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == ['Version of component part(s) of resource','Version of component part(s) of resource updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == 'New test field'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='a'] == ['Københavns Universitet','Københavns Universitet']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='b'] == ['City Campus','City Campus']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='c'] == ['Datalogisk Institut','Datalogisk Institut']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='d'] == ['SECOND FLOOR','SECOND FLOOR']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == ['D15.H63 A3 2002','D15.H63 A3 2002']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='f'] == ['call number prefix','call number prefix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='g'] == ['call number suffix','call number suffix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='h'] == ['UDC','UDC']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='j'] == ['volume','volume']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='k'] == ['enumeration','enumeration']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='l'] == ['chronology','chronology']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='i'] == ['book','book']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m'] == ['645398607547','745398607547']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='n'] == ['Copy 2','Copy 2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == ['Related resource','Related resource 13']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'

  Scenario: ListRecords: SRS: Verify that changes to instances are triggering harvesting by verb=ListRecords with marc21
    * url baseUrl
    Given path 'records-editor/records'
    And param externalId = instanceId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def instance = response
    * instance.fields[3].indicators[0] = '2'
    * instance.fields[3].indicators[1] = '3'
    * set instance._actionType = 'edit'
    * set instance $.relatedRecordVersion = '2'
    * set instance.externalHrid = 'inst000000000145'
    * set instance.parsedRecordId = instanceId
    Given path 'records-editor/records', instanceId
    And header x-okapi-token = okapiTokenAdmin
    And request instance
    When method PUT
    Then status 202
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    When method GET
    Then status 200

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245' and @ind1='2' and @ind2='3']/*[local-name()='subfield'][@code='a'] == 'New test field'

  Scenario: ListRecords: SRS: Verify that changes to holdings and item are triggering harvesting records with marc21_withholdings
    * url baseUrl
    Given path 'item-storage/items', itemId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def item = response
    * set item.electronicAccess[4].publicNote = 'publicNote7 UPDATED'
    Given path 'item-storage/items', itemId
    And header x-okapi-token = okapiTokenAdmin
    And request item
    When method PUT
    Then status 204
    Given path 'holdings-storage/holdings', holdingId
    And header x-okapi-token = okapiTokenAdmin
    When method GET
    Then status 200
    * def holdings = response
    * set holdings.electronicAccess[1].materialsSpecification = 'materialsSpecification2 UPDATED'
    Given path 'holdings-storage/holdings', holdingId
    And header x-okapi-token = okapiTokenAdmin
    And request holdings
    When method PUT
    Then status 204
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri9','uri13','uri1','uri2','uri3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == ['Version of component part(s) of resource','Version of component part(s) of resource updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == 'New test field'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='a'] == ['Københavns Universitet','Københavns Universitet']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='b'] == ['City Campus','City Campus']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='c'] == ['Datalogisk Institut','Datalogisk Institut']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='d'] == ['SECOND FLOOR','SECOND FLOOR']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == ['D15.H63 A3 2002','D15.H63 A3 2002']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='f'] == ['call number prefix','call number prefix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='g'] == ['call number suffix','call number suffix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='h'] == ['UDC','UDC']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='j'] == ['volume','volume']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='k'] == ['enumeration','enumeration']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='l'] == ['chronology','chronology']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='i'] == ['book','book']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m'] == ['645398607547','745398607547']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='n'] == ['Copy 2','Copy 2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == ['Related resource','Related resource 13']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification9','materialsSpecification3','materialsSpecification1','materialsSpecification2 UPDATED','materialsSpecification3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7 UPDATED', 'publicNote8','publicNote9','publicNote3','publicNote1','publicNote2','publicNote3']

  Scenario: ListRecords: SRS: Verify that adding a new holdings (FOLIO) to the existing instance is triggering harvesting records with marc21_withholdings
    * url baseUrl
    Given path 'holdings-storage/holdings'
    And header x-okapi-token = okapiTokenAdmin
    * def holdings = read('classpath:samples/holding2.json')
    And request holdings
    When method POST
    Then status 201
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='4']/*[local-name()='subfield'][@code='y'] == ['Version of component part(s) of resource','Version of component part(s) of resource updated']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == 'New test field'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == ['Related resource','Related resource 13']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='3']/*[local-name()='subfield'][@code='y'] == 'Component part(s) of resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='j'] == ['volume','volume']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='k'] == ['enumeration','enumeration']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='l'] == ['chronology','chronology']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='i'] == ['book','book']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m'] == ['645398607547','745398607547']

    # Updated part
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri7','uri8','uri9','uri13','uri1','uri2','uri3','uri3','uri4']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided','No information provided updated','No information provided4']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='a'] == ['Københavns Universitet','Københavns Universitet','Københavns Universitet']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='b'] == ['City Campus','City Campus','City Campus']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='c'] == ['Datalogisk Institut','Datalogisk Institut','Datalogisk Institut']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='d'] == ['SECOND FLOOR','SECOND FLOOR','SECOND FLOOR']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == ['D15.H63 A3 2002','D15.H63 A3 2002','D15.H63 A3 2002']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='f'] == ['call number prefix','call number prefix','call number prefix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='g'] == ['call number suffix','call number suffix','call number suffix']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='h'] == ['UDC','UDC','UDC']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='n'] == ['Copy 2','Copy 2','1']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == ['No display constant generated','No display constant generated3']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification7', 'materialsSpecification8','materialsSpecification9','materialsSpecification3','materialsSpecification1','materialsSpecification2 UPDATED','materialsSpecification3','materialsSpecification3','materialsSpecification4']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote7 UPDATED', 'publicNote8','publicNote9','publicNote3','publicNote1','publicNote2','publicNote3','publicNote3','publicNote4']

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

  Scenario: List records with from marc21 prefix, from param when resumption token exist
    * def totalRecords = 0

    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    When method GET
    Then status 200
    And def currentRecordsReturned = get response count(//record)
    And def totalRecords = totalRecords + currentRecordsReturned
    And def resumptionToken = get response //resumptionToken

    Given path 'oai'
    And param apikey = apikey
    And param verb = 'ListRecords'
    And param resumptionToken = resumptionToken
    When method GET
    Then status 200
    And def currentRecordsReturned = get response count(//record)
    And def totalRecords = totalRecords + currentRecordsReturned
    And match totalRecords == 2
    And def resToken = get response //resumptionToken
    And match resToken == ""
