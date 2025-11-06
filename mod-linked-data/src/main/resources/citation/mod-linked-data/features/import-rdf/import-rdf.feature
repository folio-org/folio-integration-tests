Feature: Import Bibframe2 RDF

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Import RDF file to graph & update graph using API.
    # Step 1 (Setup): create authority records referenced in the RDF file & wait till the records are available in mod-search
    * configure headers = testUserHeaders
    * def sourceRecordRequest = read('samples/authority_person_wang_jack.json')
    * def postAuthorityCall = call postSourceRecordToStorage
    * match postAuthorityCall.response.qmRecordId == '#notnull'
    * def query = '(lccn="no2012142443")'
    * def searchAuthorityCall = call searchAuthority

    * def sourceRecordRequest = read('samples/authority_subject_readers.json')
    * def postAuthorityCall = call postSourceRecordToStorage
    * match postAuthorityCall.response.qmRecordId == '#notnull'
    * def query = '(lccn="sh85111655")'
    * def searchAuthorityCall = call searchAuthority

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
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceId = searchCall.response.instances[0].id
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * def response = getInventoryInstanceCall.response
    * def hrid = response.hrid
    * match response.source == 'LINKED_DATA'
    * match response.identifiers[*].value contains '2015047302'
    * match response.identifiers[*].value contains '9781452152448 board bk'
    * match response.subjects[*].value contains 'Readers (Primary)'
    * def matchingPrimaryContributors = karate.filter(response.contributors, function(x){ return x.name == 'Wang, Jack 1972-' && x.primary == true })
    * match matchingPrimaryContributors == '#[1]'
    * match response.publication contains { publisher: 'Chronicle Books LLC', place: 'San Francisco, CA', dateOfPublication: '[2016]', role: 'Publication' }
    * def ldIdentifier = karate.filter(response.identifiers, function(x){ return x.value && x.value.startsWith('(ld)'); })[0].value
    * def resourceId = ldIdentifier.replace('(ld)', '').trim()

    # Step 5: Export RDF and validate
    * def rdfCall = call getRdf
    * def rdfResponse = rdfCall.response
    * def instance = karate.filter(rdfResponse, function(x){ return x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + resourceId; })[0]
    * match instance['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Instance'
    * match instance['http://id.loc.gov/ontologies/bibframe/dimensions'][0]['@value'] == '19 cm'
    * match instance['http://id.loc.gov/ontologies/bibframe/responsibilityStatement'][0]['@value'] == 'by Jack & Holman Wang'

    * def workId = instance['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def work = karate.filter(rdfResponse, function(x){ return x['@id'] == workId; })[0]
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Work'
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Monograph'
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][0]['@id'] == 'http://id.loc.gov/authorities/sh85111655'

    * def creatorId = work['http://id.loc.gov/ontologies/bibframe/contribution'][0]['@id']
    * def creator = karate.filter(rdfResponse, function(x){ return x['@id'] == creatorId; })[0]
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Contribution'
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/PrimaryContribution'
    * match creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == 'http://id.loc.gov/rwo/agents/no2012142443'
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'

    # Step 6: Validate HRID in graph
    * def instanceGraphCall = call getResourceGraph
    * def instanceGraph = instanceGraphCall.response

    * def adminMetadataId = instanceGraph.outgoingEdges[?(@.predicate == 'ADMIN_METADATA')].target.id
    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * retry until karate.exists(adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber']) == true
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber'][0] == hrid

    # Step 7: Update instance resource using API
    * def getResourceCall = call getResource { id: "#(resourceId)" }
    * def updateInstanceRequest = JSON.parse(JSON.stringify(getResourceCall.response))
    * def instance = updateInstanceRequest.resource['http://bibfra.me/vocab/lite/Instance']
    * set instance['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title']['http://bibfra.me/vocab/library/mainTitle'][0] = "Jane Austen's Pride & prejudice UPDATED"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/date'][0] = "2017"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/name'][0] = "Chronicle Books LLC - UPDATED"
    * set instance['http://bibfra.me/vocab/library/publication'][0]['http://bibfra.me/vocab/lite/providerDate'][0] = "2017"
    * set instance['http://library.link/vocab/map'][0]['http://library.link/identifier/LCCN']['http://bibfra.me/vocab/lite/name'][0] = "2015047302-UPDATED"
    * set instance['http://library.link/vocab/map'][1]['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/lite/name'][0] = "9781452152448-UPDATED"
    * set instance['_workReference'][0] = { id: "3176037407120150133" }
    * def putCall = call putResource { id: '#(resourceId)' , resourceRequest: '#(updateInstanceRequest)' }
    * def updatedResourceId = putCall.response.resource['http://bibfra.me/vocab/lite/Instance'].id

    # Step 8: Validate updated resource in invetnory
    * def query = 'title all "Pride & prejudice" UPDATED'
    * def searchCall = call searchInventoryInstance
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * def response = getInventoryInstanceCall.response
    * def ldIdentifiers = karate.filter(response.identifiers, function(x){ return x.value && x.value.startsWith('(ld)'); })
    * match ldIdentifiers == '#[1]'
    * match ldIdentifiers[0].value == '(ld) ' + updatedResourceId
    * match response.source == 'LINKED_DATA'
    * match response.identifiers[*].value contains '2015047302-UPDATED'
    * match response.identifiers[*].value contains '9781452152448-UPDATED board bk'
    * match response.publication contains { publisher: 'Chronicle Books LLC - UPDATED', place: 'San Francisco, CA', dateOfPublication: '2017', role: 'Publication' }
    * match response.subjects[*].value contains 'Readers (Primary)'

    # Step 9: Export RDF again and validate
    * def rdfCall = call getRdf { resourceId: '#(updatedResourceId)' }
    * def rdfResponse = rdfCall.response
    * def instance = karate.filter(rdfResponse, function(x){ return x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + updatedResourceId; })[0]
    * def provisionActivityId = instance['http://id.loc.gov/ontologies/bibframe/provisionActivity'][0]['@id']
    * def provisionActivity = karate.filter(rdfResponse, function(x){ return x['@id'] == provisionActivityId; })[0]
    * match provisionActivity['@type'] contains 'http://id.loc.gov/ontologies/bibframe/ProvisionActivity'
    * match provisionActivity['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Publication'
    * match provisionActivity['http://id.loc.gov/ontologies/bibframe/date'][0]['@value'] == '2017'
    * match provisionActivity['http://id.loc.gov/ontologies/bflc/simpleDate'][0]['@value'] == '2017'
    * match provisionActivity['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'Chronicle Books LLC - UPDATED'
    * match provisionActivity['http://id.loc.gov/ontologies/bflc/simplePlace'][0]['@value'] == 'San Francisco, CA'
    * match provisionActivity['http://id.loc.gov/ontologies/bibframe/place'][0]['@id'] == 'http://id.loc.gov/vocabulary/countries/cau'