Feature: Testing Borrowing-Pickup Cancellation Flow

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser

      # load global variables
    * callonce variables

  Scenario: Create transaction
    * def transaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-for-borrower.json')
    Given path 'transactions' , transactionId
    And request transaction
    When method POST
    Then status 201



