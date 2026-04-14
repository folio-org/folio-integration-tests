Feature: Check error response with fundcode upon invoice approval

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


  Scenario Outline: Approve invoice with <invoiceAmount> amount and budget with <allocated> amount to get code <httpCode> & <fundCode>

    * def budgetId = call uuid
    * def fundId = call uuid
    * def fundCode = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # ============= Create fund and budget =============
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: '#(<allocated>)', netTransfers: 10 }

    # ============= Create invoices ===================
    * configure headers = headersUser
    Given path 'invoice/invoices'
    And request
    """
    {
        "id": "#(invoiceId)",
        "chkSubscriptionOverlap": true,
        "currency": "USD",
        "source": "User",
        "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
        "status": "Open",
        "invoiceDate": "2020-05-21",
        "vendorInvoiceNo": "test",
        "accountingCode": "G64758-74828",
        "paymentMethod": "Physical Check",
        "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b",
        "adjustments": [
            {
                "type": "Amount",
                "description": "first",
                "prorate": "Not prorated",
                "fundDistributions": [
                    {
                        "distributionType": "amount",
                        "fundId": "#(fundId)",
                        "value": 100
                    }
                ],
                "value": 100,
                "relationToTotal": "In addition to"
            }
        ]
    }
    """
    When method POST
    Then status 201

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
        "id": "#(invoiceLineId)",
        "invoiceId": "#(invoiceId)",
        "invoiceLineStatus": "Open",
        "fundDistributions": [
            {
                "distributionType": "percentage",
                "fundId": "#(fundId)",
                "value": 100
            }
        ],
        "subTotal": <invoiceAmount>,
        "description": "test",
        "quantity": "1"
    }
    """
    When method POST
    Then status 201


    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status <httpCode>
    * if (<httpCode> == 422) karate.match(<fundCode>, response.errors[0].value)

    Examples:
      | allocated | invoiceAmount | error              | httpCode | fundCode       |
      | 100       | 101           | 'fundCannotBePaid' | 422      |  'FC'          |
      | 10        | 20            | 'fundCannotBePaid' | 422      |  'TF131111'    |
