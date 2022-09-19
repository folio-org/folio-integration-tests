Feature: mod-entities-links tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/samples/links'
    * def authorityId = karate.properties['authorityId']
    * def instanceId = karate.properties['instanceId']

#   ================= positive test cases =================

  @Undefined
  Scenario: Put link - Should create link
    * print 'undefined'

  @Undefined
  Scenario: Put link - Should update existed link
    * print 'undefined'

  @Undefined
  Scenario: Put link - Should add only new links
    * print 'undefined'

  @Undefined
  Scenario: Post bulk count links - should count links for authority
    * print 'undefined'

#   ================= negative test cases =================

  @Undefined
  Scenario: Put link - instanceId not matched with link
    * print 'undefined'

  @Undefined
  Scenario: Put link - instanceId not uuid
    * print 'undefined'

  @Undefined
  Scenario: Put link - empty body
    * print 'undefined'

  @Undefined
  Scenario: Put link - bib record tag larger than 100
    * print 'undefined'

  @Undefined
  Scenario: Put link - subfield more than one character
    * print 'undefined'

  @Undefined
  Scenario: Post bulk count links - empty ids array
    * print 'undefined'
