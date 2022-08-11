@parallel=false
Feature: Inn reach transaction Helper

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * print 'proxyCall', proxyCall
    * def user = proxyCall == false ? testUser : testUserEdge

    * callonce login user
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-to-code': 'fli01' , 'x-from-code': 'd2ir', 'x-d2ir-authorization':'auth','Accept': 'application/json'  }

    * configure headers = headersUser

  @GetTransaction
  Scenario: Get Item Transaction
    * print 'Get Item Transaction'
    Given path '/inn-reach/transactions'
    And param limit = 100
    And param offset = 0
    And param sortBy = 'transactionTime'
    And param sortOrder = 'desc'
    And param type = transactionType
    When method GET
    Then status 200