Feature: Import Bibframe2 RDF

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Import RDF file to graph
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

    # Step 3: Verify new instance in mod-inventory
    * configure headers = testUserHeaders
    * def query = 'title all "Pride & prejudice"'
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceId = searchCall.response.instances[0].id
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * print getInventoryInstanceCall.response
    * def response = getInventoryInstanceCall.response
    * match response.source == 'LINKED_DATA'
    * match response.identifiers[*].value contains '2015047302'
    * match response.identifiers[*].value contains '9781452152448 board bk'
    * match response.subjects[*].value contains 'Readers (Primary)'
    * match response.contributors contains { name: 'Wang, Jack 1972-', primary: true }
    * match response.publication contains { publisher: 'Chronicle Books LLC', place: 'San Francisco, CA', dateOfPublication: '[2016]', role: 'Publication' }
    * def ldIdentifier = karate.filter(response.identifiers, function(x){ return x.value && x.value.startsWith('(ld)'); })[0].value
    * def resourceId = ldIdentifier.replace('(ld)', '').trim()

    # Step 4: Export RDF and validate
    * def rdfCall = call getRdf
    * print rdfCall.response
    * def rdfResponse = rdfCall.response
    * def instance = karate.filter(rdfResponse, function(x){ return x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + resourceId; })[0]
    * match instance['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Instance'
    * match instance['http://id.loc.gov/ontologies/bibframe/dimensions'][0]['@value'] == '19 cm'
    * match instance['http://id.loc.gov/ontologies/bibframe/responsibilityStatement'][0]['@value'] == 'by Jack & Holman Wang'

    * def workId = instance['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def work = karate.filter(rdfResponse, function(x){ return x['@id'] == workId; })[0]
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Work'
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Monograph'
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][0]['@id'] == 'http://id.loc.gov/authorities/sh8511165'

    * def creatorId = work['http://id.loc.gov/ontologies/bibframe/contribution'][0]['@id']
    * def creator = karate.filter(rdfResponse, function(x){ return x['@id'] == creatorId; })[0]
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Contribution'
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/PrimaryContribution'
    * match creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == 'http://id.loc.gov/rwo/agents/no2012142443'
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'
