@ignore
Feature: Collection of different verifcation of invoice line

  Background:
    * url baseUrl

  @Ignore @VerifyInvoiceLine
  Scenario: Verify invoice line
    Given path 'invoice/invoice-lines', _invoiceLineId
    When method GET
    Then status 200
    And match $.fundDistributions[0].fundId == _fundId
    And match $.fundDistributions[0].code == _fundCode
    And match $.fundDistributions[0].encumbrance == _encumbrance

