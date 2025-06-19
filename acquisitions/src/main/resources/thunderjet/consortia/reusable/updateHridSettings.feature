@ignore
Feature: Update HRID settings
  # parameters: instancesPrefix, holdingsPrefix, itemsPrefix

  Background:
    * url baseUrl

  Scenario: Update HRID settings
    Given path '/hrid-settings-storage/hrid-settings'
    When method GET
    Then status 201

    * def settings = $
    * set settings.instances.prefix = instancesPrefix
    * set settings.holdings.prefix = holdingsPrefix
    * set settings.items.prefix = itemsPrefix

    Given path '/hrid-settings-storage/hrid-settings'
    And request settings
    When method PUT
    Then status 204
