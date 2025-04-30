Feature: unlink title from package. DELETE Title

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * call loginRegularUser dummyUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure retry = { count: 10, interval: 5000 }
    * configure headers = headersAdmin

    * callonce variables
    * def fundId = callonce uuid
    * def budgetId = callonce uuid1

    ### Before All ###
    # 1. Prepare finance data
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }

    * configure headers = headersUser

    @Negative
    Scenario: Delete title when PO Line is not found
      * def orderId = call uuid
      * def poLineId = call uuid
      * def titleId = call uuid
      * def pieceId1 = call uuid
      * def pieceId2 = call uuid
      * def pieceId3 = call uuid

      # 1. Prepare acquisitions data
      * def v = call createOrder { id: '#(orderId)' }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
      * def v = call openOrder { orderId: '#(orderId)' }
      * def v = call createTitle { titleId: '#(titleId)', poLineId: '#(poLineId)' }

      # 2. Delete the PO Line
      Given path 'orders/order-lines', poLineId
      When method DELETE
      Then status 204

      # 3. Attempt to delete the title
      Given path 'orders/titles', titleId
      When method DELETE
      Then status 404

    @Positive
    Scenario: Delete the title when holdings are not attached to any other existing titles.
      * def orderId = call uuid
      * def poLineId = call uuid
      * def titleId = call uuid
      * def pieceId1 = call uuid
      * def pieceId2 = call uuid
      * def pieceId3 = call uuid
      * def instanceId1 = call uuid
      * def instanceId2 = call uuid
      * def instanceTitle1 = "Instance 1" + instanceId1

      # 1. Create instances using table and createInstance method
      * table instances
        | id          | title       | instanceTypeId       |
        | instanceId1 | instanceId1 | globalInstanceTypeId |
      * def v = call createInstance instances

      # 2. Prepare acquisitions data
      * def v = call createOrder { id: '#(orderId)' }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
      * def v = call openOrder { orderId: '#(orderId)' }
      * def v = call createTitleForInstance { id: '#(titleId)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId)' }

      # 3. Delete the title
      Given path 'orders/titles', titleId
      When method DELETE
      Then status 204

  @Negative
  Scenario: Verify deleteHolding confirmation error when deleteHoldings is not exists and there are holdings are not attached to any other existing titles
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def instanceId1 = call uuid
    * def instanceId2 = call uuid
    * def instanceTitle1 = "Instance 1" + instanceId1

    # 1. Create instances using table and createInstance method
    * table instances
      | id          | title       | instanceTypeId       |
      | instanceId1 | instanceId1 | globalInstanceTypeId |
    * def v = call createInstance instances

    # 2. Prepare data
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }
    * def v = call createTitleForInstance { id: '#(titleId)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId)' }

    # 3. Create a piece with item
    Given path 'orders/pieces'
    And param createItem = true
    And request
      """
      {
        id: "#(pieceId1)",
        format: "Physical",
        locationId: "#(globalLocationsId)",
        poLineId: "#(poLineId)",
        titleId: "#(titleId)"
      }
      """
    When method POST
    Then status 201
    * def pieceItemId = $.itemId

    # 4. Check holding and item existence
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def holdingId = $.holdingsRecords[0].id

    Given path 'inventory/items', pieceItemId
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingId
    * configure headers = headersUser

    # 5. Verify existing holding confirmation error
    Given path 'orders/titles', titleId
    When method DELETE
    Then status 400
    And match $.errors[0].code == "existingHoldingsForDeleteConfirmation"
    And match $.errors[0].parameters[0].value contains holdingId


  @Positive
  Scenario: Verify holdings remain when unlinking title with deleteHoldings=false flag
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def instanceId1 = call uuid
    * def instanceId2 = call uuid
    * def instanceTitle1 = "Instance 1" + instanceId1
    * def instanceTitle2 = "Instance 2" + instanceId2

    # 1. Create instances using table and createInstance method
    * table instances
      | id          | title       | instanceTypeId       |
      | instanceId1 | instanceId1 | globalInstanceTypeId |
    * def v = call createInstance instances

    # 2. Prepare data
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }
    * def v = call createTitleForInstance { id: '#(titleId)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId)' }

    # 3. Create a piece with item
    Given path 'orders/pieces'
    And param createItem = true
    And request
      """
      {
        id: "#(pieceId1)",
        format: "Physical",
        locationId: "#(globalLocationsId)",
        poLineId: "#(poLineId)",
        titleId: "#(titleId)"
      }
      """
    When method POST
    Then status 201
    * def pieceItemId = $.itemId


    # 4. Check holding and item existence
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def holdingId = $.holdingsRecords[0].id

    Given path 'inventory/items', pieceItemId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingId
    * configure headers = headersUser


    # 5. Unlink title (Delete title)
    Given path 'orders/titles', titleId
    And param deleteHoldings = false
    When method DELETE
    Then status 204


    # 6. Verify holding existence and deletion of piece and item
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def holdingId = $.holdingsRecords[0].id

    Given path 'inventory/items', pieceItemId
    * configure headers = headersAdmin
    When method GET
    Then status 404
    * configure headers = headersUser

    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 404


  @Positive
  Scenario: Verify delete holdings, items and pieces when unlinking title and deleteHoldings=true flag
    * def orderId = call uuid
    * def orderId2 = call uuid
    * def poLineId = call uuid
    * def poLineId2 = call uuid
    * def titleId = call uuid
    * def titleId2 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def instanceId1 = call uuid
    * def instanceId2 = call uuid
    * def instanceTitle1 = "Instance 1" + instanceId1

    # 1. Create instances using table and createInstance method
    * table instances
      | id          | title       | instanceTypeId       |
      | instanceId1 | instanceId1 | globalInstanceTypeId |
    * def v = call createInstance instances

    # 2. Prepare data
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }
    * def v = call createTitleForInstance { id: '#(titleId)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId)' }

    # 3. Create a piece with item
    Given path 'orders/pieces'
    And param createItem = true
    And request
      """
      {
        id: "#(pieceId1)",
        format: "Physical",
        locationId: "#(globalLocationsId)",
        poLineId: "#(poLineId)",
        titleId: "#(titleId)"
      }
      """
    When method POST
    Then status 201
    * def pieceItemId = $.itemId


    # 4. Check holding and item existence
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def holdingId = $.holdingsRecords[0].id

    Given path 'inventory/items', pieceItemId
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingId
    * configure headers = headersUser


    # 5. Unlink title (Delete title)
    Given path 'orders/titles', titleId
    And param deleteHoldings = true
    When method DELETE
    Then status 204


    # 6. Verify holding, item and piece deletion
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'inventory/items', pieceItemId
    When method GET
    Then status 404
    * configure headers = headersUser

    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 404


  @Positive
  Scenario: Verify skip deletion of holdings which is associated with other poLines, even if deleteHoldings=true
    * def orderId = call uuid
    * def orderId2 = call uuid
    * def poLineId = call uuid
    * def poLineId2 = call uuid
    * def titleId = call uuid
    * def titleId2 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def instanceId1 = call uuid
    * def instanceId2 = call uuid
    * def instanceTitle1 = "Instance 1" + instanceId1
    * def instanceTitle2 = "Instance 2" + instanceId2

    # 1. Create instances using table and createInstance method
    * table instances
      | id          | title       | instanceTypeId       |
      | instanceId1 | instanceId1 | globalInstanceTypeId |
      | instanceId2 | instanceId2 | globalInstanceTypeId |
    * def v = call createInstance instances

    # 2. Prepare data for first order
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }
    * def v = call createTitleForInstance { id: '#(titleId)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId)' }

    # 3. Create a piece with item for first order
    Given path 'orders/pieces'
    And param createItem = true
    And request
      """
      {
        id: "#(pieceId1)",
        format: "Physical",
        locationId: "#(globalLocationsId)",
        poLineId: "#(poLineId)",
        titleId: "#(titleId)"
      }
      """
    When method POST
    Then status 201
    * def pieceItemId1 = $.itemId

    # 4. Check holding existence
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def holdingId1 = $.holdingsRecords[0].id
    * configure headers = headersUser


    # 5. Prepare acquisitions data for second order
    * def v = call createOrder { id: '#(orderId2)' }
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId2)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId2)' }
    * def v = call createTitleForInstance { id: '#(titleId2)', instanceId: '#(instanceId1)', title: '#(instanceTitle1)', poLineId: '#(poLineId2)' }

    # 6. Create a piece with item for second order
    Given path 'orders/pieces'
    And param createItem = true
    And request
      """
      {
        id: "#(pieceId2)",
        format: "Physical",
        locationId: "#(globalLocationsId)",
        poLineId: "#(poLineId2)",
        titleId: "#(titleId2)"
      }
      """
    When method POST
    Then status 201
    * def pieceItemId2 = $.itemId


    # 7. Move to first holding to make holding to used by two poLines
    * def v = call moveItem { holdingId: '#(holdingId1)', itemId: '#(pieceItemId2)' }


    # 8. Check holding and item existence
    * configure headers = headersAdmin
    Given path 'inventory/items', pieceItemId1
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingId1

    Given path 'inventory/items', pieceItemId2
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingId1
    * configure headers = headersUser


    # 9. Delete Title and holdings
    Given path 'orders/titles', titleId
    And param deleteHoldings = true
    When method DELETE
    Then status 204


    # 10.1 Verify that holding associated with other title is not deleted
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', holdingId1
    When method GET
    Then status 200

    # 10.2 Verify that item belong to poLineId1 and unlinking title is deleted
    Given path 'inventory/items', pieceItemId1
    When method GET
    Then status 404

    # 10.3 Verify that item belong to poLineId2 is not deleted
    Given path 'inventory/items', pieceItemId2
    When method GET
    Then status 200
    * configure headers = headersUser

    # 10.4 Verify that piece belong to poLineId1 and unlinking title is deleted
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 404

    # 10.5 Verify that piece belong to poLineId2 is not deleted
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
