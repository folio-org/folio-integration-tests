Feature: backdateFY

  Background:
    * url baseUrl

  Scenario: Change the FY with given id to use a period in the previous year
    Given path 'finance/fiscal-years', id
    When method GET
    Then status 200
    * def fy = $
    * def yearStart = parseInt(fy.periodStart.substring(0, 4)) - 1
    * set fy.periodStart = yearStart + fy.periodStart.substring(4)
    * def yearEnd = parseInt(fy.periodEnd.substring(0, 4)) - 1
    * set fy.periodEnd = yearEnd + fy.periodEnd.substring(4)

    * def previousYear = parseInt(fromYear) - 1
    Given path 'finance/fiscal-years', id
    And request fy
    When method PUT
    Then status 204
