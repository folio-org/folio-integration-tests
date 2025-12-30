Feature: Import Bibframe2 RDF - Verify RDF

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Validate Instance
    * def rdfCall = call getRdf
    * def rdfResponse = rdfCall.response
    * print rdfResponse
    * def instance = karate.filter(rdfResponse, x => x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + resourceId)[0]
    * match instance['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Instance'
    * match instance['http://id.loc.gov/ontologies/bibframe/dimensions'][0]['@value'] == '19 cm'
    * match instance['http://id.loc.gov/ontologies/bibframe/responsibilityStatement'][0]['@value'] == 'by Jack & Holman Wang'

    * def workId = instance['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def workResourceId = workId.replace('http://localhost:8081/linked-data-editor/resources/', '').trim()
    * def work = karate.filter(rdfResponse, x => x['@id'] == workId)[0]
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Work'
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Monograph'

  @C788722
  Scenario: Validate creator of Work
    * def workContributions = work['http://id.loc.gov/ontologies/bibframe/contribution']
    * def creatorId = karate.filter(workContributions, x => x['@id'].startsWith('_:CREATOR_'))[0]['@id']
    * def creator = karate.filter(rdfResponse, x => x['@id'] == creatorId)[0]
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Contribution'
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/PrimaryContribution'
    * match creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == 'http://id.loc.gov/rwo/agents/no2012142443'
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'

  @C957382
  Scenario: Validate contributors of Work
    * def validateContributor =
      """
      function(rdfResponse, workContributions, label, expectedType, expectedRoleIds) {
        var agent = karate.filter(rdfResponse, x => {
          var labels = x['http://www.w3.org/2000/01/rdf-schema#label'];
          var hasMatchingLabel = labels && labels.some(l => l['@value'] && l['@value'].trim() == label.trim());
          return hasMatchingLabel && x['@id'] && x['@id'].endsWith('_agent');
        })[0];
        assertTrue(agent != null, 'Agent not found in RDF: ' + label);
        assertTrue(agent['@type'].length === 2 && agent['@type'].includes("http://id.loc.gov/ontologies/bibframe/Agent") && agent['@type'].includes(expectedType));
        assertTrue(agent['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].length > 0, 'Agent do not have label in RDF: ' + label)
        assertTrue(agent['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].map(x => x['@value']).includes(label), 'Agent label do not match: ' + label);
        var contribution = karate.filter(rdfResponse, x => x['http://id.loc.gov/ontologies/bibframe/agent'] && x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == agent['@id'])[0];
        assertTrue(contribution != null, 'Contribution not found: ' + label);
        assertTrue(contribution['@type'].length === 1 && contribution['@type'].includes("http://id.loc.gov/ontologies/bibframe/Contribution"), 'Contribution type do not match: ' + label);
        assertTrue(workContributions.map(x => x['@id']).includes(contribution['@id']), 'Agent Contribution reference not found in Work resource: ' + label);
        var roles = contribution['http://id.loc.gov/ontologies/bibframe/role'];
        var roleIds = roles ? roles.map(x => x['@id']) : [];
        assertTrue(expectedRoleIds.every(x => roleIds.includes(x)) && roleIds.length === expectedRoleIds.length, 'Agent roles do not match: ' + label);
      }
      """

    * eval validateContributor(rdfResponse, workContributions, 'Smith, John, Professor of Philosophy, 1958', 'http://id.loc.gov/ontologies/bibframe/Person', [])
    * eval validateContributor(rdfResponse, workContributions, 'Art Gallery of Hamilton (Ont.)', 'http://id.loc.gov/ontologies/bibframe/Organization', ['http://id.loc.gov/vocabulary/relators/isb', 'http://id.loc.gov/vocabulary/relators/his'])
    * eval validateContributor(rdfResponse, workContributions, 'Wang, Holman', 'http://id.loc.gov/ontologies/bibframe/Person', ['http://id.loc.gov/vocabulary/relators/aut'])
    * eval validateContributor(rdfResponse, workContributions, 'Delaware. General Assembly. House of representatives.', 'http://id.loc.gov/ontologies/bibframe/Jurisdiction', ['http://id.loc.gov/vocabulary/relators/fnd', 'http://id.loc.gov/vocabulary/relators/fpy'])

  Scenario: Validate subjects of Work
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][*]['@id'] contains 'http://id.loc.gov/authorities/sh85111655'
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][*]['@id'] contains 'http://id.loc.gov/rwo/agents/no2012142443'
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][*]['@id'] contains 'http://id.loc.gov/authorities/sh2008001841'
    * def validateSubject =
      """
      function(rdfResponse, work, label, expectedType) {
        var subject = karate.filter(rdfResponse, x => {
          var labels = x['http://www.w3.org/2000/01/rdf-schema#label'];
          var hasMatchingLabel = labels && labels.some(l => l['@value'] && l['@value'].trim() == label.trim());
          return hasMatchingLabel && x['@id'] && !x['@id'].endsWith('_agent');
        })[0];
        assertTrue(subject != null, 'No subject found: ' + label);
        assertTrue(
          subject['@type'].length === 2 && subject['@type'].includes("http://www.loc.gov/mads/rdf/v1#Authority") && subject['@type'].includes(expectedType),
          'Subject type do not match. Label: ' + label
        );
        assertMatch(subject['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].length > 0, true, 'Label not found in RDF: ' + label)
        assertTrue(subject['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].map(x => x['@value']).includes(label), 'Label not found in RDF: ' + label);
        assertTrue(
          work['http://id.loc.gov/ontologies/bibframe/subject'].map(x => x['@id']).includes(subject['@id']),
          'Subject reference not found in Work resource: ' + label
        );
      }
      """
    * eval validateSubject(rdfResponse, work, 'Delaware. General Assembly. House of representatives.', 'http://id.loc.gov/ontologies/bibframe/Jurisdiction')
    * eval validateSubject(rdfResponse, work, 'Austria (AT)', 'http://id.loc.gov/ontologies/bibframe/Place')
    * eval validateSubject(rdfResponse, work, 'Middle East', 'http://id.loc.gov/ontologies/bibframe/Place')

  Scenario: Validate HRID
    * def hridResource = karate.filter(rdfResponse, x => x['@type'] && x['@type'].indexOf('http://id.loc.gov/ontologies/bibframe/Local') > -1 && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'] && x['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'][0]['@value'] == hrid)[0]
    * match hridResource != null == true
    * def hridNoteId = hridResource['http://id.loc.gov/ontologies/bibframe/note'][0]['@id']
    * def hridNote = karate.filter(rdfResponse, x => x['@id'] == hridNoteId)[0]
    * match hridNote != null == true
    * match hridNote['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'FOLIO HRID'
    * def adminMetadata = karate.filter(rdfResponse, x => x['@type'] && x['@type'].indexOf('http://id.loc.gov/ontologies/bibframe/AdminMetadata') > -1)[0]
    * match adminMetadata != null == true
    * def identifiedByIds = adminMetadata['http://id.loc.gov/ontologies/bibframe/identifiedBy'].map(x => x['@id'])
    * match identifiedByIds contains hridResource['@id']
    * match instance['http://id.loc.gov/ontologies/bibframe/adminMetadata'].map(x => x['@id']) contains adminMetadata['@id']

  Scenario: Validate Creation Date
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * def creationDate = adminMetadata["http://id.loc.gov/ontologies/bibframe/creationDate"][0]["@value"]
    * match creationDate == currentDate
