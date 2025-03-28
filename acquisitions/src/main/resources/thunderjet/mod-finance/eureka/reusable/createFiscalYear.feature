Feature: Create fiscal year
  # parameters: id, code, periodStart, periodEnd, series

  Background:
    * url baseUrl

  Scenario: Create Fiscal Year
    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(code)",
      "code": "#(code)",
      "description": "#(code)",
      "periodStart": "#(periodStart)",
      "periodEnd": "#(periodEnd)",
      "series": "#(series)"
    }
    """
    When method POST
    Then status 201
