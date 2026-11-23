Feature: Titles

  Background:
    * url baseUrl
    * call login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:promin/mod-kb-ebsco-java/features/samples/title/'

    * def packageId = karate.properties['packageId']
    * def titleId = karate.properties['titleId']

#   ================= positive test cases =================

  Scenario: GET all Titles searched by name with 200 on success
    Given path '/eholdings/titles'
    And param q = 'Test'
    And param q[field] = 'name'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.data[0].attributes.name contains "Test"

  Scenario: POST Titles should create a new Custom Title with 200 on success
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And def requestEntity = read(samplesPath + 'createTitle.json')
    And param q = requestEntity.data.attributes.publisherName
    And param q[field] = 'publisher'
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
    And param q = requestEntity.data.attributes.publisherName
    And param q[field] = 'publisher'
    And retry until response.meta.totalResults == initial_num_records + 1
    When method GET
    Then status 200

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

    #waiting for title creation
    * eval sleep(20000)

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

  Scenario: GET all Titles should return 400 if query param is missing
    Given path '/eholdings/titles'
    When method GET
    Then status 400
    And match response.errors[0].title == "Invalid Query Parameter for q: is required"

  Scenario: POST Titles should return 400 if custom Title with the provided name already exists
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And request read(samplesPath + 'createTitle.json')
    When method POST
    Then status 200
    And def titleId = response.data.id

    Given path '/eholdings/titles'
    And request read(samplesPath + 'createTitle.json')
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
    Given path '/eholdings/titles', titleId
    And def titleName = ''
    And def requestEntity = read(samplesPath + 'updateTitle.json')
    And request requestEntity
    When method PUT
    Then status 422