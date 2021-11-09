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

  Scenario: Search user by firstname.
    * def expectedFirstName = 'first'
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseBarcode = createUserResponse.response.firstName
    Given path 'users?query=(personal.firstName=first)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == expectedFirstName

  Scenario: Search user by firstname & lastname.
    * def expectedFirstName = 'first'
    * def expectedLastName = 'TestUser'
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseBarcode = createUserResponse.response.firstName
    Given path 'users?query=(personal.firstName=first)or(personal.lastName=TestUser)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == expectedFirstName
    And match response.users[0].personal.lastName == expectedLastName

  Scenario: Search user by UUID.
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseUserId = createUserResponse.response.id

    Given path 'users?query=(id='+responseUserId+')'
    When method GET
    Then status 200
    And match responseUserId == response.users[0].id

  Scenario: Search user by lastname.
    * def expectedLastName = 'TestUser'
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseUserLastName = createUserResponse.response.lastName

    Given path 'users?query=(personal.lastName=TestUser)'
    When method GET
    Then status 200
    And match responseUserLastName == response.users[0].lastName

  Scenario: Search user by email.
    * def expectedEmail = 'testmail@abc.com'
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseUserEmail = createUserResponse.response.email

    Given path 'users?query=(personal.email=testmail@abc.com)'
    When method GET
    Then status 200
    And match responseUserEmail == response.users[0].email

  Scenario: Search user by username.
    * def expectedEmail = 'testmail@abc.com'
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def responseUserEmail = createUserResponse.response.email

    Given path 'users?query=(username=test-user)'
    When method GET
    Then status 200

  Scenario: Filter inactive patron.
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndInactiveUser')
    * def createUserResponse = call read('classpath:domain/mod-users/features/util/initData.feature@PostPatronGroupAndInactiveUser')

    Given path 'users?query=(active==false)'
    When method GET
    Then status 200
    And match response.resultInfo.totalRecords == 2











