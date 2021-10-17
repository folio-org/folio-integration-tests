Feature: User Assignment

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:domain/mod-kb-ebsco-java/features/samples/user-assigment/'

    * def credential = callonce read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupCredentials')
    * def credentialId = credential.credentialId
    * def existUser = read(samplesPath + 'existUser.json')

 #   ================= positive test cases =================

  Scenario: GET users by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: POST user by KB credentials id with 201 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And def userId = uuid()
    And def userName = 'TEST_USER'
    And request read(samplesPath + 'createUser.json')
    When method POST
    Then status 201

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match response.meta.totalResults == initial_num_records + 1

  Scenario: PUT user by KB credentials id with 204 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And def userId = uuid()
    And def userName = 'TEST_USER_BEFORE_UPDATE'
    And request read(samplesPath + 'createUser.json')
    When method POST
    Then status 201

    Given path '/eholdings/kb-credentials', credentialId, 'users', userId
    And def userName = 'TEST_USER_AFTER_UPDATE'
    And def requestEntity = read(samplesPath + 'createUser.json')
    And request requestEntity
    When method PUT
    Then status 204

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match response.data[*].attributes.userName contains userName

    #delete user
    Given path '/eholdings/kb-credentials', credentialId, 'users', userId
    When method DELETE
    Then status 204

#   ================= negative test cases =================

  Scenario: POST user by KB credentials id should return 400 if user is already assigned
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method POST
    Then status 400

  Scenario: POST user by KB credentials id should return 422 if required attribute is missing
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And def userId = uuid()
    And def requestEntity = read(samplesPath + 'createUser.json')
    And remove requestEntity.data.attributes.lastName
    And request requestEntity
    When method POST
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'data.attributes.lastName'

  Scenario: POST user by KB credentials id should return 422 if name is empty
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And def userId = uuid()
    And def requestEntity = read(samplesPath + 'createUser.json')
    And set requestEntity.data.attributes.userName = ''
    And request requestEntity
    When method POST
    Then status 422

  Scenario: PUT user by KB credentials id should return 400 if trying to update ID
    Given path '/eholdings/kb-credentials', credentialId, 'users', existUser.data.id
    And set existUser.data.id = uuid()
    And request existUser
    When method PUT
    Then status 400

  Scenario: PUT user by KB credentials id should return 422 if required attribute is missing
    Given path '/eholdings/kb-credentials', credentialId, 'users', existUser.data.id
    And remove existUser.data.attributes.userName
    And request existUser
    When method PUT
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'data.attributes.userName'

  Scenario: DELETE user by KB credentials id should return 400 if id is invalid
    Given path '/eholdings/kb-credentials', credentialId, 'users', 'WRONG_USER_ID'
    When method DELETE
    Then status 400

#   ================= Destroy test fata =================

  Scenario: Destroy kb-credential
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyCredentials') {credentialId: #(credentialId)}