Feature: Test quickMARC holdings records
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def utilFeature = 'classpath:spitfire/mod-quick-marc/features/setup/import-record.feature'

    * def testInstanceId = karate.properties['instanceId']
    * def testHoldingsId = karate.properties['holdingsId']
    * def testQMHoldingsId = karate.properties['QMHoldingsId']

  # ================= positive test cases =================

  Scenario: Record should contains a valid 004 field
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def instanceHrid = response.externalHrid

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='004')]")[0]
    Then match tag.content == instanceHrid

  Scenario: Record should contains a 008 tag
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='008')].content != null

  Scenario: Record should contains a valid 852 location code
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='852')]")[0]
    Then match tag.content != null
    Then match tag.content contains "$b olin"

  Scenario: Quick-marc record should contains a valid 004 field
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def instanceHrid = response.externalHrid

    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='004')]")[0]
    Then match tag.content == instanceHrid

  Scenario: Quick-marc record should contains a 008 tag
    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='008')].content != null

  Scenario: Quick-marc record should contains a valid 852 location code
    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='852')]")[0]
    Then match tag.content != null
    Then match tag.content contains "$b Test Subfield"

  #   ================= negative test cases =================

  Scenario: Record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"

    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsNotValid004', jobName:'createHoldings' }
    Then match status == 'ERROR'
    Then match errorMessage == expectedMessage
