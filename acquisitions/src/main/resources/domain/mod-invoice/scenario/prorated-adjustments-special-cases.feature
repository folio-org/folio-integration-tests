Feature: Verify that request will be rejected if provided adjustments no valid

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * def invoiceId = callonce uuid
    * def invoiceLineId = callonce uuid
    * def poNumber = '10000000'

  Scenario: Create invoice wit prorated adjustment
    Given path 'invoice/invoices'
    And request
    """
    {
      id: '#(invoiceId)',
      "adjustments": [
        {
          "description": "Shipping",
          "exportToAccounting" : false,
          "type": "Amount",
          "value": 4.50,
          "prorate": "By line",
          "relationToTotal": "In addition to"
        }
      ],
      "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
      "currency": "USD",
      "invoiceDate": "2018-07-20T00:00:00.000+0000",
      "paymentMethod": "EFT",
      "status": "Reviewed",
      "source": "User",
      "vendorInvoiceNo": "YK75851",

      "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b"
    }
    """
    When method POST
    Then status 201

  Scenario: Create invoice line with non-existent adjustmentId and duplicated adjustmentId
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLineId)',
      "adjustments": [
        {
          "adjustmentId": "14263aab-b22b-4ddc-9ecc-3434427c2c8f",
          "exportToAccounting" : false,
          "description":"Shipping",
          "type":"Amount",
          "value":2.50,
          "prorate":"By line",
          "relationToTotal":"In addition to"
        },
        {
          "adjustmentId": "14263aab-b22b-4ddc-9ecc-3434427c2c8f",
          "exportToAccounting" : false,
          "description":"Shipping",
          "type":"Amount",
          "value":2.50,
          "prorate":"By line",
          "relationToTotal":"In addition to"
        }
      ],
      "description": "Some description",
      "fundDistributions": [
        {
          "code": "USHIST",
          "encumbrance": "1c8fc9f4-d2cc-4bd1-aa9a-cb02291cbe65",
          "fundId": "1d1574f1-9196-4a57-8d1f-3b2e4309eb81",
          "distributionType": "percentage",
          "value": 100
        }
      ],
      "invoiceId": '#(invoiceId)',
      "invoiceLineStatus": "Open",
      "quantity": 3,
      "releaseEncumbrance": false,
      "subTotal": 25.00
    }
    """
    When method POST
    Then status 422
    And match $.errors[0].code == 'adjustmentIdsNotUnique'
    And match $.errors[1].code == 'cannotAddAdjustment'

  Scenario: Create valid invoice line
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLineId)',
      "description": "Some description",
      "fundDistributions": [
        {
          "code": "USHIST",
          "encumbrance": "1c8fc9f4-d2cc-4bd1-aa9a-cb02291cbe65",
          "fundId": "1d1574f1-9196-4a57-8d1f-3b2e4309eb81",
          "distributionType": "percentage",
          "value": 100
        }
      ],
      "invoiceId": '#(invoiceId)',
      "invoiceLineStatus": "Open",
      "quantity": 3,
      "releaseEncumbrance": false,
      "subTotal": 25.00
    }
    """
    When method POST
    Then status 201

  Scenario: Update invoice line to delete existing adjustmentId
    Given path 'invoice/invoice-lines', invoiceLineId
    And request
    """
    {
      "id": '#(invoiceLineId)',
      "description": "Some description",
      "fundDistributions": [
        {
          "code": "USHIST",
          "encumbrance": "1c8fc9f4-d2cc-4bd1-aa9a-cb02291cbe65",
          "fundId": "1d1574f1-9196-4a57-8d1f-3b2e4309eb81",
          "distributionType": "percentage",
          "value": 100
        }
      ],
      "invoiceId": '#(invoiceId)',
      "invoiceLineStatus": "Open",
      "quantity": 3,
      "releaseEncumbrance": false,
      "subTotal": 25.00
    }
    """
    When method PUT
    Then status 422
    And match $.errors[0].code == 'cannotDeleteAdjustment'

  Scenario: delete invoice line
    Given path 'invoice/invoice-lines', invoiceLineId
    When method DELETE
    Then status 204

  Scenario: delete invoice
    Given path 'invoice/invoices', invoiceId
    When method DELETE
    Then status 204

