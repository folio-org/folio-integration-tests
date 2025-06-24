@ignore
Feature: checkOrderLine
  # parameters: poLineNumber, titleOrPackage, listUnitPrice?, listUnitPriceElectronic?,
  # currency?, quantityPhysical?, quantityElectronic?, paymentStatus?, receiptStatus?, checkinItems?

  Background:
    * url baseUrl

  Scenario: checkOrderLine
    Given path "orders/order-lines"
    And param query = "poLineNumber==" + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == "#[1]"
    And match each $.poLines[*].titleOrPackage == titleOrPackage
    And match $.poLines[*].cost.listUnitPrice contains karate.get("listUnitPrice", [])
    And match $.poLines[*].cost.listUnitPriceElectronic contains karate.get("listUnitPriceElectronic", [])
    And match each $.poLines[*].cost.currency == karate.get("currency", "USD")
    And match each $.poLines[*].cost.quantityPhysical == karate.get("quantityPhysical", 0)
    And match each $.poLines[*].cost.quantityElectronic == karate.get("quantityElectronic", 0)
    And match each $.poLines[*].paymentStatus == karate.get("paymentStatus", "Pending")
    And match each $.poLines[*].receiptStatus == karate.get("receiptStatus", "Pending")
    And match each $.poLines[*].checkinItems == karate.get("checkinItems", false)