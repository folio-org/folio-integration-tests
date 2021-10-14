Feature: Loans

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: When a new circulation rule is entered in the circulation editor, add the rule to the circulation rules record
    * def circulationRuleRequest = read('samples/circulation-rule-entity.json')
    * def circulationRulesAsText = circulationRuleRequest.rulesAsText
    * call read('classpath:domain/mod-circulation/features/util/prepareData.feature@CreateCirculationRule') {rulesAsText: circulationRulesAsText}
    
    Given path 'circulation/rules'
    When method GET
    Then status 200
    And match response.rulesAsText == circulationRulesAsText


