Feature: update configuration

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  @TechnicalConfig
  Scenario: set technical config
    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==technical'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * print response

    * def configResponse = response
    * def technicalId = get[0] configResponse.configurationSettings[?(@.configName=='technical')].id
    * print technicalId
    * def existingConfig = get[0] configResponse.configurationSettings[?(@.configName=='technical')].configValue
    * print existingConfig

    * def updatePayload = read('classpath:samples/technical.json')

    * set updatePayload.configValue.maxRecordsPerResponse = '1'
    * set updatePayload.configValue.enableValidation = 'false'
    * set updatePayload.configValue.formattedOutput = 'false'
    * print updatePayload

    Given path '/oai-pmh/configuration-settings', technicalId
    And request updatePayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

  @BehaviorConfig
  Scenario: set behavior config
    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200

    * def configResponse = response
    * def behaviorId = get[0] configResponse.configurationSettings[?(@.configName=='behavior')].id
    * def existingConfig = get[0] configResponse.configurationSettings[?(@.configName=='behavior')].configValue

    * def updatePayload = read('classpath:samples/behavior.json')
    * set updatePayload.configValue.suppressedRecordsProcessing = 'true'
    * set updatePayload.configValue.recordsSource = 'Source record storage'
    * set updatePayload.configValue.deletedRecordsSupport = 'persistent'
    * set updatePayload.configValue.errorsProcessing = '200'
    * print updatePayload

    Given path '/oai-pmh/configuration-settings', behaviorId
    And request updatePayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204
