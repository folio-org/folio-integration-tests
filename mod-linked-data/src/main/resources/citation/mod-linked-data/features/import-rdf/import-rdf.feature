Feature: Import Bibframe2 RDF

  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Import RDF file to graph & update graph using API.
    # Step 1 (Setup): create authority records referenced in the RDF file & wait till the records are available in mod-search
    * configure headers = testAdminHeaders
    * call read('import-rdf.feature@createAutority') { fileName: 'authority_person_wang_jack.json', query: '(lccn="no2012142443")' }
    * call read('import-rdf.feature@createAutority') { fileName: 'authority_subject_readers.json', query: '(lccn="sh85111655")' }
    * call read('import-rdf.feature@createAutority') { fileName: 'authority_subject_private_flying.json', query: '(lccn="sh2008001841")' }
    * call read('import-rdf.feature@createAutority') { fileName: 'authority_subject_history.json', query: '(lccn="sh99005024")' }
    * call read('import-rdf.feature@createAutority') { fileName: 'authority_subject_dyes.json', query: '(lccn="sh85040281")' }
    * call read('import-rdf.feature@createAutority') { fileName: 'fast_authority_japan.json', query: '(naturalId="fst01204082")' }

    # Step 2: Import RDF file
    * def fileName = 'rdf.json'
    * configure headers = { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path '/linked-data/import/file'
    And multipart file fileName = { read: 'classpath:citation/mod-linked-data/features/import-rdf/samples/rdf.json', filename: '#(fileName)', contentType: 'application/ld+json'  }
    When method POST
    Then status 200

    # Step 3: Verify new Work in mod-search
    * configure headers = testUserHeaders
    * def query = 'title all "Pride & prejudice"'
    * def searchCall = call searchLinkedDataWork
    * match searchCall.response.totalRecords == 1

    # Step 4: Verify new instance in mod-inventory
    * callonce read('validate/verify-inventory-instance.feature')

    # Step 5: Validate Instance API
    * callonce read('validate/verify-instance-get-api.feature')

    # Step 6: Validate graph
    * callonce read('validate/verify-graph.feature')

    # Step 7: Export RDF and validate
    * callonce read('validate/verify-export-rdf.feature')

    # Step 8: Update instance resource using API
    * def getResourceCall = call getResource { id: "#(resourceId)" }
    * def updateInstanceRequest = JSON.parse(JSON.stringify(getResourceCall.response))
    * def instance = updateInstanceRequest.resource['http://bibfra.me/vocab/lite/Instance']
    * set instance['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title']['http://bibfra.me/vocab/library/mainTitle'][0] = "Jane Austen's Pride & prejudice UPDATED"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/date'][0] = "2017"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/name'][0] = "Chronicle Books LLC - UPDATED"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/providerDate'][0] = "2017"
    * def lccnObj = karate.filter(instance['http://library.link/vocab/map'], x => x['http://library.link/identifier/LCCN'] != null)
    * set lccnObj[0]['http://library.link/identifier/LCCN']['http://bibfra.me/vocab/lite/name'][0] = "2015047302-UPDATED"
    * def isbnBoardObj = karate.filter(instance['http://library.link/vocab/map'], x => x['http://library.link/identifier/ISBN'] != null && x['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/library/qualifier'] && x['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/library/qualifier'][0] == 'board bk')
    * set isbnBoardObj[0]['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/lite/name'][0] = "9781452152448-UPDATED"
    * set instance['_workReference'][0] = { id: "#(workResourceId)" }
    * def putCall = call putResource { id: '#(resourceId)' , resourceRequest: '#(updateInstanceRequest)' }
    * def updatedResourceId = putCall.response.resource['http://bibfra.me/vocab/lite/Instance'].id

    # Step 9: Validate updated resource in invetnory
    * def query = 'title all "Pride & prejudice" UPDATED'
    * def searchCall = call searchInventoryInstance
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * def response = getInventoryInstanceCall.response
    * def ldIdentifiers = karate.filter(response.identifiers, x => x.value && x.value.startsWith('(ld)'))
    * match ldIdentifiers == '#[1]'
    * match ldIdentifiers[0].value == '(ld) ' + updatedResourceId
    * match response.source == 'LINKED_DATA'
    * match response.identifiers[*].value contains '2015047302-UPDATED'
    * match response.identifiers[*].value contains '9781452152448-UPDATED board bk'
    * match response.publication contains { publisher: 'Chronicle Books LLC - UPDATED', place: 'San Francisco, CA', dateOfPublication: '2017', role: 'Publication' }
    * match response.subjects[*].value contains 'Readers (Primary)'

    # Step 10: Export RDF again and validate
    * def rdfCall = call getRdf { resourceId: '#(updatedResourceId)' }
    * def rdfResponse = rdfCall.response
    * def instance = karate.filter(rdfResponse, x => x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + updatedResourceId)[0]
    * def provisionActivityIds = karate.map(instance['http://id.loc.gov/ontologies/bibframe/provisionActivity'], x => x['@id'])
    * def provisionActivity = karate.filter(rdfResponse, x => x['@type'] != null && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Publication') && x['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'Chronicle Books LLC - UPDATED')[0]
    * match provisionActivity['@type'] contains 'http://id.loc.gov/ontologies/bibframe/ProvisionActivity'
    * match provisionActivity['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Publication'
    * match provisionActivity['http://id.loc.gov/ontologies/bibframe/date'][0]['@value'] == '2017'
    * match provisionActivity['http://id.loc.gov/ontologies/bflc/simpleDate'][0]['@value'] == '2017'
    * match provisionActivity['http://id.loc.gov/ontologies/bflc/simplePlace'][0]['@value'] == 'San Francisco, CA'
    * match provisionActivity['http://id.loc.gov/ontologies/bibframe/place'][0]['@id'] == 'http://id.loc.gov/vocabulary/countries/cau'
    * match provisionActivityIds contains provisionActivity['@id']

  @ignore
  @createAutority
  Scenario: Create authority & verify
    * def sourceRecordRequest = read('samples/' + fileName)
    * def postAuthorityCall = call postSourceRecordToStorage
    * match postAuthorityCall.response.qmRecordId == '#notnull'
    * def searchAuthorityCall = call searchAuthority { query: '#(query)' }
