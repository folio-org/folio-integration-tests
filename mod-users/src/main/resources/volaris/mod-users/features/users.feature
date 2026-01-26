Feature: Users tests

  Background:
    * call read('classpath:common/util/random_numbers.feature')
    * call read('classpath:common/util/random_string.feature')
    * call read('classpath:common/util/uuid1.feature')
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)',  'Accept': '*/*'  }
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'

    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

  Scenario: Create Profile Picture Setting
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostProfilePictureConfigSetting')

  Scenario: Create a new User with PatronGroup.
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = call uuid1
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') {status: true, uuid: #(uuid), username: #(username), barcode: #(barcode)}

  Scenario: Search user by barcode.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { barcode: #(barcode), status: true, uuid: #(uuid), username: #(username)}
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { barcode: #(barcode), status: true, uuid: #(uuid), username: #(username)}

    Given path 'users'
    And param query = '(barcode='+ barcode +')'
#    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + extItemId + ')'
    When method GET
    Then status 200
    And match response.users[0].barcode == barcode.toString()
    And match response.totalRecords == 1

  Scenario:  Find an active user and make that user the sponsor of another active patron
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createUserResponse = call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.response.id
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createProxyUserResponse = call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser')
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
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: abc, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * def createUserResponse = call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: xyz, status: true, uuid: #(uuid), username: #(username) }
    * def responseBarcode = createUserResponse.response.firstName

    Given path 'users'
    And param query = '(personal.firstName=abc)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == 'abc'

  Scenario: Search user by firstname & lastname.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: abc,lastName: xyz, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { firstName: pqr,lastName: def, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(personal.firstName=abc)and(personal.lastName=xyz)'
    When method GET
    Then status 200
    And match response.users[0].personal.firstName == 'abc'
    And match response.users[0].personal.lastName == 'xyz'


  Scenario: Search user by UUID.
    * def username = call random_string
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { uuid: #(uuid), status: true, username: #(username), barcode: #(barcode) }
    * def barcode = call random_numbers
    * def username = call random_string
    * def uuid = call uuid1
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { uuid: #(uuid), status: true, username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(id=' + uuid + ')'
    When method GET
    Then status 200
    And match response.users[0].id == uuid.toString()


  Scenario: Search user by lastname.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { lastName: abc, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { lastName: pqr, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(personal.lastName=pqr)'
    When method GET
    Then status 200
    And match response.users[0].personal.lastName == 'pqr'


  Scenario: Search user by email.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { email: testmail@abc.com, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { email: abc@xyz.com, status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(personal.email=testmail@abc.com)'
    When method GET
    Then status 200
    And match response.users[0].personal.email == 'testmail@abc.com'

  Scenario: Search user by username.
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * def username = call random_string
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * def username = call random_string
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(username=' + username + ')'
    When method GET
    Then status 200
    And match response.users[0].username == username

  Scenario: Use keyword search to find a user by username.
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * def username = call random_string
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def barcode = call random_numbers
    * def username = call random_string
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '((username='+ username +' or personal.firstName="mnq*" or personal.preferredFirstName="mnq*" or personal.lastName="mnq*" or personal.email="mnq*" or barcode="mnq*" or id="mnq*" or externalSystemId="mnq*" or customFields="mnq*"))'
    When method GET
    Then status 200
    And match response.users[0].username == username

  Scenario: Filter inactive patron.
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode) }
    * def uuid = call uuid1
    * def username = call random_string
    * def barcode = call random_numbers
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUser') { status: false, uuid: #(uuid), username: #(username), barcode: #(barcode) }

    Given path 'users'
    And param query = '(active==false)'
    When method GET
    Then status 200


  Scenario: Update User's Profile Picture

    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    * def id = response.settings[0].id
    * def encryptionKey = response.settings[0].value.encryptionKey
    * def version = response.settings[0]._version

    Given path '/users/settings/entries/' + id
    And request
    """
      {
        "id": "#(id)",
        "scope": "mod-users",
        "key": "PROFILE_PICTURE_CONFIG",
        "value": {
          "enabled": true,
          "enabledObjectStorage": false,
          "encryptionKey": "#(encryptionKey)",
        },
        "_version": "#(version)"
      }
    """
    When method PUT
    Then status 204

    # Create Profile Picture
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 201
    * def profileId = response.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)',  'Accept': '*/*'  }

    # Create User with Profile Picture
    * def barcode = call random_numbers
    * def username = call random_string
    * def uuid = call uuid1
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUserWithProfilePicture') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode)}

    # Update Profile Picture with Id
    * def filepathNew = 'classpath:volaris/mod-users/samples/pictureUpdated.jpg'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 200

    # Get User by Id
    Given path 'users'
    And param query = '(id='+ uuid +')'
    When method GET
    Then status 200
    And match response.users[0].id == uuid.toString()


    # Get Profile Picture by Id
    Given path '/users/profile-picture/' + profileId
    When method GET
    Then status 200

  Scenario: Delete User. Linked Profile Picture should stay.

    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    * def id = response.settings[0].id
    * def encryptionKey = response.settings[0].value.encryptionKey
    * def version = response.settings[0]._version

    Given path '/users/settings/entries/' + id
    And request
      """
      {
        "id": "#(id)",
        "scope": "mod-users",
        "key": "PROFILE_PICTURE_CONFIG",
        "value": {
          "enabled": true,
          "enabledObjectStorage": false,
          "encryptionKey": "#(encryptionKey)",
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create Profile Picture
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 201
    * def profileId = response.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)',  'Accept': '*/*'  }

    # Create User with Profile Picture
    * def barcode = call random_numbers
    * def username = call random_string
    * def uuid = call uuid1
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUserWithProfilePicture') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode)}

    # Delete User by Id
    Given path 'users'
    And param query = '(id='+ uuid +')'
    When method DELETE
    Then status 204

    # Get Profile Picture by Id
    Given path '/users/profile-picture/' + profileId
    When method GET
    Then status 200

  Scenario: Delete Profile Picture, which is already has linked to User.

    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    * def id = response.settings[0].id
    * def encryptionKey = response.settings[0].value.encryptionKey
    * def version = response.settings[0]._version

    Given path '/users/settings/entries/' + id
    And request
      """
      {
        "id": "#(id)",
        "scope": "mod-users",
        "key": "PROFILE_PICTURE_CONFIG",
        "value": {
          "enabled": true,
          "enabledObjectStorage": false,
          "encryptionKey": "#(encryptionKey)",
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create Profile Picture
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 201
    * def profileId = response.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)','Accept': '*/*'  }

    # Create User with Profile Picture
    * def barcode = call random_numbers
    * def username = call random_string
    * def uuid = call uuid1
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostPatronGroupAndUserWithProfilePicture') { status: true, uuid: #(uuid), username: #(username), barcode: #(barcode)}

    # delete profile picture
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 204

    # Get User by Id
    Given path 'users'
    And param query = '(id=' + uuid + ')'
    When method GET
    Then status 200
    And match response.users[0].id == uuid.toString()
