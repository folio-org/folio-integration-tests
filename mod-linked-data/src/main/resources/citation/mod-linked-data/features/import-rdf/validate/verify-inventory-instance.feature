Feature: Import Bibframe2 RDF - Verify Inventory instance

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario:
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceId = searchCall.response.instances[0].id
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * def response = getInventoryInstanceCall.response
    * def hrid = response.hrid
    * match response.source == 'LINKED_DATA'

    * match response.identifiers[*].value contains '2015047302'
    * match response.identifiers[*].value contains '9781452152448 board bk'

    * def subjectValues = karate.map(response.subjects, function(x){ return x.value })
    * match subjectValues == '#[6]'
    * match subjectValues contains 'Readers (Primary)'
    * match subjectValues contains 'Middle East'
    * match subjectValues contains 'Delaware. General Assembly. House of representatives'
    * match subjectValues contains 'Wang, Jack 1972-'
    * match subjectValues contains 'Austria (AT)'
    * match subjectValues contains 'Private flying--Periodicals--Accidents--United States'

    * def primaryContributors = karate.filter(response.contributors, function(x){ return x.name == 'Wang, Jack 1972-' && x.primary == true })
    * match primaryContributors == '#[1]'

    * def nonPrimaryContributors = karate.filter(response.contributors, function(x){ return x.primary == false })
    * def nonPrimaryContributorNames = karate.map(nonPrimaryContributors, function(x){ return x.name })
    * match nonPrimaryContributorNames == '#[5]'
    * match nonPrimaryContributorNames contains 'Wang, Holman'
    * match nonPrimaryContributorNames contains 'Smith, John, Professor of Philosophy, 1958'
    * match nonPrimaryContributorNames contains 'Art Gallery of Hamilton (Ont.)'
    * match nonPrimaryContributorNames contains 'Delaware. General Assembly. House of representatives'
    * match nonPrimaryContributorNames contains 'International Congress on Philosophy, 2023, Vienna'

    * match response.publication contains { publisher: 'Chronicle Books LLC', place: 'San Francisco, CA', dateOfPublication: '[2016]', role: 'Publication' }
    * def ldIdentifier = karate.filter(response.identifiers, function(x){ return x.value && x.value.startsWith('(ld)'); })[0].value
    * def resourceId = ldIdentifier.replace('(ld)', '').trim()