Feature: Templates tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def templateId = call uuid1
    * def templateNotFoundId = call uuid2

  Scenario: Get all templates
    Given path 'templates'
    When method GET
    Then status 200

  # CRUD

  Scenario: Post should return 201 and new template
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'templates/' + templateId
    When method GET
    Then status 200
    And match $.description == requestEntity.description

  Scenario: Post should return 400 if template resolver is not supported
    * def requestEntity = read('samples/template-entity.json')
    * requestEntity.templateResolver = {}

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 400

  Scenario: Post should return 422 if template did not pass validation
    * def requestEntity = read('samples/invalid-template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 422

  Scenario: Get by id should return 200
    Given path 'templates'
    When method GET
    Then status 200

    Given path 'templates/' + response.templates[0].id
    When method GET
    Then status 200

  Scenario: Get by id should return 404 if template does not exist
    Given path 'templates/' + templateNotFoundId
    When method GET
    Then status 404

  Scenario: Put should return 200 and updated template
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201

    * response.description = 'Template for changing password was updated'

    Given path 'templates/' + templateId
    And request requestEntity
    When method PUT
    Then status 200

  Scenario: Put should return 400 if template resolver is not supported
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.templateResolver = {}

    Given path 'templates/' + templateId
    And request requestEntity
    When method PUT
    Then status 400

  Scenario: Put should return 404 if template does not exist
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'templates/' + templateNotFoundId
    And request requestEntity
    When method PUT
    Then status 404

  Scenario: Delete should return 204
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'templates/' + templateId
    When method DELETE
    Then status 204

  Scenario: Delete should return 404 if template does not exist
    Given path 'templates/' + templateNotFoundId
    When method DELETE
    Then status 404
