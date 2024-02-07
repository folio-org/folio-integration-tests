Feature: Profile-picture tests

  Background:
    * call read('classpath:common/util/random_numbers.feature')
    * call read('classpath:common/util/random_string.feature')
    * call read('classpath:common/util/uuid1.feature')
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def profileIdNotUploaded = 'c58d129e-347a-4931-9ffa-a27a3fffa7a8'
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }


  Scenario: Upload user profile picture

    # prepare tenant
    Given path '/users/configurations/entry'
    When method GET
    Then status 200
    * def id = response.id
    * def encryptionKey = response.encryptionKey

    Given path '/users/configurations/entry/' + id
    And request
    """
         {
           "id": "#(id)",
           "configName": "PROFILE_PICTURE_CONFIG",
           "enabled": true,
           "enabledObjectStorage": false,
           "encryptionKey": "#(encryptionKey)"
         }
     """
    When method PUT
    Then status 204

    # upload file
    * def filepath = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/'
    And configure headers = headersUserOctetStream
    And request read(filepath)
    When method POST
    Then status 201
    * def profileId = response.id

    # positive
    Given path '/users/profile-picture/' + profileId
    When method GET
    Then status 200

    # negative
    Given path '/users/profile-picture/' + profileIdNotUploaded
    When method GET
    Then status 404
    And match response == 'No profile picture found for id ' + profileIdNotUploaded

    # update user profile picture
    # positive
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 200

    # negative
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileIdNotUploaded
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method PUT
    Then status 404
    And match response == 'Existing profile picture is not found'

    # delete user profile picture
    # positive
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileId
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 204

    # negative
    * def filepathNew = 'classpath:volaris/mod-users/samples/picture1.png'
    Given path '/users/profile-picture/' + profileIdNotUploaded
    And configure headers = headersUserOctetStream
    And request read(filepathNew)
    When method DELETE
    Then status 404
    And match response == 'Profile picture not found'