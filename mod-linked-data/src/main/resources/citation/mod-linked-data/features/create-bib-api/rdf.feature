Feature: Derived Bibframe2 RDF

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def baseResourceUrl = 'http://localhost:8081/linked-data-editor/resources/'

  Scenario: Validate Bibframe2 RDF
    * def rdfCall = call getRdf { resourceId:  '#(instanceId)' }
    * def rdf = rdfCall.response

    * def instance = rdf.filter(x => x['@id'] == baseResourceUrl + instanceId)[0]
    * match instance['http://id.loc.gov/ontologies/bibframe/dimensions'][*]['@value'] contains '8x8'
    * match instance['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Instance'
    * match instance['http://id.loc.gov/ontologies/bibframe/title'] == '#[3]'
    * match instance['http://id.loc.gov/ontologies/bibframe/title'][*]['@id'] contains baseResourceUrl + instanceMainTitleId
    * match instance['http://id.loc.gov/ontologies/bibframe/instanceOf'][*]['@id'] contains baseResourceUrl + workId

    * def title = rdf.filter(x => x['@id'] == baseResourceUrl + instanceMainTitleId)[0]
    * match title['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Title'
    * match title['http://id.loc.gov/ontologies/bibframe/mainTitle'][0]['@value'] == 'create-bib-title'
    * match title['http://id.loc.gov/ontologies/bibframe/partName'][0]['@value'] == 'part 3'
    * match title['http://id.loc.gov/ontologies/bibframe/partNumber'][0]['@value'] == '3'
    * match title['http://id.loc.gov/ontologies/bibframe/subtitle'][0]['@value'] == 'Instance Sub title'

    * def work = rdf.filter(x => x['@id'] == baseResourceUrl + workId)[0]
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Work'
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Monograph'
    * match work['http://id.loc.gov/ontologies/bibframe/title'] == '#[1]'

  @C813010
  Scenario: Validate ISBN, LCCN and EAN
    * match instance['http://id.loc.gov/ontologies/bibframe/identifiedBy'] == '#[3]'

    * def isbnObj = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Isbn') && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'] && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'][0]['@value'] == '0987654321')[0]
    * match isbnObj['http://id.loc.gov/ontologies/bibframe/qualifier'][0]['@value'] == 'Hardcover'
    * match isbnObj['http://id.loc.gov/ontologies/bibframe/status'][0]['@id'] == 'http://id.loc.gov/vocabulary/mstatus/current'
    * match instance['http://id.loc.gov/ontologies/bibframe/identifiedBy'].map(x => x['@id']) contains isbnObj['@id']

    * def lccnObj = rdf.filter(x =>x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Lccn') && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'] && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'][0]['@value'].trim() == '1234567890')[0]
    * match lccnObj['http://id.loc.gov/ontologies/bibframe/status'][0]['@id'] == 'http://id.loc.gov/vocabulary/mstatus/current'
    * match instance['http://id.loc.gov/ontologies/bibframe/identifiedBy'].map(x => x['@id']) contains lccnObj['@id']

    * def eanObj = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Ean') && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'] && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'][0]['@value'] == 'IAN value')[0]
    * match eanObj['http://id.loc.gov/ontologies/bibframe/qualifier'][0]['@value'] == 'IAN Qualifier'
    * match instance['http://id.loc.gov/ontologies/bibframe/identifiedBy'].map(x => x['@id']) contains eanObj['@id']
