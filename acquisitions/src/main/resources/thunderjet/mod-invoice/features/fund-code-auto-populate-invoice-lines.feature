# For MODINVOICE-619, https://foliotest.testrail.io/index.php?/cases/view/934328
Feature: Fund code is automatically populated for invoice lines if it is missing

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @C934328
  @Positive
  Scenario: Fund code is automatically populated for invoice lines if it is missing
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    # 1. Create an active Fund with current budget and money allocation
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", code: "AUTO-FUND-001", name: "Auto Populate Test Fund" }
    * def fundCode = v.response.code
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create an Invoice in "Open" status without invoice lines
    * configure headers = headersUser
    * def v = call createInvoice { id: "#(invoiceId)" }

    Given path 'invoice/invoices/', invoiceId
    When method GET
    Then status 200
    And match $.status == "Open"

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 3. Send POST request to create an invoice line without fund code
    * def invoiceLineWithoutCode =
    """
    {
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "distributionType": "percentage",
          "value": 100,
          "fundId": "#(fundId)",
          "encumbrance": null,
          "expenseClassId": null
        }
      ],
      "releaseEncumbrance": true,
      "description": "Test description - without fund code",
      "quantity": 1,
      "subTotal": 5.5
    }
    """

    Given path 'invoice/invoice-lines'
    And request invoiceLineWithoutCode
    When method POST
    Then status 201
    And match $.fundDistributions[0].fundId == fundId
    And match $.fundDistributions[0].code == fundCode
    * def createdInvoiceLineId1 = $.id

    # 4. Verify fund code is displayed in invoice lines
    Given path 'invoice/invoice-lines'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.invoiceLines[0].fundDistributions[0].code == fundCode

    # 5. Send POST request to create an invoice line with invalid fund code
    * def invoiceLineWithInvalidCode =
    """
    {
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "distributionType": "percentage",
          "value": 100,
          "fundId": "#(fundId)",
          "code": "INVALID-CODE-999",
          "encumbrance": null,
          "expenseClassId": null
        }
      ],
      "releaseEncumbrance": true,
      "description": "Test description - with invalid fund code",
      "quantity": 1,
      "subTotal": 5.5
    }
    """

    Given path 'invoice/invoice-lines'
    And request invoiceLineWithInvalidCode
    When method POST
    Then status 201
    And match $.fundDistributions[0].fundId == fundId
    And match $.fundDistributions[0].code == fundCode
    * def createdInvoiceLineId2 = $.id

    # 6. Verify both invoice lines have correct fund code
    Given path 'invoice/invoice-lines'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.invoiceLines == '#[2]'
    And match each $.invoiceLines[*].fundDistributions[0].code == fundCode