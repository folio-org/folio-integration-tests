# FIXME This test is disabled because it is flaky
# configuration updates were removed in MODORDERS-1373 but the test makes no sense without
Feature: Return current fiscal year consider time zone

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

  Scenario: Return current fiscal year consider time zone
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def configUUID = call uuid
    * def codePrefix = call random_string
    * def year = call getCurrentYear
    * def yesterday = call getYesterday
    * print "Yesterday date : " + yesterday

    # 1. Prepare fiscal year
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: '#(codePrefix + year)', periodStart: '#(yesterday + "T00:00:00Z")', periodEnd: '#(yesterday + "T23:59:59Z")' }

    # 2. Prepare finances for ledger
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }

    # 3. Create configuration with Pacific/Midway timezone
    * configure headers = headersAdmin
    Given path 'configurations/entries'
    And request
      """
    {
      "id": "#(configUUID)",
      "module": "ORG",
      "configName": "localeSettings",
      "enabled": true,
      "code": "#(configUUID)",
      "value": "{\"locale\":\"en-US\",\"timezone\":\"Pacific/Midway\",\"currency\":\"USD\"}"
    }
    """
    When method POST
    Then status 201

    # 4. Get current fiscal year for ledger if timezone Pacific/Midway
    * configure headers = headersUser
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 200
    And match $.id == '#(fiscalYearId)'

  # 5. Update configuration with UTC timezone
    * configure headers = headersAdmin
    Given path 'configurations/entries', configUUID
    And request
      """
    {
      "id": "#(configUUID)",
      "module": "ORG",
      "configName": "localeSettings",
      "enabled": true,
      "code": "#(configUUID)",
      "value": "{\"locale\":\"en-US\",\"timezone\":\"Europe/Minsk\",\"currency\":\"USD\"}"
    }
    """
    When method PUT
    Then status 204

    # 6. Get current fiscal year for ledger if timezone Europe/Minsk
    * configure headers = headersUser
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 404

    # 7. Delete configuration with Pacific/Midway timezone
    * configure headers = headersAdmin
    Given path 'configurations/entries',configUUID
    When method DELETE
    Then status 204
