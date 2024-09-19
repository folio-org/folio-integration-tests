@ignore
Feature: Validate order line encumbrance links
  # parameters: encumbrances, orderLines

  Background: validateOrderLineEncumbranceLinks
    * url baseUrl
    * def getEncumbranceIdByPoLineId =
      """
      function (poLineId) {
        for (var i = 0; i < encumbrances.length; i++) {
          if (encumbrances[i].encumbrance.sourcePoLineId == poLineId) return encumbrances[i].id
        }
        return null
      }
      """

  Scenario: Validate order line encumbrance links
    Given path 'orders/order-lines', id
    When method GET
    Then status 200
    * def encumbranceId = getEncumbranceIdByPoLineId(id)
    * print "Printing encumbrance id: ", encumbranceId, ", for poLineId: ", id
    And match each $.fundDistribution[*].encumbrance == encumbranceId