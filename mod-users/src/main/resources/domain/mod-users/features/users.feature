Feature: Users tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Create a new User with PatronGroup.
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')

  Scenario: Search user by barcode.
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseBarcode = createUserResponse.response.barcode
    * print responseBarcode
    Given path 'users?query=(barcode='+responseBarcode+')'
    When method GET
    Then status 200
    * def expectedBarcode = response.users[0].barcode
    * print expectedBarcode
    And match expectedBarcode == responseBarcode

  Scenario:  Find an active user and make that user the sponsor of another active patron
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.response.id
    * def createProxyUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def proxyUserId = createProxyUserResponse.response.id
    Given path 'proxiesfor'
    And request {"accrueTo":"Sponsor","notificationsTo":"Sponsor","requestForSponsor":"Yes","status":"Active","proxyUserId":"#(proxyUserId)","userId":"#(userId)"}
    When method POST
    Then status 201
    And match proxyUserId == response.proxyUserId






