@ignore
Feature: Upsert createInventory orders-storage setting
  # parameters: eresource, physical, other
  # Sets the mod-orders Inventory interaction defaults via /orders-storage/settings.
  # POSTs when the setting does not exist yet, otherwise PUTs an updated value.

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Upsert Create Inventory Setting
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def newValue = '{"eresource":"' + eresource + '","physical":"' + physical + '","other":"' + other + '"}'

    # Look up existing setting (if any) by key
    Given path 'orders-storage/settings'
    And param query = 'key==createInventory'
    And headers headersAdmin
    When method GET
    Then status 200

    # Branch: PUT existing or POST new
    * def upsert =
    """
    function() {
      if (response.settings.length > 0) {
        var setting = response.settings[0];
        setting.value = newValue;
        return karate.call('classpath:thunderjet/mod-orders/reusable/put-orders-setting.feature', { setting: setting, headersAdmin: headersAdmin });
      }
      return karate.call('classpath:thunderjet/mod-orders/reusable/post-orders-setting.feature', { key: 'createInventory', value: newValue, headersAdmin: headersAdmin });
    }
    """
    * eval upsert()