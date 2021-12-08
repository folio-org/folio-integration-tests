Feature: Titles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/title/'

    * def credentialId = karate.properties['credentialId']
    * def packageId = karate.properties['packageId']

#   ================= positive test cases =================

  Scenario: GET all Titles filtered by name with 200 on success
    Given path '/eholdings/titles'
    And param filter[name] = 'Test'
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: POST Titles should create a new Custom Title with 200 on success
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And def requestEntity = read(samplesPath + 'createTitle.json')
    And param filter[publisher] = requestEntity.data.attributes.publisherName
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults

    Given path '/eholdings/titles'
    And request requestEntity
    When method POST
    Then status 200
    And def titleId = response.data.id

    #waiting for title creation
    * eval sleep(20000)

    Given path '/eholdings/titles'
    And param filter[publisher] = requestEntity.data.attributes.publisherName
    When method GET
    Then status 200
    And match response.meta.totalResults == initial_num_records + 1

    Given path '/eholdings/titles', titleId
    When method GET
    Then status 200
    And def attributes = response.data.attributes;
    And match attributes.name == requestEntity.data.attributes.name
    And match attributes.publisherName == requestEntity.data.attributes.publisherName
    And match attributes.publicationType == requestEntity.data.attributes.publicationType

  Scenario: GET Title by id with 200 on success
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And def requestEntity = read(samplesPath + 'createTitle.json')
    And request requestEntity
    When method POST
    Then status 200
    And def titleId = response.data.id

    Given path '/eholdings/titles', titleId
    When method GET
    Then status 200
    And match response.data.attributes.name == requestEntity.data.attributes.name

  Scenario: PUT Title by id with 200 on success
    Given path '/eholdings/titles'
    And def randomPrefix = random_string()
    And def titleName = randomPrefix + 'TEST_TITLE_BEFORE_UPDATE'
    And request read(samplesPath + 'createTitle.json')
    When method POST
    Then status 200
    And def titleId = response.data.id

    Given path '/eholdings/titles', titleId
    And def titleName = randomPrefix + 'UPDATED_TEST_TITLE'
    And def requestEntity = read(samplesPath + 'updateTitle.json')
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/titles', titleId
    When method GET
    Then status 200
    And match response.data.attributes.name == requestEntity.data.attributes.name


#   ================= negative test cases =================

  Scenario: GET all Titles should return 400 if filter param is missing
    Given path '/eholdings/titles'
    When method GET
    Then status 400
    And match response.errors[0].title == "All of filter[name], filter[isxn], filter[subject] and filter[publisher] cannot be missing."

  Scenario: POST Titles should return 400 if custom Title with the provided name already exists
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And request read(samplesPath + 'createTitle.json')
    When method POST
    Then status 200
    And def titleId = response.data.id

    Given path '/eholdings/titles'
    And request  read(samplesPath + 'createTitle.json')
    When method POST
    Then status 400

  Scenario: POST Titles should return 422 if name is not provided
    Given path '/eholdings/titles'
    And def titleName = ''
    And def requestEntity = read(samplesPath + 'createTitle.json')
    And request requestEntity
    When method POST
    Then status 422

  Scenario: PUT Title by id should return 422 if name is not provided
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And request read(samplesPath + 'createTitle.json')
    When method POST
    Then status 200
    And def titleId = response.data.id

    Given path '/eholdings/titles', titleId
    And def titleName = ''
    And def requestEntity = read(samplesPath + 'updateTitle.json')
    And request requestEntity
    When method PUT
    Then status 422