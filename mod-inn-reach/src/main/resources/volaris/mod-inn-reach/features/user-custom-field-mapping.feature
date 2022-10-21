@parallel=false
Feature: User custom field mapping

  Background:
    * url baseUrl + '/inn-reach/central-servers'

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

  @create
  Scenario: Create user custom field mapping
    * print 'Create user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    And request read(samplesPath + 'user-custom-field-mapping/create-user-custom-field-mappings-request.json')
    When method POST
    Then status 201
    And match response.id == '#notnull'
    And match response.customFieldId == 'b376851e-a76b-450b-9945-d035128f628f'
    And match response.configuredOptions.agencyCode == 'test1'
    And match response.configuredOptions.customField == '12345'

  Scenario: Create user custom field mapping which already mapped
    * print 'Create user custom field mapping which already mapped'
    Given path centralServer1.id + '/user-custom-field-mappings'
    And request read(samplesPath + 'user-custom-field-mapping/create-user-custom-field-mappings-request.json')
    When method POST
    Then status 409

  Scenario: Create user custom field mapping with invalid data
    * print 'Create user custom field mapping with invalid data'
    Given path centralServer2.id + '/user-custom-field-mappings'
    And request read(samplesPath + 'user-custom-field-mapping/create-user-custom-field-mappings-invalid-request.json')
    When method POST
    Then status 409

  Scenario: Get user custom field mapping
    * print 'Get user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    When method GET
    Then status 200
    And match response.id == '#notnull'
    And match response.customFieldId == 'b376851e-a76b-450b-9945-d035128f628f'
    And match response.configuredOptions.agencyCode == 'test1'
    And match response.configuredOptions.customField == '12345'

  Scenario: Get user custom field mapping which not exist
    * print 'Get user custom field mapping which not exist'
    Given path centralServer2.id + '/user-custom-field-mappings'
    When method GET
    Then status 404

  Scenario: Update user custom field mapping
    * print 'Prepare user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    When method GET
    Then status 200
    * def req = get response
    * set req.customFieldId = 'updateId'
    * set req.configuredOptions.agencyCode = "upd11"
    * set req.configuredOptions.customField = "54321"

    * print 'Update user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    And request req
    When method PUT
    Then status 204

    * print 'Check successful update'
    Given path centralServer1.id + '/user-custom-field-mappings'
    When method GET
    Then status 200
    And match response.id == req.id
    And match response.customFieldId == 'updateId'
    And match response.configuredOptions.agencyCode == 'upd11'
    And match response.configuredOptions.customField == '54321'

  Scenario: Update user custom field mapping which not exist
    * print 'Prepare user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    When method GET
    Then status 200
    * def req = response

    * print 'Update user custom field mapping which not exist'
    Given path centralServer2.id + '/user-custom-field-mappings'
    And request req
    When method PUT
    Then status 404

  Scenario: Update user custom field mapping with invalid data
    * print 'Prepare user custom field mapping'
    Given path centralServer1.id + '/user-custom-field-mappings'
    When method GET
    Then status 200
    * def req = get response
    * set req.customFieldId = 'updateId'
    * set req.configuredOptions.agencyCode = "updateCode"
    * set req.configuredOptions.customField = "updateField"

    * print 'Update user custom field mapping with invalid data'
    Given path centralServer1.id + '/user-custom-field-mappings'
    And request req
    When method PUT
    Then status 409

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')