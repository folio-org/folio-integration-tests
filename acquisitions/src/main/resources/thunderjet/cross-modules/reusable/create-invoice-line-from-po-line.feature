@ignore
Feature: Create invoice line from po line
  # parameters: same as createInvoiceLine but poLineId is required and encumbranceId must not be used

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create invoice line from po line
    # Get the encumbrance id
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def encumbranceId = $.fundDistribution[0].encumbrance
    * def encumbranceId = (encumbranceId == '#notpresent') ? null : encumbranceId

    # Create an invoice line linked to the po line
    * call createInvoiceLine
