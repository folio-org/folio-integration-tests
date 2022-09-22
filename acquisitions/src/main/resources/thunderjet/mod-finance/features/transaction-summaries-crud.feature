Feature: Transaction summaries CRUD

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * def invTransSumId = callonce uuid

  Scenario: CRUD invoice-transaction-summaries flow

    Given path 'finance/invoice-transaction-summaries'
    And request
    """
      {
        "id": '#(invTransSumId)',
        "numPendingPayments": 3,
        "numPaymentsCredits": 4
      }

    """
    When method POST
    Then status 201


    Given path 'finance/invoice-transaction-summaries', invTransSumId
    And request
    """
      {
        "id": '#(invTransSumId)',
        "numPendingPayments": 9,
        "numPaymentsCredits": 7
      }
    """
    When method PUT
    Then status 204


    Given path 'finance-storage/invoice-transaction-summaries', invTransSumId
    And request
    When method GET
    Then status 200
    And match response.numPendingPayments == 9
    And match response.numPaymentsCredits == 7