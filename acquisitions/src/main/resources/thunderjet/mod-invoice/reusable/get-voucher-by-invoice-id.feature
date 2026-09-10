@ignore
Feature: Get voucher by invoice id
  # parameters: invoiceId
  # returns: voucher

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Get voucher by invoice id
    Given path 'voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match response.vouchers == '#[1]'
    * def voucher = response.vouchers[0]
