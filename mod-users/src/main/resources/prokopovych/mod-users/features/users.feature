Feature: Users tests

  Background:
    * call read('classpath:common/util/random_numbers.feature')
    * call read('classpath:common/util/random_string.feature')
    * call read('classpath:common/util/uuid1.feature')
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'

  Scenario: Create a new User with PatronGroup.
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = call uuid1
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser')

  Scenario: Search user by barcode.
    * def uuid = call uuid1
    * def username = call random_string
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { barcode: 2222}
    * def uuid = call uuid1
    * def username = call random_string
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { barcode: 3333}

    Given path 'users'
    And param query = '(barcode=2222)'
    When method GET
    Then status 200
    And match response.users[0].barcode == '2222'
    And match response.totalRecords == 1

  Scenario:  Find an active user and make that user the sponsor of another active patron
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createUserResponse = call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.response.id
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createProxyUserResponse = call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def proxyUserId = createProxyUserResponse.response.id

    Given path 'proxiesfor'
    And request {"accrueTo":"Sponsor","notificationsTo":"Sponsor","requestForSponsor":"Yes","status":"Active","proxyUserId":"#(proxyUserId)","userId":"#(userId)"}
    When method POST
    Then status 201
    And match proxyUserId == response.proxyUserId

  Scenario: Search user by firstname.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: abc }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createUserResponse = call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: xyz }
    * def responseBarcode = createUserResponse.response.firstName

    Given path 'users'
    And param query = '(personal.firstName=abc)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == 'abc'
    And match response.totalRecords == 1

  Scenario: Search user by firstname & lastname.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: abc,lastName: xyz }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: pqr,lastName: def }

    Given path 'users'
    And param query = '(personal.firstName=abc)and(personal.lastName=xyz)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == 'abc'
    And match response.users[0].personal.lastName == 'xyz'
    And match response.totalRecords == 1

  Scenario: Search user by UUID.
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { uuid: 00000000-aaaa-1bbb-8ddd-eeeeeeeeeeee }
    * def barcode = call random_numbers
    * def username = call random_string
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { uuid: 11111111-bbbb-2ccc-9ddd-ffffffffffff }

    Given path 'users'
    And param query = '(id=11111111-bbbb-2ccc-9ddd-ffffffffffff)'
    When method GET
    Then status 200
    And match response.users[0].id == '11111111-bbbb-2ccc-9ddd-ffffffffffff'
    And match response.totalRecords == 1

  Scenario: Search user by lastname.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { lastName: abc }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { lastName: pqr }

    Given path 'users'
    And param query = '(personal.lastName=pqr)'
    When method GET
    Then status 200
    And match response.users[0].personal.lastName == 'pqr'
    And match response.totalRecords == 1

  Scenario: Search user by email.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { email: testmail@abc.com }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { email: abc@xyz.com }

    Given path 'users'
    And param query = '(personal.email=testmail@abc.com)'
    When method GET
    Then status 200
    And match response.users[0].personal.email == 'testmail@abc.com'
    And match response.totalRecords == 1

  Scenario: Search user by username.
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { username: aaa }
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { username: bbb }

    Given path 'users'
    And param query = '(username=aaa)'
    When method GET
    Then status 200
    And match response.users[0].username == 'aaa'
    And match response.totalRecords == 1

  Scenario: Use keyword search to find a user by username.
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { username: xyz }
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { username: mnq }

    Given path 'users'
    And param query = '((username="mnq*" or personal.firstName="mnq*" or personal.preferredFirstName="mnq*" or personal.lastName="mnq*" or personal.email="mnq*" or barcode="mnq*" or id="mnq*" or externalSystemId="mnq*" or customFields="mnq*"))'
    When method GET
    Then status 200
    And match response.users[0].username == 'mnq'
    And match response.totalRecords == 1

  Scenario: Filter inactive patron.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:prokopovych/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: false }

    Given path 'users'
    And param query = '(active==false)'
    When method GET
    Then status 200
    And match response.resultInfo.totalRecords == 1
