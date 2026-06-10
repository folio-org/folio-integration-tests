# For MODORDERS-890, MODORDERS-1265, https://foliotest.testrail.io/index.php?/cases/view/398006
# Regression: changing a POL's instance connection to an instance carrying an ISBN identifier in
# "ISBN Qualifier" format must not produce an invalid productId that blocks invoice approve & pay.
Feature: Change POL Instance Connection To ISBN-Qualifier Instance Then Approve And Pay Invoice

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
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @C398006
  @Positive
  Scenario: Change POL Instance Connection To ISBN-Qualifier Instance And Approve-And-Pay Invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def initialInstanceId = call uuid
    * def isbnQualifierInstanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # Resource Identifier In "ISBN Qualifier" Format Taken From TestRail Preconditions #3
    * def isbnQualifierValue = '0914378260 paperbound'

    # 1. Create Fund And Budget
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2-3. Create Initial And Target ISBN-Qualifier Instances (TestRail Preconditions #1, #3)
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(initialInstanceId)', title: 'C398006 Initial Instance', instanceTypeId: '#(globalInstanceTypeId)' }
    * def v = call createInstance { id: '#(isbnQualifierInstanceId)', title: 'C398006 ISBN Qualifier Instance', instanceTypeId: '#(globalInstanceTypeId)', identifiers: [{ value: '#(isbnQualifierValue)', identifierTypeId: '#(globalISBNIdentifierTypeId)' }] }
    * configure headers = headersUser

    # 4. Create Ongoing Order With A Single POL Bound To The Initial Instance, Then Open It (TestRail Preconditions #4-5)
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { interval: 30, isSubscription: false, renewalDate: '2030-01-01T00:00:00.000+00:00' } }
    * def v = call createOrderLineWithInstance { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', instanceId: '#(initialInstanceId)', titleOrPackage: 'C398006 Initial Instance' }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Verify POL Initially Points To The Initial Instance With No Product IDs (TestRail Steps 1-2)
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == initialInstanceId
    And match response.details.productIds == '#[0]'

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Change POL Instance Connection To ISBN-Qualifier Instance — "Find Or Create" + Keep Abandoned Holdings (TestRail Steps 3-7)
    * table instanceChangeData
      | poLineId | instanceId              | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | isbnQualifierInstanceId | 'Find or Create'  | false                   |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 7. Verify New Instance Is Linked, productId Carries The Full ISBN+Qualifier String, And The Qualifier Field Is NOT Split Out (TestRail Step 8 — MODORDERS-1265)
    * def isPoLineLinkedWithQualifier =
    """
    function(response) {
      return response.instanceId == isbnQualifierInstanceId &&
             response.details && response.details.productIds &&
             response.details.productIds.length > 0 &&
             response.details.productIds[0].productId == isbnQualifierValue &&
             response.details.productIds[0].productIdType == globalISBNIdentifierTypeId &&
             response.details.productIds[0].qualifier == null;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineLinkedWithQualifier(response)
    When method GET
    Then status 200

    # 8. Create Invoice And Invoice Line Linked To The POL (TestRail Steps 10-12)
    * def v = call createInvoice { id: '#(invoiceId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', poLineId: '#(poLineId)', total: 10 }

    # 9. "Approve & Pay In One Click" — API Equivalent Is Approve Followed By Pay (TestRail Step 13).
    # Regression Assertion For MODORDERS-890: Approval Must NOT Fail With An Invalid-ISBN Validation Error.
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 10. Verify Invoice Status Is Paid (TestRail Step 13 Final Outcome)
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Paid'
    When method GET
    Then status 200
