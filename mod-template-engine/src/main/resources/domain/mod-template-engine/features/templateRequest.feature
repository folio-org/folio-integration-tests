Feature: Template processing requests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def templateId = call uuid1

  Scenario: Post templateProcessingRequest should return 200 and templateProcessingResult
    * def requestEntity = read('samples/template-request-entity.json')

    Given path 'templates'
    When method GET
    Then status 200

    * requestEntity.templateId = response.templates[0].id
    * requestEntity.outputFormat = response.templates[0].outputFormats[0]

    Given path 'template-request'
    And request requestEntity
    When method POST
    Then status 200
    And match $.templateId == requestEntity.templateId
    And match $.result.header == 'Complete activation of your FOLIO account'
    And match $.result.body == '<p></p><p>Your FOLIO account has been activated.</p><p>Your username is .</p><p>To complete activation of your account, please use the following link to create a password for your FOLIO account: <a href=>visit this link</a></p><p>If you do not create a password within 24 hours of the delivery of this email, then contact your FOLIO Administrator to receive a new create password link.</p><p>Regards,</p><p> FOLIO Administration</p>'

  Scenario: Post templateProcessingRequest should return 400 if template does not exist
    * def requestEntity = read('samples/template-request-entity.json')
    * def expectedResponse = 'Template with id ' + templateId + ' does not exist'

    Given path 'template-request'
    And request requestEntity
    When method POST
    Then status 400
    And match response == expectedResponse

  Scenario: Post templateProcessingRequest should return 400 if template does not support requested output format
    * def requestEntity = read('samples/template-request-entity.json')

    Given path 'templates'
    When method GET
    Then status 200

    * requestEntity.templateId = response.templates[0].id
    * requestEntity.outputFormat = 'image/jpeg'

    Given path 'template-request'
    And request requestEntity
    When method POST
    Then status 400
    Then match response == 'Requested template does not support \'image/jpeg\' output format'

  Scenario: Post templateProcessingRequest should return 400 if template does not have localized template for the specified language
    * def requestEntity = read('samples/template-request-entity.json')

    Given path 'templates'
    When method GET
    Then status 200

    * requestEntity.templateId = response.templates[0].id
    * requestEntity.outputFormat = response.templates[0].outputFormats[0]
    * requestEntity.lang = 'zh'

    Given path 'template-request'
    And request requestEntity
    When method POST
    Then status 400
    Then match response == 'Requested template does not have localized template for language \'zh\''

  Scenario: Post templateProcessingRequest should return 422 if request did not pass validation
    * def requestEntity = read('samples/template-request-entity.json')

    Given path 'templates'
    When method GET
    Then status 200

    * requestEntity.templateId = null

    Given path 'template-request'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match $.errors[0].parameters[0].key == 'templateId'
