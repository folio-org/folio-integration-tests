Feature: Init Data for Claims Export
  # parameters: orgId, orgCode, accountNo,
  #             configId, configName, transMeth, fileFormat, ftpFormat,
  #             poNumber, poLineNumber, pieceId, fundId

  Background:
    * url baseUrl

  Scenario: initData
    # 1. Create organization
    * def accounts = [{ name: "#(orgCode)_ACC", accountNo: "#(accountNo)", accountStatus: "Active" }]
    * table orgData
      | id    | code    | name    | accounts | isVendor |
      | orgId | orgCode | orgCode | accounts | true    |
    * callonce createOrganization orgData

    # 2. Create organization integration details
    * table orgIntegrationDetails
      | configId | configName | vendorId | transmissionMethod | fileFormat | ftpFormat | accountNoList    |
      | configId | configName | orgId    | transMeth          | fileFormat | ftpFormat | ["#(accountNo)"] |
    * callonce createIntegrationDetails orgIntegrationDetails

    # 3. Create order with order line and open order
    * def orderId = call uuid
    * def orderData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/order.json')
    Given path '/orders/composite-orders'
    And request orderData
    When method POST
    Then status 201

    * def poLineId = call uuid
    * def poLineData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/order-line.json')
    Given path '/orders/order-lines'
    And request poLineData
    When method POST
    Then status 201

    * def v = callonce openOrder { orderId: '#(orderId)' }

    # 4. Create title and piece
    * def titleId = call uuid
    * def titleData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/title.json')
    Given path '/orders/titles'
    And request titleData
    When method POST
    Then status 201

    * def pieceData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/piece.json')
    Given path '/orders/pieces'
    And request pieceData
    When method POST
    Then status 201