Feature: Import Bibframe2 RDF - Verify RDF

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario:
    * def rdfCall = call getRdf
    * def rdfResponse = rdfCall.response
    * print rdfResponse
    * def instance = karate.filter(rdfResponse, function(x){ return x['@id'] == 'http://localhost:8081/linked-data-editor/resources/' + resourceId; })[0]
    * match instance['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Instance'
    * match instance['http://id.loc.gov/ontologies/bibframe/dimensions'][0]['@value'] == '19 cm'
    * match instance['http://id.loc.gov/ontologies/bibframe/responsibilityStatement'][0]['@value'] == 'by Jack & Holman Wang'

    * def workId = instance['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def workResourceId = workId.replace('http://localhost:8081/linked-data-editor/resources/', '').trim()
    * def work = karate.filter(rdfResponse, function(x){ return x['@id'] == workId; })[0]
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Work'
    * match work['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Monograph'
    * match work['http://id.loc.gov/ontologies/bibframe/subject'][0]['@id'] == 'http://id.loc.gov/authorities/sh85111655'

    # Validate creator of Work
    * def workContributions = work['http://id.loc.gov/ontologies/bibframe/contribution']
    * def creatorId = karate.filter(workContributions, function(x){ return x['@id'].startsWith('_:CREATOR_'); })[0]['@id']
    * def creator = karate.filter(rdfResponse, function(x){ return x['@id'] == creatorId; })[0]
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Contribution'
    * match creator['@type'] contains 'http://id.loc.gov/ontologies/bibframe/PrimaryContribution'
    * match creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == 'http://id.loc.gov/rwo/agents/no2012142443'
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'

    # Validate contributors
    * def validateContributor =
    """
    function(rdfResponse, workContributions, label, expectedType, expectedRoleIds) {
      var labels = rdfResponse.map(function(x){
        return x['http://www.w3.org/2000/01/rdf-schema#label'] ? x['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] : null;
      });
      var agent = karate.filter(rdfResponse, function(x){
        return x['http://www.w3.org/2000/01/rdf-schema#label'] &&
               x['http://www.w3.org/2000/01/rdf-schema#label'][0] &&
               x['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] &&
               x['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'].trim() == label.trim();
      })[0];
      karate.match(agent != null, true);
      karate.match(agent['@type'], { containsOnly: ['http://id.loc.gov/ontologies/bibframe/Agent', expectedType] });
      karate.match(agent['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].length, 1)
      karate.match(agent['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'][0]['@value'], label)
      var contribution = karate.filter(rdfResponse, function(x){
        return x['http://id.loc.gov/ontologies/bibframe/agent'] &&
               x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'] == agent['@id'];
      })[0];
      karate.match(contribution != null, true);
      karate.match(contribution['@type'], { containsOnly: ['http://id.loc.gov/ontologies/bibframe/Contribution'] });
      karate.match(workContributions.map(function(x){return x['@id'];}), { contains: contribution['@id'] });
      var roles = contribution['http://id.loc.gov/ontologies/bibframe/role'];
      var roleIds = roles ? roles.map(function(x){ return x['@id']; }) : [];
      karate.match(roleIds, { containsOnly: expectedRoleIds });
    }
    """

    * validateContributor(rdfResponse, workContributions, 'Smith, John, Professor of Philosophy, 1958', 'http://id.loc.gov/ontologies/bibframe/Person', [])
    * validateContributor(rdfResponse, workContributions, 'Art Gallery of Hamilton (Ont.)', 'http://id.loc.gov/ontologies/bibframe/Organization', ['http://id.loc.gov/vocabulary/relators/isb', 'http://id.loc.gov/vocabulary/relators/his'])
    * validateContributor(rdfResponse, workContributions, 'Wang, Holman', 'http://id.loc.gov/ontologies/bibframe/Person', ['http://id.loc.gov/vocabulary/relators/aut'])
    * validateContributor(rdfResponse, workContributions, 'Delaware. General Assembly. House of representatives.', 'http://id.loc.gov/ontologies/bibframe/Jurisdiction', ['http://id.loc.gov/vocabulary/relators/fnd', 'http://id.loc.gov/vocabulary/relators/fpy'])