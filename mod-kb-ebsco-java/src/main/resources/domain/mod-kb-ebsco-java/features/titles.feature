Feature: Titles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def testTitle = read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/title.json')

#   ================= positive test cases =================

  Scenario: GET all Titles filtered by tags with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by access-type with 200 on success
    Given path '/eholdings/titles'
    And param filter[access-type] = 'test'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by selection status with 200 on success
    Given path '/eholdings/titles'
    And param filter[name] = 'test'
    And param filter[selected] = 'true'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by type with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    And param filter[type] = 'book'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by name with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    And param filter[name] = 'test'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by isxn with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    And param filter[isxn] = '0000-1111'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by subject with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    And param filter[subject] = 'test'
    When method GET
    Then status 200

  Scenario: GET all Titles filtered by publisher with 200 on success
    Given path '/eholdings/titles'
    And param filter[tags] = 'test'
    And param filter[publisher] = 'test'
    When method GET
    Then status 200

  @Undefined
  Scenario: POST Titles should create a new Custom Title with 200 on success
    Given path '/eholdings/titles'
    And request testTitle
    When method POST
    Then status 200
    * def titleId = response.data.id

  @Undefined
  Scenario: GET Title by id with 200 on success
    Given path '/eholdings/titles', titleId
    When method GET
    Then status 200
    And match response.data.attributes.name == testTitle.data.attributes.name

  @Undefined
  Scenario: PUT Title by id with 200 on success
    * print 'undefined'


#   ================= negative test cases =================

  Scenario: GET all Titles should return 400 if filter param is missing
    Given path '/eholdings/titles'
    When method GET
    Then status 400
    And match response.errors[0].title == "All of filter[name], filter[isxn], filter[subject] and filter[publisher] cannot be missing."

  Scenario: POST Titles should return 400 if custom Title with the provided name already exists
    Given path '/eholdings/titles'
    And request testTitle
    When method POST
    Then status 400

  @Undefined
  Scenario: POST Titles should return 422 if Identifier subtype is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Title by id should return 404 if Title not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Title by id should return 422 if Identifier subtype is invalid
    * print 'undefined'
