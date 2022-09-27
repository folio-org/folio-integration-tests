Feature: mod-entities-links tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples/links/'
    * def removeLinks = 'entitiesLinksTest.feature@RemoveLinks'

    * def authorityId = karate.properties['authorityId']
    * def secondAuthorityId = karate.properties['secondAuthorityId']

    * def instanceId = karate.properties['instanceId']
    * def secondInstanceId = karate.properties['secondInstanceId']

  @Ignore #Util scenario, accept 'instanceId' parameter
  @RemoveLinks
  Scenario: Put link - Should remove all links for instance
    Given path '/links/instances', instanceId
    And request {'links': [] }
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200
    Then match response.totalRecords == 0

  @Positive
  Scenario: Put link - Should link authority to instance
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200
    Then assert response.links.length > 0
    Then assert response.totalRecords > 0

    * call read(removeLinks)

  @Positive
  Scenario: Put link - Should link one authority for two instances
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200
    Then assert response.links.length > 0
    Then assert response.totalRecords > 0

    Given path '/links/instances', secondInstanceId
    And def link = read(samplePath + 'createLink.json')
    And set link.links[0].instanceId = secondInstanceId
    And request link
    When method PUT
    Then status 204

    Given path '/links/instances', secondInstanceId
    When method GET
    Then status 200
    Then assert response.links.length > 0
    Then assert response.totalRecords > 0

    * call read(removeLinks)
    * call read(removeLinks) {instanceId: secondInstanceId}

  @Positive
  Scenario: Put link - Should update tag for existed links
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createTwoLinks.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    And def links = read(samplePath + 'createTwoLinks.json')
    And set links.links[0].bibRecordTag = '010'
    And set links.links[1].bibRecordTag = '999'
    And request links
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200
    Then assert response.totalRecords > 0
    Then match response.links[0].bibRecordTag == '010'
    Then match response.links[1].bibRecordTag == '999'

    * call read(removeLinks)

  @Positive
  Scenario: Put link - Should save only new links
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    And request read(samplePath + 'createTwoLinks.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200
    Then assert response.totalRecords == 2

    * call read(removeLinks)

  @Positive
  @Undefined
  Scenario: Post bulk count links - should count links for authority
    * print 'undefined'

  @Negative
  Scenario: Put link - instanceId not matched with link
    * def randomId = uuid()
    Given path '/links/instances', randomId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'Link should have instanceId = ' + randomId
    Then match response.errors[0].parameters[0].value == instanceId

  @Negative
  @Ignore #For now we can link non existed records
  Scenario: Put link - link non existed instance
    * def instanceId = uuid()
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'Instance not exist'

  @Negative
  @Ignore #For now we can link non existed records
  Scenario: Put link - link non existed authority
    * def authorityId = uuid()
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'Authority not exist'

  @Negative
  Scenario: Put link - bib record tag larger than 100
    Given path '/links/instances', instanceId
    And def link = read(samplePath + 'createLink.json');
    And set link.links[0].bibRecordTag = 99999
    And request link
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'must match \"^[0-9]{3}$\"'
    Then match response.errors[0].parameters[0].key == 'links[0].bibRecordTag'

  @Negative
  Scenario: Put link - empty subfields
    Given path '/links/instances', instanceId
    And def link = read(samplePath + 'createLink.json');
    And remove link.links[0].bibRecordSubfields
    And request link
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'size must be between 1 and 100'
    Then match response.errors[0].parameters[0].key == 'links[0].bibRecordSubfields'

  @Negative
  Scenario: Put link - subfield more than one character
    Given path '/links/instances', instanceId
    And def link = read(samplePath + 'createLink.json');
    And set link.links[0].bibRecordSubfields[0] = 'ab'
    And request link
    When method PUT
    Then status 422
    Then match response.errors[0].message == 'Max Bib record subfield length is 1'
    Then match response.errors[0].parameters[0].key == 'bibRecordSubfields'

  @Negative
  @Undefined
  Scenario: Post bulk count links - empty ids array
    * print 'undefined'
