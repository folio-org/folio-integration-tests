@ignored
Feature: Cancel an invoice check encumbrance
  # parameters: paymentStatusTable

  Background: cancelInvoiceCheckEncumbrance
    * url baseUrl

  Scenario: Cancel an invoice check encumbrance
    * def fundId = globalFundId
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def paymentStatus = __arg.paymentStatus
    * def encumbranceId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def isbn = "9780552142359"

    * print "1. Create instances"
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(instanceId)",
        "source": "FOLIO",
        "title": "Interesting Times",
        "instanceTypeId": "#(globalInstanceTypeId)",
        "identifiers": [
          {
            "value": "#(isbn)",
            "identifierTypeId": "#(globalISBNIdentifierTypeId)"
          }
        ]
      }
      """
    When method POST
    Then status 201

    * print '2. Create composite order'
    * def order =
      """
      {
        "id": "#(orderId)",
        "tags": {
          "tagList": [
            "amazon"
          ]
        },
        "notes": [
          "Check credit card statement to make sure payment shows up"
        ],
        "billTo": "5f8a321e-6b38-4d90-92d4-bf08f91a2242",
        "shipTo": "f7c36792-05f7-4c8c-969d-103ac6763187",
        "vendor": "#(globalVendorId)",
        "approved": true,
        "manualPo": false,
        "poNumber": "10000",
        "template": "4dee318b-f5b3-40dc-be93-cc89b8c45b6f",
        "orderType": "One-Time",
        "acqUnitIds": [],
        "reEncumber": false,
        "nextPolNumber": 2,
        "workflowStatus": "Pending"
      }
      """
    * remove order.poNumber
    * remove order.billTo
    * remove order.shipTo
    Given path 'orders/composite-orders'
    And request order
    When method POST
    Then status 201

    * print '3. Create order lines'
    * def poLine =
      """
      {
        "id": "#(poLineId)",
        "cost": {
          "currency": "USD",
          "discountType": "percentage",
          "listUnitPrice": 1.0,
          "quantityPhysical": 1,
          "poLineEstimatedPrice": 1.0
        },
        "rush": false,
        "alerts": [],
        "claims": [],
        "source": "User",
        "details": {
          "productIds": [ { productId: "#(isbn)", productIdType: "#(globalISBNIdentifierTypeId)" } ],
          "isAcknowledged": false,
          "isBinderyActive": false,
          "subscriptionInterval": 0
        },
        "physical": {
          "volumes": [],
          "materialType": "#(globalMaterialTypeIdPhys)",
          "createInventory": "Instance, Holding, Item",
          "materialSupplier": "#(globalVendorId)",
        },
        "isPackage": false,
        "locations": [
          {
            "quantity": 1,
            "locationId": "#(globalLocationsId)",
            "quantityPhysical": 1
          }
        ],
        "collection": false,
        "orderFormat": "Physical Resource",
        "checkinItems": false,
        "contributors": [],
        "poLineNumber": "10000-1",
        "vendorDetail": {
          "instructions": "",
          "vendorAccount": "1234",
          "referenceNumbers": []
        },
        "paymentStatus": "#(paymentStatus)",
        "receiptStatus": "Pending",
        "claimingActive": false,
        "reportingCodes": [],
        "titleOrPackage": "Test 1",
        "automaticExport": false,
        "purchaseOrderId": "#(orderId)",
        "claimingInterval": 45,
        "fundDistribution": [
          {
            "code": "#(globalFundCode)",
            "value": 100.0,
            "fundId": "#(globalFundId)",
            "distributionType": "percentage"
          }
        ],
        "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
        "searchLocationIds": [
          "fcd64ce1-6995-48f0-840e-89ffa2288371"
        ],
        "donorOrganizationIds": [],
        "cancellationRestriction": true
      }
      """
    * remove poLine.poLineNumber
    * remove poLine.searchLocationIds
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print '4. Open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove order.compositePoLines
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    * print '5. Retrieve budge info for later'
    Given path '/finance/budgets', globalBudgetId
    When method GET
    Then status 200
    * def budgetBefore = $

    * print "6. Create an invoice"
    * def invoice =
      """
      {
        "id": "#(invoiceId)",
        "total": 1.0,
        "source": "User",
        "status": "Open",
        "currency": "USD",
        "subTotal": 1.0,
        "vendorId": "#(globalVendorId)",
        "poNumbers": [
          "10000"
        ],
        "acqUnitIds": [],
        "adjustments": [],
        "invoiceDate": "2024-06-01T00:00:00.000+00:00",
        "batchGroupId": "#(globalBatchGroupId)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "paymentMethod": "Credit Card",
        "accountingCode": "G64758-74834",
        "folioInvoiceNo": "10001",
        "enclosureNeeded": false,
        "vendorInvoiceNo": "2",
        "adjustmentsTotal": 0.0,
        "exportToAccounting": true,
        "nextInvoiceLineNumber": 2,
        "chkSubscriptionOverlap": true
      }
      """
    * remove invoice.poNumbers
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

    * print "7. Add an invoice line"
    * def invoiceLine =
      """
      {
        "id": "#(invoiceLineId)",
        "total": 1.0,
        "poLineId": "#(poLineId)",
        "quantity": 1,
        "subTotal": 1.0,
        "invoiceId": "#(invoiceId)",
        "adjustments": [],
        "description": "Test 1",
        "accountNumber": "1234",
        "accountingCode": "G64758-74834",
        "adjustmentsTotal": 0.0,
        "referenceNumbers": [],
        "fundDistributions": [
          {
            "code": "#(globalFundCode)",
            "value": 100.0,
            "fundId": "#(globalFundId)",
            "distributionType": "percentage",
            "encumbrance": "#(encumbranceId)",
            "expenseClassId": "1bcc3247-99bf-4dca-9b0f-7bc51a2998c2",
          }
        ],
        "invoiceLineNumber": "1",
        "invoiceLineStatus": "Open",
        "releaseEncumbrance": true
      }
      """
    * remove invoiceLine.fundDistributions[*].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    * print "8. Approve the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * print "9. Pay the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * print "10. Cancel the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Cancelled'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * print "11. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance'
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Unreleased'
