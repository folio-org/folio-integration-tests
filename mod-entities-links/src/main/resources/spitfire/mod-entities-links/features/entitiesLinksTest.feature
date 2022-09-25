Feature: mod-entities-links tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples/links/'
    * def authorityId = karate.properties['authorityId']
    * def secondAuthorityId = karate.properties['secondAuthorityId']
    * def instanceId = karate.properties['instanceId']
    * def secondInstanceId = karate.properties['secondInstanceId']

#   ================= positive test cases =================

  @Positive
  Scenario: Put link - Should create link
    Given path '/links/instances', instanceId
    And request read(samplePath + 'createLink.json')
    When method PUT
    Then status 204

    Given path '/links/instances', instanceId
    When method GET
    Then status 200

  @Positive
  Scenario: Put link - Should update existed link
    Given path '/links/instances', instanceId
    When method GET
    Then status 200

  @Positive
  Scenario: Put link - Should add only new links
    * print 'undefined'

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
    Then match response.errors[0].parameters[0].value == randomId

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
