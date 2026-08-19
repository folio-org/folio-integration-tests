@parallel=false
Feature: Verify OAI-PMH Behavior Configuration Settings

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  @C375138
  Scenario: Verify Behavior configuration settings have correct default values
    Given path '/oai-pmh/configuration-settings'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    And match response.configurationSettings[*].configName contains 'behavior'
    And match response.configurationSettings[*].configName contains 'technical'
    And match response.configurationSettings[*].configName contains 'general'

    * def behaviorConfig = karate.jsonPath(response, "$.configurationSettings[?(@.configName=='behavior')]")[0]
    * match behaviorConfig.configName == 'behavior'
    * match behaviorConfig.configValue.recordsSource == 'Source record storage and Inventory'
    * match behaviorConfig.configValue.errorsProcessing == '500'
    * match behaviorConfig.configValue.deletedRecordsSupport == 'persistent'
    * match behaviorConfig.configValue.suppressedRecordsProcessing == 'true'
