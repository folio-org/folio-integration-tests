@ignore
Feature: Shift fiscal year periods to make FY1 past and FY2 current
  # Parameters: fromFiscalYearId, toFiscalYearId, series (optional)
  # This feature shifts two consecutive fiscal years so that:
  # - FY1 period is moved completely to the previous year (e.g., 2024-01-01 to 2024-12-30)
  # - FY2 period is updated to include the current date (e.g., yesterday to end of current year)
  # - Updates fiscal year codes/names if series is provided

  Background:
    * url baseUrl

  Scenario: Shift fiscal year periods
    * def currentDate = call getCurrentDate
    * def yesterday = call getYesterday
    * def fromYear = parseInt(currentDate.substring(0, 4))
    * def prevYear = fromYear - 1
    * def series = karate.get('series', null)

    # Update FY1 to be completely in the past
    * def prevYearStart = prevYear + '-01-01T00:00:00Z'
    * def prevYearEnd = prevYear + '-12-30T23:59:59Z'

    Given path 'finance/fiscal-years', fromFiscalYearId
    When method GET
    Then status 200
    * def fy1 = response
    * set fy1.periodStart = prevYearStart
    * set fy1.periodEnd = prevYearEnd
    * def updateFy1Code = function(){ if (series != null) { fy1.code = series + prevYear; fy1.name = series + prevYear } }
    * eval updateFy1Code()
    Given path 'finance/fiscal-years', fromFiscalYearId
    And request fy1
    When method PUT
    Then status 204

    # Update FY2 to include current date
    * def currentYearEnd = fromYear + '-12-30T23:59:59Z'

    Given path 'finance/fiscal-years', toFiscalYearId
    When method GET
    Then status 200
    * def fy2 = response
    * set fy2.periodStart = yesterday + 'T00:00:00Z'
    * set fy2.periodEnd = currentYearEnd
    * def updateFy2Code = function(){ if (series != null) { fy2.code = series + fromYear; fy2.name = series + fromYear } }
    * eval updateFy2Code()
    Given path 'finance/fiscal-years', toFiscalYearId
    And request fy2
    When method PUT
    Then status 204

