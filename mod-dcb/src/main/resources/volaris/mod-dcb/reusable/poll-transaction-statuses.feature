Feature: Transaction status poll helper

  Background:
    * def transactionStatusPoller = read('classpath:volaris/mod-dcb/util/transaction-status-poller.js')

  @PollTransactionStatuses
  Scenario: Get Transaction status list
    * def response = transactionStatusPoller(config)

  @GetTransactionStatuses
  Scenario: Get Transaction status list after Item checked in
    Given url baseUrl
    And path path
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    And param pageSize = pageSize
    And param pageNumber = pageNumber
    When method GET
    Then status 200
