@ignore
Feature: Util feature for managing PO lines limit settings

  Background:
    * url baseUrl
    * def userHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }

  @setPoLinesLimit
  Scenario: Create or update PO lines limit setting
    # parameters: poLineLimit
    # returns: created/updated poLines limit setting

    Given path '/orders-storage/settings'
    And headers userHeaders
    And param query = 'key==poLines-limit'
    When method GET
    Then status 200

    * def existingRecord = response.totalRecords > 0 ? response.settings[0] : null
    * def existingValue = existingRecord != null ? existingRecord.value : null

    * if (existingRecord == null) karate.call('classpath:promin/data-import/global/order-lines-limit-settings.feature@createPoLinesLimit', { poLineLimit: __arg.poLineLimit })
    * if (existingRecord != null && existingValue != '' + __arg.poLineLimit) karate.fail('poLines-limit is already set to ' + existingValue + ', but expected ' + __arg.poLineLimit)

  @createPoLinesLimit
  @ignore
  Scenario: Create PO lines limit setting
    Given path '/orders-storage/settings'
    And headers userHeaders
    And request
      """
      {
        "key": "poLines-limit",
        "value": "#(__arg.poLineLimit)"
      }
      """
    When method POST
    Then status 201