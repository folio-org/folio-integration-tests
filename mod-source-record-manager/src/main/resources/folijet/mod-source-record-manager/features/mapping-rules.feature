Feature: Source-Record-Storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def marc_bib_rules = read('classpath:samples/marc-bib.json')
    * def marc_holdings_rules = read('classpath:samples/marc-holdings.json')
    * def marc_authority_rules = read('classpath:samples/marc-authority.json')

  @Positive
  Scenario: GET 'mapping-rules/marc-bib' should return 200 and rules json
    Given path 'mapping-rules', 'marc-bib'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'modeOfIssuanceId'

  @Positive
  Scenario: GET 'mapping-rules/marc-holdings' should return 200 and rules json
    Given path 'mapping-rules', 'marc-holdings'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'holdingsTypeId'

  @Positive
  Scenario: GET 'mapping-rules/marc-authority' should return 200 and rules json
    Given path 'mapping-rules', 'marc-authority'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'identifiers.identifierTypeId'


  @Positive
  Scenario: PUT 'mapping-rules/marc-bib' should update rules, THEN restore default rules
    Given path 'mapping-rules', 'marc-bib'
    And request marc_bib_rules
    When method PUT
    Then status 200
    And match response.Marc bib rules == '#present'

    Given path 'mapping-rules', 'marc-bib', 'restore'
    When method PUT
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'modeOfIssuanceId'

  @Positive
  Scenario: PUT 'mapping-rules/marc-holdings' should update rules, THEN restore default rules
    Given path 'mapping-rules', 'marc-holdings'
    And request marc_holdings_rules
    When method PUT
    Then status 200
    And match response.Marc holdings rules == '#present'

    Given path 'mapping-rules', 'marc-holdings', 'restore'
    When method PUT
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'holdingsTypeId'

  @Positive
  Scenario: PUT 'mapping-rules/marc-holdings/restore' should restore default rules
    Given path 'mapping-rules', 'marc-authority', 'restore'
    When method PUT
    Then status 200
    And match responseType == 'json'
    And match response.001[1].target == 'identifiers.identifierTypeId'

  @Negative
  Scenario: GET 'mapping-rules' with wrong path should return 400 and text message
    Given path 'mapping-rules', 'wrong-path'
    When method GET
    Then status 400
    And match response == 'Only marc-bib, marc-holdings or marc-authority supported'

  @Negative
  Scenario: PUT 'mapping-rules/marc-authority' should return 400 for authorities
    Given path 'mapping-rules', 'marc-authority'
    And request marc_authority_rules
    When method PUT
    Then status 400
    And match response == 'Can\'t edit MARC Authority default mapping rules'

  @Negative
  Scenario: PUT 'mapping-rules' with wrong path should return 400 and text message
    Given path 'mapping-rules', 'wrong-path'
    And request marc_holdings_rules
    When method PUT
    Then status 400
    And match response == 'Only marc-bib or marc-holdings supported'

  @Negative
  Scenario: PUT 'mapping-rules/restore' with wrong path should return 400 and text message
    Given path 'mapping-rules', 'wrong-path', 'restore'
    When method PUT
    Then status 400
    And match response == 'Only marc-bib or marc-holdings supported'