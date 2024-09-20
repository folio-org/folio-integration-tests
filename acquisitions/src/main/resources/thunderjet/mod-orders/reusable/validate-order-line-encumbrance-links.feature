@ignore
Feature: Validate order line encumbrance links
  # parameters: encumbrances (global scope), orderLines

  # Feature description:
  # For every order line record in the orderLines table a request to /orders/order-lines/{id}
  # is made to retrieve the POL record. After the POL record is retrieved, the incoming poLineId
  # is compared with the sourcePoLineId from the encumbrances array. If the sourcePoLineId is found
  # in the encumbrances array, the encumbrance id is extracted & compared with the encumbrance id on
  # POL fundDistribution. If the id matches the test passes, if the match contains a null the test fails.

  Background: validateOrderLineEncumbranceLinks
    * url baseUrl
    * def getEncumbranceIdByPoLineId =
      """
      function (poLineId) {
        for (var i = 0; i < encumbrances.length; i++) {
          if (encumbrances[i].encumbrance.sourcePoLineId == poLineId) {
            return encumbrances[i].id
          }
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