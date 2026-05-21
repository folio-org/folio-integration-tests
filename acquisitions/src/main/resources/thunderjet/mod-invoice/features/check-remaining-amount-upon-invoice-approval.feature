Feature: Check remaining amount upon invoice approval

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

  Scenario Outline: Approve invoice with <invoiceAmount> amount and budget with <allocated> and <netTransfers> amount to get <httpCode> code

    * def budgetId = call uuid
    * def fundId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # ============= Create fund and budget =============
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: '#(<allocated>)', netTransfers: '#(<netTransfers>)' }

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
                        "value": <invoiceAdjustmentAmount>
                    }
                ],
                "value": <invoiceAdjustmentAmount>,
                "relationToTotal": "In addition to"
            }
        ]
    }
    """
    When method POST
    Then status 201

    # ============= Create invoice line ===================
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: '#(<invoiceAmount>)' }

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
    * if (<httpCode> == 404) karate.match(<error>, response.errors[0].code)

    Examples:
      | allocated | invoiceAmount | netTransfers | invoiceAdjustmentAmount | error              | httpCode |
      | 100       | 90            | 0            | 10                      | null               | 204      |
      | 100       | 100           | 0            | 0                       | null               | 204      |
      | 55        | 51            | 1            | 0                       | null               | 204      |
      | 100       | 101           | 0            | 0                       | 'fundCannotBePaid' | 422      |
      | 50        | 50            | 0            | 1                       | 'fundCannotBePaid' | 422      |
      | 49        | 51            | 1            | 0                       | 'fundCannotBePaid' | 422      |
