Feature: Verify exported Bibframe2 RDF
  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def baseResourceUrl = 'http://localhost:8081/linked-data-editor/resources/'

  Scenario: Fetch Instance Subgraph
    * def rdfCall = call getRdf { resourceId:  '#(instanceResourceId)' }
    * def rdf = rdfCall.response
    * def instanceRdf = rdf.filter(x => x['@id'] == baseResourceUrl + instanceResourceId)[0]
    * def workId = instanceRdf['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def workRdf = rdf.filter(x => x['@id'] == workId)[0]

  Scenario: Verify Creator of work (Rally ID C805759)
    * def contributionIds = workRdf['http://id.loc.gov/ontologies/bibframe/contribution'].map(x => x['@id'])
    * def contributorsRdfs = contributionIds.map(id => rdf.filter(x => x['@id'] == id)[0])
    * def creator = contributorsRdfs.filter(x => x['@type'].includes('http://id.loc.gov/ontologies/bibframe/PrimaryContribution'))[0]
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'
    * def creatorAgentId = creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def creatorAgent = rdf.filter(x => x['@id'] == creatorAgentId)[0]
    * match creatorAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match creatorAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Person'
    * match creatorAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Edgell, David L., Sr., David Lee, 1938'

  Scenario: Verify Contributors of work (Rally ID C805759)
    * def contributors = contributorsRdfs.filter(x => !x['@type'].includes('http://id.loc.gov/ontologies/bibframe/PrimaryContribution'))

    * def familyContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Rinehart family, Rinehart, Family Rinehart')[0]
    * def familyAgentId = familyContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def familyAgent = rdf.filter(x => x['@id'] == familyAgentId)[0]
    * match familyAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match familyAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Family'
    * match familyAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Rinehart family, Rinehart, Family Rinehart'

    * def personContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'VI, Edward, King of England, 1537-1553')[0]
    * def personAgentId = personContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def personAgent = rdf.filter(x => x['@id'] == personAgentId)[0]
    * match personAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match personAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Person'
    * match personAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'VI, Edward, King of England, 1537-1553'

    * def organizationContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :')[0]
    * def organizationAgentId = organizationContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def organizationAgent = rdf.filter(x => x['@id'] == organizationAgentId)[0]
    * match organizationAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match organizationAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Organization'
    * match organizationAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :'

    * def meetingContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia')[0]
    * def meetingAgentId = meetingContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def meetingAgent = rdf.filter(x => x['@id'] == meetingAgentId)[0]
    * match meetingAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match meetingAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Meeting'
    * match meetingAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia'

