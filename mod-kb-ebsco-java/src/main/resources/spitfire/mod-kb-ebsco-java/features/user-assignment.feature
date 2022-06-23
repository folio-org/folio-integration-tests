Feature: User Assignment

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/user-assigment/'

    * def credentialId = karate.properties['credentialId']
    * def assignedUserId = '00000000-1111-5555-9999-999999999992'
    * def existUserId = '00000000-1111-5555-9999-999999999991'

 #   ================= positive test cases =================

  Scenario: GET users by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match response.data[*].id contains assignedUserId

  Scenario: POST user by KB credentials id with 201 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults

    And def userId = existUserId
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And request read(samplesPath + 'assignUser.json')
    When method POST
    Then status 201

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match response.meta.totalResults == initial_num_records + 1
    And match response.data[*].id contains existUserId

  Scenario: DELETE user from KB credentials by userId with 204 on success
    Given path '/eholdings/kb-credentials', credentialId, 'users', existUserId
    When method DELETE
    Then status 204

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    And match response.data[*].id !contains existUserId

#   ================= negative test cases =================

  Scenario: POST user by KB credentials id should return 400 if user is already assigned
    And def userId = assignedUserId
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And request read(samplesPath + 'assignUser.json')
    When method POST
    Then status 400

  Scenario: POST user by KB credentials id should return 400 if user assigned to another credentials
    And def credentialsId = uuid()
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And request read(samplesPath + 'assignUser.json')
    When method POST
    Then status 422
    And match response.errors[0].title == 'The user is already assigned to another credentials'

#    Uncomment after fixing MODKBEKBJ-667
#  Scenario: POST user by KB credentials id should return 422 if user not exist
#    And def userId = uuid()
#    Given path '/eholdings/kb-credentials', credentialId, 'users'
#    And request read(samplesPath + 'assignUser.json')
#    When method POST
#    Then status 422
#    And match response.errors[0].message == 'user with provided id not exist'

  Scenario: POST user by KB credentials id should return 422 if required attribute is missing
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And def requestEntity = read(samplesPath + 'assignUser.json')
    And remove requestEntity.data.id
    And request requestEntity
    When method POST
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'data.id'

  Scenario: DELETE user by KB credentials id should return 400 if id is invalid
    Given path '/eholdings/kb-credentials', credentialId, 'users', 'WRONG_USER_ID'
    When method DELETE
    Then status 400
