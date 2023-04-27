Feature: create electronic access relationship

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapiTokenAdmin = okapitoken

  @TechnicalConfig
  Scenario: set technical config
    Given path 'configurations/entries'
      And param query = 'module==OAIPMH and configName==technical'
      And header Accept = 'application/json'
      And header Content-Type = 'application/json'
      And header x-okapi-token = okapiTokenAdmin
      When method GET
      Then status 200

    * def configId = response.configs[0].id

    Given path 'configurations/entries', configId
    And request
    """
    {
      "module" : "OAIPMH",
      "configName" : "technical",
      "enabled" : true,
      "value" : "{\"maxRecordsPerResponse\":\"1\",\"enableValidation\":\"false\",\"formattedOutput\":\"false\"}"
    }
    """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    When method PUT
    Then status 204