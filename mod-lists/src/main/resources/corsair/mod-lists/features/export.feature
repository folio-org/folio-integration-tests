Feature: Scenarios that are primarily focused around exporting list data

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

  Scenario: Getting '404 Response' for invalid exportId
    * def invalidExportId = call uuid1
    Given path 'lists', loanListId, 'exports', invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Getting '404 Response' for invalid listId
    * def invalidListId = call uuid1
    * def invalidExportId = call uuid1
    Given path 'lists', invalidListId, 'exports', invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Export should fail if list is refreshing
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists', listId, 'exports'
    When method POST
    Then status 400

    Given path 'lists', listId, 'refresh'
    When method DELETE
    Then status 204

  Scenario: Export test - Instance - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/instance-list.json')
    * def fields = ['instance.hrid', 'instance.title', 'instance.id']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['instance.hrid', 'instance.title', 'instance.id']

  Scenario: Export test - Item - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/item-list.json')
    * def fields = ['items.barcode', 'items.status_name', 'items.hrid']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['items.barcode', 'items.status_name', 'items.hrid']

  Scenario: Export test - Holdings - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/holdings-list.json')
    * def fields = ['holdings.hrid', 'holdings.call_number', 'holdings.id']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['holdings.hrid', 'holdings.call_number', 'holdings.id']

  Scenario: Export test - Organization - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/organization-list.json')
    * def fields = ['organization.name', 'organization.code', 'organization.id']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['organization.name', 'organization.code', 'organization.id']

  Scenario: Export test - Loan - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/loan-list.json')
    * def fields = ['loans.due_date', 'loans.checkout_date', 'loans.id']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['loans.due_date', 'loans.checkout_date', 'loans.id']

  Scenario: Export test - POL - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/pol-list.json')
    * def fields = ['pol.po_line_number', 'pol.title_or_package', 'pol.id']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['pol.po_line_number', 'pol.title_or_package', 'pol.id']

  Scenario: Export test - User - Selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def fields = ['users.username', 'users.active', 'users.barcode']
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == ['users.username', 'users.active', 'users.barcode']

  Scenario: Export test - Instance - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/instance-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - Item - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/item-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - Holdings - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/holdings-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - Organization - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/organization-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - Loan - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/loan-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - POL - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/pol-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields

  Scenario: Export test - User - All columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def exportResult = call read('classpath:corsair/mod-lists/features/util/export-list.feature')
    * def exportId = exportResult.exportId
    * def listId = exportResult.listId
    * def allFields = exportResult.allFields

    Given path 'lists', listId, 'exports', exportId
    When method GET
    Then status 200
    And match $.fields == allFields
