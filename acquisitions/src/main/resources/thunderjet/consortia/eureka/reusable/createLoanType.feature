Feature: Create loan type

  Background:
    * url baseUrl

  Scenario: createLoanType
    Given path 'loan-types'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(name)",
      "metadata": {
        "createdDate": "2020-04-17T02:44:38.672",
        "updatedDate": "2020-04-17T02:44:38.672+0000"
      }
    }
    """
    When method POST
    Then status 201
