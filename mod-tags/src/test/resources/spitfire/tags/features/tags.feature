Feature: Mod-tags integration tests

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': '*/*' }
    * configure headers = headers

    * def tag = read('classpath:samples/tag.json')
    * def invalid_tag = read('classpath:samples/invalid-tag.json')
    * def random_uuid = uuid()


  @Positive
  Scenario: GET '/tags' should return 200 and collection of tags
    Given path 'tags'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.totalRecords == 2
    And match response.tags[0].label == 'important'
    And match response.tags[1].label == 'urgent'
    And match response.tags[1].description == 'Requires urgent attention'

  @Positive
  Scenario: GET '/tags/{id}' should return 200 and tag with specified id
    Given path 'tags'
    When method GET
    Then status 200
    * def test_tag = response.tags[0]

    Given path 'tags', test_tag.id
    When method GET
    Then status 200
    And match response == test_tag

  @Positive
  Scenario: POST '/tags' should return 201 and created tag with id
    Given path 'tags'
    And request tag
    When method POST
    Then status 201
    And response.id == '#present'
    And response.label == 'tag.label'
    And response.description == 'tag.description'


    Given path 'tags', response.id
    When method DELETE
    And status 204

  @Positive
  Scenario: PUT '/tags/{id}' should return 204 if tag was successfully updated
    Given path 'tags'
    And request tag
    When method POST
    Then status 201
    * def test_tag = response

    Given path 'tags', test_tag.id
    And request test_tag
    And set test_tag.description = 'new description'
    And set test_tag.label = 'new label'
    When method PUT
    Then status 204

    Given path 'tags', test_tag.id
    When method GET
    And response.id == test_tag.id
    And response.label == test_tag.label
    And response.description == test_tag.description

    Given path 'tags', test_tag.id
    When method DELETE
    Then status 204

  @Positive
  Scenario: DELETE '/tags/{id}' should return 204 if tag was successfully deleted
    Given path 'tags'
    And request tag
    When method POST
    Then status 201

    Given path 'tags', response.id
    When method DELETE
    Then status 204

  @Negative
  Scenario: GET '/tags' should return 422 when malformed request body or query parameter
    Given path 'tags'
    And param query = 'invalid query'
    When method GET
    Then status 422

  @Negative
  Scenario: POST '/tags' should return 422 when malformed request body or query parameter
    Given path 'tags'
    And request {}
    When method POST
    Then status 422

  @Negative
  Scenario: DELETE '/tags/{id}' should return 422 when malformed request body or query parameter
    Given path 'tags/1'
    When method DELETE
    And status 422

  @Negative
  Scenario: GET '/tags/{id}' should return 404 if tag with specified id not found
    Given path 'tags', random_uuid
    When method GET
    And status 404

  @Negative
  Scenario: PUT '/tags/{id}' should return 404 if tag with specified id not found
    Given path 'tags', random_uuid
    And request tag
    When method PUT
    And status 404

  @Negative
  Scenario: DELETE '/tags/{id}' should return 404 if tag with specified id not found
    Given path 'tags', random_uuid
    When method DELETE
    And status 404

  @Negative
  Scenario: GET '/tags/{id}' should return 422 when specified id is not UUID
    Given path 'tags/1'
    When method GET
    Then status 422

  @Negative
  Scenario: POST '/tags' should return 422 when label parameter is absent
    Given path 'tags'
    And request invalid_tag
    When method POST
    Then status 422

  @Negative
  Scenario: POST '/tags' should return 422 when label is already exist
    Given path 'tags'
    When method GET
    Then status 200
    * def test_tag = response.tags[0]

    Given path 'tags'
    And request tag
    And set tag.label = test_tag.label
    When method POST
    Then status 422

  @Negative
  Scenario: PUT '/tags' should return 422 when label is already exist
    Given path 'tags'
    When method GET
    Then status 200
    * def first_tag = response.tags[0]
    * def second_tag = response.tags[1]

    Given path 'tags', first_tag.id
    And request first_tag
    And set first_tag.label = second_tag.label
    When method PUT
    Then status 422
