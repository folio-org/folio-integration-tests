Feature: patrons tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def uuid = call uuid1
    * def firstName = call random_string
    * def lastName = call random_string
    * def userName = call random_string
    * def owner = random_string


  Scenario: Return total fees/fines regardless of fee/fine being attached to an item for a patron.
    * def itemId = call uuid1
    * def materialTypeId = call uuid1
    * def materialTypeName = random_string
    * def barcode = call random_numbers
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def materialTypeId = call uuid1
    * def materialTypeName = random_string
    * def barcode = call random_numbers
    * def itemId = call uuid1
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.createUserRequest.id
    * def createFineResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine')
    * def createFineResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine')

    Given path 'accounts?query=(userId=='+userId+')'
    When method GET
    Then status 200
    And match response.totalRecords == 2

