# For MODORDERS-573, MODORDERS-557, MODORDERS-1369
Feature: Check opening an order links to the right instance based on the identifier type and value but only if instance matching is not disabled

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * configure retry = { interval: 10000, count: 10 }

    * callonce variables
    * def isbn1 = "9780552142359"
    * def isbn2 = "9781580469968"

    * def fundId = call uuid
    * def budgetId = call uuid
    * def instanceId1 = call uuid
    * def instanceId2 = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderId3 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def settingId = call uuid

    # Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

  @Positive
  Scenario: Verify Instance Matching Behavior With Enabled And Disabled Settings
    # Create Two Instances With Different ISBN Patterns
    * table identifiers1
      | value | identifierTypeId           |
      | isbn1 | globalISBNIdentifierTypeId |
      | isbn2 | globalIdentifierTypeId     |
    * def v = call createInstance { 'id': '#(instanceId1)', 'title': 'Interesting Times', 'instanceTypeId': '#(globalInstanceTypeId)', 'identifiers': '#(identifiers1)' }

    * table identifiers2
      | value | identifierTypeId           |
      | isbn2 | globalISBNIdentifierTypeId |
      | isbn1 | globalIdentifierTypeId     |
    * def v = call createInstance { 'id': '#(instanceId2)', 'title': 'Music, Liturgy, and Confraternity Devotions in Paris and Tournai, 1300-1550', 'instanceTypeId': '#(globalInstanceTypeId)', 'identifiers': '#(identifiers2)' }

    # Create Order With Line And Verify Instance Matching (Enabled By Default)
    * def v = call createOrder { 'id': '#(orderId1)' }
    * table productIds1
      | productId | productIdType              |
      | isbn2     | globalISBNIdentifierTypeId |
    * def v = call createOrderLine { 'id': '#(poLineId1)', 'orderId': '#(orderId1)', 'fundId': '#(fundId)', 'productIds': '#(productIds1)' }
    * def v = call openOrder { 'orderId': '#(orderId1)' }

    # Verify Instance Matching To InstanceId2
    Given path 'orders/order-lines', poLineId1
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

    # Disable Instance Matching
    * configure headers = headersAdmin
    Given path 'orders-storage/settings'
    And request { "id": "#(settingId)", "key": "disableInstanceMatching", "value": "{\"isInstanceMatchingDisabled\":true}" }
    When method POST
    Then status 201
    * def v = call pause 65000
    * configure headers = headersUser

    # Create Second Order With Disabled Instance Matching
    * def v = call createOrder { 'id': '#(orderId2)' }
    * table productIds2
      | productId | productIdType              |
      | isbn2     | globalISBNIdentifierTypeId |
    * def v = call createOrderLine { 'id': '#(poLineId2)', 'orderId': '#(orderId2)', 'fundId': '#(fundId)', 'productIds': '#(productIds2)' }
    * def v = call openOrder { 'orderId': '#(orderId2)' }

    # Verify New Instance Created (Not Matching Existing)
    * def v = call pause 10000
    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    And match $.instanceId != instanceId1
    And match $.instanceId != instanceId2

    # Re-Enable Instance Matching
    * configure headers = headersAdmin
    Given path 'orders-storage/settings'
    And param query = 'key==disableInstanceMatching'
    When method GET
    Then status 200
    * def setting = $.settings[0]
    * set setting.value = "{\"isInstanceMatchingDisabled\":false}"
    * def settingIdFound = $.settings[0].id

    Given path 'orders-storage/settings', settingIdFound
    And request setting
    When method PUT
    Then status 204
    * def v = call pause 65000
    * configure headers = headersUser

    # Create Third Order And Verify Instance Matching Re-Enabled
    * def v = call createOrder { 'id': '#(orderId3)' }
    * table productIds3
      | productId | productIdType              |
      | isbn2     | globalISBNIdentifierTypeId |
    * def v = call createOrderLine { 'id': '#(poLineId3)', 'orderId': '#(orderId3)', 'fundId': '#(fundId)', 'productIds': '#(productIds3)' }
    * def v = call openOrder { 'orderId': '#(orderId3)' }

    # Verify Instance Matching To InstanceId2 Again
    Given path 'orders/order-lines', poLineId3
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

  @Positive
  Scenario: Verify Instance Matching Skips Deleted Instances And Creates New Instance
    * def orderId4 = call uuid
    * def poLineId4 = call uuid

    # Create First Order With POL - Let System Create Instance
    * def v = call createOrder { 'id': '#(orderId1)' }
    * table productIds
      | productId | productIdType              |
      | isbn1     | globalISBNIdentifierTypeId |
    * def v = call createOrderLine { 'id': '#(poLineId1)', 'orderId': '#(orderId1)', 'fundId': '#(fundId)', 'productIds': '#(productIds)' }
    * def v = call openOrder { 'orderId': '#(orderId1)' }

    # Get Instance ID Created By System
    Given path 'orders/order-lines', poLineId1
    And retry until response.instanceId != null
    When method GET
    Then status 200
    * def initialInstanceId = response.instanceId

    # Create Second Order With POL That Should Also Match Initial Instance
    * def v = call createOrder { 'id': '#(orderId2)' }
    * def v = call createOrderLine { 'id': '#(poLineId2)', 'orderId': '#(orderId2)', 'fundId': '#(fundId)', 'productIds': '#(productIds)' }
    * def v = call openOrder { 'orderId': '#(orderId2)' }

    # Verify Same Instance Matching
    Given path 'orders/order-lines', poLineId2
    And retry until response.instanceId == initialInstanceId
    When method GET
    Then status 200

    # Mark Initial Instance As Deleted
    * configure headers = headersAdmin
    Given path 'inventory/instances', initialInstanceId
    When method GET
    Then status 200
    * def instance = $
    * set instance.deleted = true
    * set instance.staffSuppress = true
    * set instance.discoverySuppress = true

    Given path 'inventory/instances', initialInstanceId
    And request instance
    When method PUT
    Then status 204
    * configure headers = headersUser

    # Create Third Order With POL That Should Match Different Instance (Not Deleted One)
    * def v = call createOrder { 'id': '#(orderId3)' }
    * def v = call createOrderLine { 'id': '#(poLineId3)', 'orderId': '#(orderId3)', 'fundId': '#(fundId)', 'productIds': '#(productIds)' }
    * def v = call openOrder { 'orderId': '#(orderId3)' }

    # Verify New Instance Created
    Given path 'orders/order-lines', poLineId3
    And retry until response.instanceId != null && response.instanceId != initialInstanceId
    When method GET
    Then status 200
    * def newInstanceId = response.instanceId

    # Create Fourth Order With POL That Should Match The Same New Instance
    * def v = call createOrder { 'id': '#(orderId4)' }
    * def v = call createOrderLine { 'id': '#(poLineId4)', 'orderId': '#(orderId4)', 'fundId': '#(fundId)', 'productIds': '#(productIds)' }
    * def v = call openOrder { 'orderId': '#(orderId4)' }

    # Verify It Matches The Same New Instance
    Given path 'orders/order-lines', poLineId4
    And retry until response.instanceId == newInstanceId
    When method GET
    Then status 200

