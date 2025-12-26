# This test is disabled because it is flaky
@parallel=false
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
    * def fiscalYearId = call uuid1
    * def ledgerId = call uuid2
    * def configUUID = call uuid3
    * def codePrefix = call random_string
    * def year = call getCurrentYear
    * def yesterday = call getYesterday
    * print "Yesterday date : " + yesterday

    # 1. Prepare fiscal year
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

    # 2. Prepare finances for ledger
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

    # 3. Get current fiscal year for ledger if timezone Pacific/Midway
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 200
    And match $.id == '#(fiscalYearId)'

    # 4. Get current fiscal year for ledger if timezone Europe/Minsk
    Given path 'finance/ledgers', ledgerId, '/current-fiscal-year'
    When method GET
    Then status 404

    # 5. Delete ledger
    Given path 'finance/ledgers', ledgerId
    When method DELETE
    Then status 204

    # 6. Delete fiscal year
    Given path 'finance/fiscal-years', fiscalYearId
    When method DELETE
    Then status 204