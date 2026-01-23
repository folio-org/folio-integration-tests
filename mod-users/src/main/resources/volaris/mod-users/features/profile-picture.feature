Feature: Profile-picture tests

  Background:

    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def profileIdNotUploaded = 'c58d129e-347a-4931-9ffa-a27a3fffa7a8'
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def statusSuccess = function(){ var status = karate.get('responseStatus'); return status >= 200 && status < 300 }

  Scenario: Create Profile Picture Setting
    * call read('classpath:volaris/mod-users/features/util/initData.feature@PostProfilePictureConfigSetting')

  Scenario: Set enabledObjectStorage = false (by default DB will be enabled), set enabled = true (when profile picture feature is enabled)

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
          "encryptionKey": "#(encryptionKey)"
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 201
    * def profileId = response.id
    * assert statusSuccess()
    And print 'Response Time POST: ' + responseTime

    # Get
    Given path '/users/profile-picture/' + profileId
    When method GET
    Then status 200
    * assert statusSuccess()
    And print 'Response Time GET: ' + responseTime

    # Update
    * def filepathNew = 'classpath:volaris/mod-users/samples/pictureUpdated.jpg'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 200
    * assert statusSuccess()
    And print 'Response Time PUT: ' + responseTime

    # delete profile picture
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 204
    * assert statusSuccess()
    And print 'Response Time DELETE: ' + responseTime

    # Validation. Profile picture id does not exists.
    Given path '/users/profile-picture/' + profileIdNotUploaded
    When method GET
    Then status 404
    And match response == 'No profile picture found for id ' + profileIdNotUploaded

    # Validation. Update not existing profile picture
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileIdNotUploaded
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 404
    And match response == 'Existing profile picture is not found'

    # Delete not existing profile picture
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 404
    And match response == 'Profile picture not found'

  Scenario: Set enabledObjectStorage = false (by default DB will be enabled), set enabled = false (when profile picture feature is not enabled, it should give error)

    # prepare tenant
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
          "enabled": false,
          "enabledObjectStorage": false,
          "encryptionKey": "#(encryptionKey)"
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    * def profileId = response.id
    And match response == 'Profile picture feature is not enabled for tenant ' + testTenant

    # Get
    Given path '/users/profile-picture/' + profileId
    When method GET
    Then status 500
    And match response == 'Profile picture feature is not enabled for tenant ' + testTenant

    # Update
    * def filepathNew = 'classpath:volaris/mod-users/samples/pictureUpdated.jpg'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 500
    And match response == 'Profile picture feature is not enabled for tenant ' + testTenant

    # delete profile picture
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 500
    And match response == 'Profile picture feature is not enabled for tenant ' + testTenant

  Scenario: Validation. Upload different type of file (Photoshop Document).

    * def filepath = 'classpath:volaris/mod-users/samples/picture2.psd'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    And match response == 'Requested image should be of supported type-[PNG,JPG,JPEG]'


  Scenario: Validation. Upload different type of file (Graphics Interchange Format).

    * def filepath = 'classpath:volaris/mod-users/samples/picture3.GIF'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    And match response == 'Requested image should be of supported type-[PNG,JPG,JPEG]'

  Scenario: Validation. Upload different type of file (Portable Document Format).

    * def filepath = 'classpath:volaris/mod-users/samples/picture4.pdf'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    And match response == 'Requested image should be of supported type-[PNG,JPG,JPEG]'

  Scenario: Validation file size.

    # prepare tenant
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
          "maxFileSize": 4
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create
    * def filepath = 'classpath:volaris/mod-users/samples/pictureBigSize4.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    And match response == 'Requested file size should be within allowed size updated in profile_picture configuration'

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)',  'Accept': '*/*'  }

    # remove the maxFIleSize from config. Try to upload an image more than 10 mb. We should get error.
    * def version = version + 1
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
          "encryptionKey": "#(encryptionKey)"
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # Create
    * def filepath = 'classpath:volaris/mod-users/samples/pictureBigSize10.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 500
    And match response == 'Requested file size should be within allowed size updated in profile_picture configuration'

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)',  'Accept': '*/*'  }

    # Update configuration. Give maxFileSize value more than 10. Should get error.
    * def version = version + 1
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
          "maxFileSize": 14
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 500
    And match response == 'Max file size should not exceed more than 10 megabytes'

  Scenario: Validation Encryption key

    # prepare tenant
    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    * def id = response.settings[0].id
    * def encryptionKey = response.settings[0].value.encryptionKey
    * def version = response.settings[0]._version

    # try to update the encryption key with same key
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
          "maxFileSize": 4
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 204

    # try to update the encryption key with another key
    * def version = version + 1
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
          "encryptionKey": "another key "
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 400
    And match response == 'Cannot update the Encryption key'

    # try to update the encryption key with null value
    * def version = version + 1
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
          "encryptionKey": null,
          "maxFileSize": 14
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 400
    And match response == 'Cannot update the Encryption key'

    # try to get the configuration
    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    And match response.settings[0].value.encryptionKey == encryptionKey
    * def version = response.settings[0]._version

    # try to update the configuration when encryptionKey field is not present
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
          "maxFileSize": 14
        },
        "_version": "#(version)"
      }
      """
    When method PUT
    Then status 400
    And match response == 'Cannot update the Encryption key'

    # get the configuration
    Given path '/users/settings/entries'
    When method GET
    And param query = '(key="PROFILE_PICTURE_CONFIG")'
    And param limit = 1
    Then status 200
    And match response.settings[0].value.encryptionKey == encryptionKey