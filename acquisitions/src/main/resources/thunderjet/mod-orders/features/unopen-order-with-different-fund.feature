# For MODORDERS-626, MODORDERS-894, MODORDERS-1222
Feature: Unopen order and change fund distribution

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

    * callonce variables

    @Positive
    Scenario: Unopen order and add fund distribution with another expense class
      # 1. Prepare finance data [create budget with two expense classes (PRN and Elec)]
      * def fundId = call uuid
      * def budgetId = call uuid
      * def statusExpenseClasses = [{ 'expenseClassId': '#(globalPrnExpenseClassId)', 'status': 'Active' }, { 'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Active' }]

      * configure headers = headersAdmin
      * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerId)' }
      * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000, statusExpenseClasses: '#(statusExpenseClasses)' }

      # 2. Create order and order line
      * configure headers = headersUser
      * def orderId = call uuid
      * def poLineId = call uuid

      * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'Ongoing', ongoing: { interval: 123, isSubscription: true, renewalDate: '2023-05-08T00:00:00.000+00:00' } }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', expenseClassId: '#(globalElecExpenseClassId)', value: 100.0 }

      # 3. Open and unopen the order
      * def v = call openOrder { orderId: '#(orderId)' }
      * def v = call unopenOrder { orderId: '#(orderId)' }

      # 4. Add fund distribution with the same fund and another expense class
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200

      * def poLine = $
      * set poLine.fundDistribution[0].value = 50.0
      * set poLine.fundDistribution[1] =
        """
        {
          "fundId" : "#(fundId)",
          "distributionType" : "percentage",
          "expenseClassId" : "#(globalPrnExpenseClassId)",
          "value" : 50.0
        }
        """

      Given path 'orders/order-lines', poLineId
      And request poLine
      When method PUT
      Then status 204

      # 5. Reopen the order
      * def v = call openOrder { orderId: '#(orderId)' }


    @Positive
    Scenario: Unopen order and change fund distribution expense class
      # 1. Prepare finance data [create budget with expense classes (Elec)]
      * def fundId = call uuid
      * def budgetId = call uuid
      * def statusExpenseClasses = [{ 'expenseClassId': '#(globalPrnExpenseClassId)', 'status': 'Active' }]

      * configure headers = headersAdmin
      * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerId)' }
      * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000, statusExpenseClasses: '#(statusExpenseClasses)' }

      # 2. Create order and order line
      * configure headers = headersUser
      * def orderId = call uuid
      * def poLineId = call uuid
      * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

      # 3. Open and unopen the order
      * def v = call openOrder { orderId: '#(orderId)' }
      * def v = call unopenOrder { orderId: '#(orderId)' }

      # 4. Retrieve and update the order line with new expense class
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200

      * def poLine = $
      * set poLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

      Given path 'orders/order-lines', poLineId
      And request poLine
      When method PUT
      Then status 204

      # 5. Reopen the order
      * def v = call openOrder { orderId: '#(orderId)' }


  @Positive
  Scenario: UnOpen order with '25' order line with '3' fund distributions and encumbrances to check their status to verify process transactions completion
    # 1. Prepare finance data [create budget with three expense classes (PRN, Elec, and Misc)]
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def fundId3 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def budgetId3 = call uuid

    * table statusExpenseClasses
      | expenseClassId           | status   |
      | globalPrnExpenseClassId  | 'Active' |
      | globalElecExpenseClassId | 'Active' |

    * configure headers = headersAdmin
    * table fundTable
      | id      | ledgerId       |
      | fundId1 | globalLedgerId |
      | fundId2 | globalLedgerId |
      | fundId3 | globalLedgerId |
    * def v = call createFund fundTable
    * table budgetTable
      | id        | fundId  | allocated | statusExpenseClasses |
      | budgetId1 | fundId1 | 1000      | statusExpenseClasses |
      | budgetId2 | fundId2 | 1000      | statusExpenseClasses |
      | budgetId3 | fundId3 | 1000      | statusExpenseClasses |
    * def v = call createBudget budgetTable

    # 2. Create order and 15 order line with 3 fund distributions
    * configure headers = headersUser
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }

    * table fundDistributionTable
      | fundId  | code    | expenseClassId           | value |
      | fundId1 | 'fund1' | globalPrnExpenseClassId  | 30    |
      | fundId2 | 'fund2' | globalElecExpenseClassId | 30    |
      | fundId3 | 'fund3' | globalElecExpenseClassId | 40    |
    * def orderLineId = call uuid
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundDistribution: '#(fundDistributionTable)' }

    * def poLineParameters = []
    * def poLineParametersArray =
      """
      function() {
        for (let i = 0; i < 15; i++) {
          poLineParameters.push({
            id: uuid(),
            purchaseOrderId: orderId,
            fundId: fundId1
          })
        }
      }
      """
    * eval poLineParametersArray()
    * def v = call createOrderLine poLineParameters

    # 3. Open and unopen the order and check encumbrance transactions status
    * def v = call openOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Unreleased', _orderStatus: 'Open' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus

    # 4. Unopen the order and check encumbrance transactions status
    * configure headers = headersUser
    * def v = call unopenOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Pending', _orderStatus: 'Pending' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus

    # 5. Reopen the order and check encumbrance transactions status
    * configure headers = headersUser
    * def v = call openOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Unreleased', _orderStatus: 'Open' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus


  @Positive
  Scenario: UnOpen order with order line with '25' fund distributions and encumbrances to check their status to verify process transactions completion
    This scenario created specifically for MODORDERS-1222 to avoid duplication poLines

    # 1. Prepare finance data [create budget with three expense classes (PRN, Elec, and Misc)]
    * def fundIds = []
    * def budgetIds = []
    * table statusExpenseClasses
      | expenseClassId           | status   |
      | globalPrnExpenseClassId  | 'Active' |
      | globalElecExpenseClassId | 'Active' |

    * configure headers = headersAdmin
    * def fundsTable = []
    * def createFundsTable =
      """
      function() {
        for (let i = 0; i < 25; i++) {
          var fundId = uuid();
          fundIds.push(fundId);
          fundsTable.push({ id: fundId, ledgerId: globalLedgerId });
        }
      }
      """
    * eval createFundsTable()
    * def v = call createFund fundsTable

    * def budgetsTable = []
    * def createBudgetsTable =
      """
      function() {
        for (let i = 0; i < 25; i++) {
          var budgetId = uuid();
          budgetIds.push(budgetId);
          budgetsTable.push({ id: budgetId, fundId: fundIds[i], allocated: 1000, statusExpenseClasses: statusExpenseClasses });
        }
      }
      """
    * eval createBudgetsTable()
    * def v = call createBudget budgetsTable

    # 2. Create order and one order line with 25 fund distributions
    * configure headers = headersUser
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }

    * def fundDistributionTable = []
    * def createFundDistributionTable =
      """
      function() {
        for (let i = 0; i < 25; i++) {
          fundDistributionTable.push({
            fundId: fundIds[i],
            code: 'fund' + (i + 1),
            expenseClassId: globalPrnExpenseClassId,
            value: 4
          });
        }
      }
      """
    * eval createFundDistributionTable()

    * def orderLineId = call uuid
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundDistribution: '#(fundDistributionTable)' }

    # 3. Open and unopen the order and check encumbrance transactions status
    * def v = call openOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Unreleased', _orderStatus: 'Open' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus

    # 4. Unopen the order and check encumbrance transactions status
    * configure headers = headersUser
    * def v = call unopenOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Pending', _orderStatus: 'Pending' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus

    # 5. Reopen the order and check encumbrance transactions status
    * configure headers = headersUser
    * def v = call openOrder { orderId: '#(orderId)' }
    * def expectedEncumbranceStatus = { _orderId: '#(orderId)', _encumbranceStatus: 'Unreleased', _orderStatus: 'Open' }
    * configure headers = headersAdmin
    * def v = call verifyEncumbranceStatus expectedEncumbranceStatus
