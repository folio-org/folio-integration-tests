Feature: transactions tests

  Background:
    * url baseUrl

#    * callonce dev {tenant: 'testfinance'}

    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  Scenario: Create fiscal year
    Given path 'finance/fiscal-years'
    And request
    """
    {
        "id": "1477d5b9-0818-4c34-86d7-45b81b8cca38",
        "code": "ALLOCFY2019",
        "name": "Test fiscal year",
        "periodStart": "2019-01-01T00:00:00Z",
        "periodEnd": "2025-12-30T23:59:59Z"
    }
    """
    When method POST
    Then status 201

  Scenario: Create ledgers
    Given path 'finance/ledgers'
    And request
    """
    {
        "id": "6e50cf5b-9c9a-465f-a1e2-79ba0ba005e6",
        "code": "ALLOC-LDGR",
        "ledgerStatus": "Active",
        "name": "Test transaction ledger",
        "fiscalYearOneId": "1477d5b9-0818-4c34-86d7-45b81b8cca38"
    }
    """
    When method POST
    Then status 201

  Scenario: Create fund
    Given path 'finance/funds'
    And request
    """
    {
        "fund": {
            "id": "47d9ac2e-52d4-4fb4-bf80-6f6ced186a3d",
            "code": "ALLOC-FND",
            "fundStatus": "Active",
            "ledgerId": "6e50cf5b-9c9a-465f-a1e2-79ba0ba005e6",
            "name": "Test fund"
        },
        "groupIds": []
    }
    """
    When method POST
    Then status 201
    # TODO need to validate


  Scenario: Create budget
    Given path 'finance/budgets'
    And request
    """
    {
        "id": "258e224e-fc17-48d3-89c4-681a06bf3c07",
        "allocated": 0,
        "name": "ALLOC-BDGT",
        "budgetStatus": "Active",
        "fundId": "47d9ac2e-52d4-4fb4-bf80-6f6ced186a3d",
        "fiscalYearId": "1477d5b9-0818-4c34-86d7-45b81b8cca38",
        "allowableEncumbrance": 100,
        "allowableExpenditure": 100
    }
    """
    When method POST
    Then status 201
    # TODO need to validate


  Scenario: Create allocations
    Given path 'finance/allocations'
    And request
    """
    {
        "id": "071185ff-183e-400e-a334-3894e10f8753",
        "amount": 25,
        "currency": "USD",
        "description": "PO_Line: History of Incas",
        "fiscalYearId": "1477d5b9-0818-4c34-86d7-45b81b8cca38",
        "source": "User",
        "toFundId": "47d9ac2e-52d4-4fb4-bf80-6f6ced186a3d",
        "transactionType": "Allocation"
    }
    """
    When method POST
    Then status 201
    # TODO need to validate


  Scenario: Get transaction by id
    Given path 'finance/transactions', '071185ff-183e-400e-a334-3894e10f8753'
    When method GET
    Then status 200
#    And match response == schema.transaction
    * print schema
#    And match response == schema.transaction
    And match response contains { amount: 25.0}

  Scenario: Get transaction by query
    Given path 'finance/transactions'
    And param query = 'id==071185ff-183e-400e-a334-3894e10f8753'
    When method GET
    Then status 200
    And match each response.transactions contains {id: '#uuid', fiscalYearId: '#uuid', toFundId: '#uuid', amount: 25.0, transactionType: 'Allocation', metadata: '#present'}

  Scenario: Get ledgers with summary
    Given path 'finance/ledgers', '6e50cf5b-9c9a-465f-a1e2-79ba0ba005e6'
    And param fiscalYear = '1477d5b9-0818-4c34-86d7-45b81b8cca38'
    When method GET
    Then status 200
    # TODO need to validate

  Scenario: Get ledger records by fiscalYear with summary
    Given path 'finance/ledgers'
    And param fiscalYear = '1477d5b9-0818-4c34-86d7-45b81b8cca38'
    And param query = 'id==6e50cf5b-9c9a-465f-a1e2-79ba0ba005e6'
    When method GET
    Then status 200
    And match each response.ledgers contains {id: '#uuid', code: 'ALLOC-LDGR', fiscalYearOneId: '#uuid', allocated: 25.0, available: 25.0, metadata: '#present' }

  Scenario: Delete transaction
    * call login testAdmin
    Given path 'finance-storage/transactions', '071185ff-183e-400e-a334-3894e10f8753'
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'text/plain'  }
    When method DELETE
    Then status 204

  Scenario: Delete budget
    Given path 'finance/budgets', '258e224e-fc17-48d3-89c4-681a06bf3c07'
    When method DELETE
    Then status 204

  Scenario: Delete funds
    Given path 'finance/funds', '47d9ac2e-52d4-4fb4-bf80-6f6ced186a3d'
    When method DELETE
    Then status 204

  Scenario: Delete ledgeer
    Given path 'finance/ledgers', '6e50cf5b-9c9a-465f-a1e2-79ba0ba005e6'
    When method DELETE
    Then status 204

  Scenario: Delete fiscal year
    Given path 'finance/fiscal-years', '1477d5b9-0818-4c34-86d7-45b81b8cca38'
    When method DELETE
    Then status 204
