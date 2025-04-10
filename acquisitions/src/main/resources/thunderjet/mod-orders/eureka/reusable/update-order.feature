@ignore
Feature: Update order
  # parameters: id, vendor?, orderType?, ongoing?, reEncumber?, acqUnitIds?, workflowStatus?

  Background:
    * url baseUrl

  Scenario: createOrder
    Given path 'orders/composite-orders', id
    When method GET
    Then status 200

    * def order = $
    * set order.vendor = karate.get('vendor', order.vendor)
    * set order.orderType = karate.get('orderType', order.orderType)
    * set order.ongoing = karate.get('ongoing', order.ongoing)
    * set order.reEncumber = karate.get('reEncumber', order.reEncumber)
    * set order.acqUnitIds = karate.get('acqUnitIds', order.acqUnitIds)
    * set order.workflowStatus = karate.get('workflowStatus', order.workflowStatus)
    * remove order.compositePoLines

    Given path 'orders/composite-orders', id
    And request order
    When method PUT
    Then status 204
