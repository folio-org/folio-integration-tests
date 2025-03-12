Feature: Manual block templates tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def manualBlockTemplatesId = call uuid1

  # CRUD

  Scenario: Create a manual block template
    * def requestEntity = read('samples/manualblocktemplates-request-entity.json')

    Given path 'manual-block-templates'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { metadata: #present, desc: #present, id: #present, name: #present }
    And match response.id == manualBlockTemplatesId

  Scenario: Get a list of manual block templates
    Given path 'manual-block-templates'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, manualBlockTemplates: #present }

  Scenario: Get a manual block template by ID
    * def requestEntity = read('samples/manualblocktemplates-request-entity.json')
    Given path 'manual-block-templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method GET
    Then status 200
    And match response.id == manualBlockTemplatesId
    And match response == { metadata: #present, name: #present, id: #present, desc: #present }

  Scenario: Update a manual block template
    * def requestEntity = read('samples/manualblocktemplates-request-entity.json')
    Given path 'manual-block-templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method GET
    Then status 200
    And response.desc == 'default description'

    * requestEntity.desc = 'updated description'
    Given path 'manual-block-templates', manualBlockTemplatesId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method GET
    Then status 200
    And response.desc == 'updated description'

  Scenario: Delete a manual block template
    * def requestEntity = read('samples/manualblocktemplates-request-entity.json')
    Given path 'manual-block-templates'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method GET
    Then status 200
    And match response.id == manualBlockTemplatesId

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method DELETE
    Then status 204

    Given path 'manual-block-templates', manualBlockTemplatesId
    When method GET
    Then status 404
    And match response == 'Not found'