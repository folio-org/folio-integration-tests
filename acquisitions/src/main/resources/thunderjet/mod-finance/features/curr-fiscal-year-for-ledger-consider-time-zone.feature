Feature:  Return current fiscal year consider time zone

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    * callonce variables

    * def fiscalYearId = callonce uuid1
    * def ledgerId = callonce uuid2
    * def configUUID = callonce uuid3
    * def codePrefix = callonce random_string
    * def year = callonce getCurrentYear
    * def yesterday = callonce getYesterday
    * print "Yesterday date : " + yesterday

  Scenario: prepare fiscal year

    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": '#(fiscalYearId)',
      "name": '#(codePrefix + year)',
      "code": '#(codePrefix + year)',
      "periodStart": '#(yesterday + "T00:00:00Z")',
      "periodEnd": '#(yesterday + "T23:59:59Z")'
    }
    """
    When method POST
    Then status 201


  Scenario: prepare finances for ledger
    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(ledgerId)",
      "ledgerStatus": "Active",
      "name": "#(ledgerId)",
      "code": "#(ledgerId)",
      "fiscalYearOneId":"#(fiscalYearId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Create configuration with Pacific/Midway timezone
    Given path 'configurations/entries'
    And request
    """
    {
      "id": "#(configUUID)",
      "module": "ORG",
      "configName": "localeSettings",
      "enabled": true,
      "value": "{\"locale\":\"en-US\",\"timezone\":\"Pacific/Midway\",\"currency\":\"USD\"}"
    }
    """
    When method POST
    Then status 201

  Scenario: Get current fiscal year for ledger if timezone Pacific/Midway
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 200
    And match $.id == '#(fiscalYearId)'

  Scenario: update configuration with UTC timezone
    Given path 'configurations/entries', configUUID
    And request
    """
    {
      "id": "#(configUUID)",
      "module": "ORG",
      "configName": "localeSettings",
      "enabled": true,
      "value": "{\"locale\":\"en-US\",\"timezone\":\"Europe/Minsk\",\"currency\":\"USD\"}"
    }
    """
    When method PUT
    Then status 204

  Scenario: Get current fiscal year for ledger if timezone Europe/Minsk
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 404


  Scenario: Delete ledger
    Given path 'finance/ledgers', ledgerId
    When method DELETE
    Then status 204

  Scenario: Delete fiscal year
    Given path 'finance/fiscal-years', fiscalYearId
    When method DELETE
    Then status 204

  Scenario: Delete configuration with Pacific/Midway timezone
    Given path 'configurations/entries',configUUID
    When method DELETE
    Then status 204
