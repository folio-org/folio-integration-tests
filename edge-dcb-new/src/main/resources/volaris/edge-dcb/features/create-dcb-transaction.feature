Feature: Testing createDCBTransaction

  Background:
     * url baseUrl
     * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
     * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Create DCB Transaction
    * def dcbTransactionId = '123456'

    Given path '/transactions/ + dcbTransactionId
    And request
    """
    {
        "dcBItem":  #(dcBItem),
        "dcBPatron": #(dcBPatron)
    }
    """
    When method POST
    Then status 501