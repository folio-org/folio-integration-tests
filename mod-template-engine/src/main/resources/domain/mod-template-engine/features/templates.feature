Feature: Templates tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def templateId = call uuid1

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
    And match response.id == templateId
    And match $.description == requestEntity.description
    And match $.templateResolver == requestEntity.templateResolver

  Scenario: Post should return 400 if template resolver is not supported
    * def requestEntity = read('samples/template-entity.json')
    * requestEntity.templateResolver = 'nonexistent resolver'

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 400
    And match response == 'Template resolver \'nonexistent resolver\' is not supported'

  Scenario: Post should return 422 if template did not pass validation
    * def values = { key: ['templateResolver', 'localizedTemplates'] }

    Given path 'templates'
    And request { "templateId": "#(templateId)" }
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match values.key contains any $.errors[0].parameters[0].key
    And match values.key contains any $.errors[1].parameters[0].key

  Scenario: Get by id should return 200
    Given path 'templates'
    When method GET
    Then status 200
    And match response == { templates: #present, totalRecords: #present }
    And match response.templates[0] == { outputFormats: #present,  description: #present, id: #present, templateResolver: #present, localizedTemplates: #present }

  Scenario: Get by id should return 404 if template does not exist
    * def expectedResponse = 'Template with id \'' + templateId + '\' not found'

    Given path 'templates/', templateId
    When method GET
    Then status 404
    And match response == expectedResponse

  Scenario: Put should return 200 and updated template
    * def requestEntity = read('samples/template-entity.json')
    * def expectedDescription = 'Template for changing password was updated'

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { outputFormats: #present, metadata: #present,  description: #present, id: #present, templateResolver: #present, localizedTemplates: #present }

    * requestEntity.description = expectedDescription

    Given path 'templates/', templateId
    And request requestEntity
    When method PUT
    Then status 200

    Given  path 'templates/', templateId
    When method GET
    Then status 200
    And response.description == expectedDescription

  Scenario: Put should return 400 if template resolver is not supported
    * def requestEntity = read('samples/template-entity.json')

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { outputFormats: #present, metadata: #present,  description: #present, id: #present, templateResolver: #present, localizedTemplates: #present }

    * requestEntity.templateResolver = 'nonexistent resolver'

    Given path 'templates/' + templateId
    And request requestEntity
    When method PUT
    Then status 400
    And match response == 'Template resolver \'nonexistent resolver\' is not supported'

  Scenario: Put should return 404 if template does not exist
    * def requestEntity = read('samples/template-entity.json')
    * def expectedResponse = 'Template with id \'' + templateId + '\' not found'

    Given path 'templates/', templateId
    And request requestEntity
    When method PUT
    Then status 404
    And match response == expectedResponse

  Scenario: Delete should return 204
    * def requestEntity = read('samples/template-entity.json')
    * def expectedResponse = 'Template with id \'' + templateId + '\' not found'

    Given path 'templates'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { outputFormats: #present, metadata: #present,  description: #present, id: #present, templateResolver: #present, localizedTemplates: #present }

    Given path 'templates/', templateId
    When method DELETE
    Then status 204

    Given  path 'templates/', templateId
    When method GET
    Then status 404
    And match response == expectedResponse

  Scenario: Delete should return 404 if template does not exist
    * def expectedResponse = 'Template with id \'' + templateId + '\' not found'

    Given path 'templates/', templateId
    When method DELETE
    Then status 404
    And match response == expectedResponse
