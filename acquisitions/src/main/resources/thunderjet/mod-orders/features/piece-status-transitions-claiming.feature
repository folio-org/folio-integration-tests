# For MODORDSTOR-354
@parallel=false
Feature: Piece status transitions claiming

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def previousDate = '2024-01-23T12:50:03.156+00:00'

    # Create Finances
    * configure headers = headersAdmin
    * def v = callonce createFund { 'id': '#(fundId)' }
    * def v = callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser


  # ============================================================
  # C436738: Piece status has not been changed if "Expected receipt date" wasn't specified
  # https://foliotest.testrail.io/index.php?/cases/view/436738
  # ============================================================
  @C436738
  @Positive
  Scenario: Verify Piece Status Not Changed Without Expected Receipt Date
    * def orderId = call uuid
    * def poLineId = call uuid

    # Precondition 1: Create Ongoing Order In Open Status With Claiming Active
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # Precondition 2: Run Pieces Claiming Batch Job
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # Step 1: Check Piece In Expected Accordion - Piece Should Be In Expected Status
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.pieces[0].receivingStatus == 'Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receiptDate == '#notpresent'

    # Step 2: Verify PO Line Receipt Status Is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # Step 3-4: Verify Item Status Is On Order
    * def poLine = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = poLine.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'
