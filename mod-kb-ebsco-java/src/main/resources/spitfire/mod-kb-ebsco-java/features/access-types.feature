Feature: Access types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/access-types/'

    * def credentialId = karate.properties['credentialId']

#   ================= positive test cases =================

  Scenario: Get all Access types with 200 on success
    Given path "/eholdings/access-types"
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: GET all Access types by KB credentials id with 200 on success
    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: POST Access type by KB credentials id with 201 on success
    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults
    And def accessName = random_string()
    And def requestEntity = read(samplesPath + 'createAccessType.json')

    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    And request requestEntity
    When method POST
    Then status 201

    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    When method GET
    Then status 200
    And match response.meta.totalResults == initial_num_records + 1

  Scenario: PUT Access type by KB credentials id with 204 on success
    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    And def accessName = random_string() + 'TEST_ACCESS_BEFORE_UPDATE'
    And request read(samplesPath + 'createAccessType.json')
    When method POST
    Then status 201
    And def accessId = response.id

    Given path "/eholdings/kb-credentials", credentialId, 'access-types', accessId
    And def accessName = random_string() + 'UPDATED_TEST_ACCESS'
    And def requestEntity = read(samplesPath + 'createAccessType.json')
    And request requestEntity
    When method PUT
    Then status 204

    Given path "/eholdings/kb-credentials", credentialId, 'access-types', accessId
    When method GET
    Then status 200
    And match response.attributes.name == requestEntity.data.attributes.name

    #delete access-type
    Given path "/eholdings/kb-credentials", credentialId, 'access-types', accessId
    When method DELETE
    Then status 204

#   ================= negative test cases =================

  Scenario: GET Access type by id should return 400 if id is invalid
    Given path "/eholdings/access-types", 'INVALID_ID'
    When method GET
    Then status 400

  Scenario: POST Access type by KB credentials id should return 422 if Access type is already exists
    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    And def accessName = 'TEST_ACCESS'
    And request read(samplesPath + 'createAccessType.json')
    When method POST
    Then status 201

    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    And request read(samplesPath + 'createAccessType.json')
    When method POST
    Then status 422

  Scenario: POST Access type by KB credentials id should return 422 if name is more then 75 characters
    Given path "/eholdings/kb-credentials", credentialId, 'access-types'
    And def accessName = new Array(76).fill('1').join('')
    And request read(samplesPath + 'createAccessType.json')
    When method POST
    Then status 422

  Scenario: GET Access type by KB credentials id should return 400 if id is invalid
    Given path "/eholdings/kb-credentials", credentialId, 'access-types', 'INVALID_ID'
    When method GET
    Then status 400

  Scenario: PUT Access type by KB credentials id should return 422 if required attribute is missing
    Given path "/eholdings/kb-credentials", credentialId, 'access-types', uuid()
    And def requestEntity = read(samplesPath + 'createAccessType.json')
    And remove requestEntity.data.attributes.name
    And request requestEntity
    When method PUT
    Then status 422