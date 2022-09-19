Feature: Check error response with fundcode upon invoice approval

  Background:
    * url baseUrl
    # uncomment below line for development
#   * callonce dev {tenant: 'testinvoices'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

  Scenario Outline: Approve invoice with <invoiceAmount> amount and budget with <allocated> amount to get code <httpCode> & <fundCode>

    * def budgetId = call uuid
    * def fundId = call uuid
    * def fundCode = call uuid

    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # ============= Create funds =============
    * configure headers = headersAdmin
    Given path 'finance-storage/funds'
    And request
    """
    {

      "id": "#(fundId)",
      "code": "<fundCode>",
      "description": "Fund for orders API Tests",
      "externalAccountNo": "1111111111111111111111111",
      "fundStatus": "Active",
      "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
      "name": "Fund for orders API Tests"
    }
    """
    When method POST
    Then status 201

    # ============= Create budgets ===================
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
      "budgetStatus": "Active",
      "allowableExpenditure": 100,
      "allowableEncumbrance": 100,
      "allocated": <allocated>,
      "netTransfers": 10
    }
    """
    When method POST
    Then status 201

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
