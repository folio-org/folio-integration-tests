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
    * print response
    Then status 200

    * def configId = response.configurationSettings[0].id
    * def existingConfig = response.configurationSettings[0]

    # Create the update payload preserving the existing structure
    * def updatePayload = existingConfig
    * set updatePayload.configValue.maxRecordsPerResponse = '1'
    * set updatePayload.configValue.enableValidation = 'false'
    * set updatePayload.configValue.formattedOutput = 'false'

    Given path '/oai-pmh/configuration-settings', configId
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
    * print response
    Then status 200

    * def configId = response.configurationSettings[0].id
    * def existingConfig = response.configurationSettings[0]

    # Create the update payload preserving the existing structure
    * def updatePayload = existingConfig
    * set updatePayload.configValue.suppressedRecordsProcessing = 'true'
    * set updatePayload.configValue.recordsSource = 'Source record storage'
    * set updatePayload.configValue.deletedRecordsSupport = 'persistent'
    * set updatePayload.configValue.errorsProcessing = '200'

    Given path '/oai-pmh/configuration-settings', configId
    And request updatePayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204
