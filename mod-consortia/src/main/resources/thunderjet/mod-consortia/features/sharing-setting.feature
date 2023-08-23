Feature: Consortia Sharing Settings api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }
    * def settingId = 'cf23adf0-61ba-4887-bf82-956c4aae2260'
    * def wrongConsortiumId = 'a051a9f0-3512-11ee-be56-0242ac120002'
    * def name = 'Accounting'
    * def updateName = 'Management'
    * def code = 'XXX'
    * def updateCode = 'YYY'
    * def source = 'System'

  # Currently, we have three tenants 1) centralTenant, 2) universityTenant, 3) collegeTenant. 
  # We will test these below cases:
  #   0. All Negative cases  
  #   1. Share new settings for 3 tenants - POST method for publication request
  #   2. Update existing settings for 3 tenants - PUT method for publication request
  #   3. Delete existing settings for 3 tenants - DELETE method for publication request
  #   4. The case of error occurred one of three tenants while sharing settings

  @Negative
  Scenario: Attempt to POST a sharingSetting with invalid request body or non-existing path id for 3 tenants
    # Cases for 404
    # attempt to create a sharingSetting for non-existing consortium
    Given path 'consortia', wrongConsortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      "settingId": "#(settingId)",
      "url": "/departments",
      "payload": {
          "id": "#(settingId)",
          "name": "#(name)",
          "code": "#(code)",
          "usageNumber": 10,
          "source": "#(source)"
      }
    }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [a051a9f0-3512-11ee-be56-0242ac120002] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # 1. Delete sharing setting for both centralTenant and universityTenant
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
    }
    """
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with settingId [cf23adf0-61ba-4887-bf82-956c4aae2260] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # Cases for 400
    # attempt to create a sharingSetting with request which has mismatch settingId with id in payload
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
          id: '96533f13-8904-47b6-961d-1626f5d5cdd0',
          name: '#(name)',
          code: '#(code)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 400
    And match response == { errors: [{message: 'Mismatch id in payload with settingId', type: '-1', code: 'VALIDATION_ERROR'}] }

    # Cases for 422
    # attempt to create a sharingSetting without an settingId
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      url: '/departments',
      payload: {
          id: '96533f13-8904-47b6-961d-1626f5d5cdd0',
          name: '#(name)',
          code: '#(code)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 422
    And match response == { errors: [{message: "'settingId' validation failed. must not be null", type: '-1', code: 'sharingSettingRequestValidationError'}] }

    # attempt to create a sharingInstance without url
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      payload: {
          id: '96533f13-8904-47b6-961d-1626f5d5cdd0',
          name: '#(name)',
          code: '#(code)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 422
    And match response == { errors: [{message: "'url' validation failed. must not be null", type: '-1', code: 'sharingSettingRequestValidationError'}] }

  @Positive
  Scenario: POST request to start sharing setting and and check request details for 3 tenants
    # 1. Create sharing setting for 3 tenants: centralTenant, universityTenant and collegeTenant
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
          id: '#(settingId)',
          name: '#(name)',
          code: '#(code)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 201
    And match response == {createSettingsPCId: '#notnull'}
    * def createSettingsPCId = response.createSettingsPCId

    # 2. Check details from publication request by using response createSettingsPCId
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.status == 'COMPLETE'
    And print response.request

    # 3.1. Check created object from database for CENTRAL TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == 'consortium'

    # 3.2. Check created object from database for UNIVERSITY TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == 'consortium'
    
    # 3.3. Check created object from database for COLLEGE TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == 'consortium'

  @Positive
  Scenario: POST request to UPDATE existing sharing setting and check request details for 3 tenants
    # 1. Update sharing setting for 3 tenants: centralTenant, universityTenant and collegeTenant
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
          id: '#(settingId)',
          name: '#(updateName)',
          code: '#(updateCode)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 201
    And match response == {updateSettingsPCId: '#notnull'}
    * def updateSettingsPCId = response.updateSettingsPCId

    # 2. Check details from publication request by using response updateSettingsPCId
    Given path 'consortia', consortiumId, 'publications', updateSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.status == 'COMPLETE'
    And print response.request

    # 3.1. Check updated object from database for CENTRAL TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == 'consortium'

    # 3.2. Check updated object from database for UNIVERSITY TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == 'consortium'

    # 3.3. Check updated object from database for COLLEGE TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == 'consortium'

  @Positive
  Scenario: DELETE request to delete existing shared settings and check request details of 3 tenants
    # 1. Delete sharing setting for 3 tenants: centralTenant, universityTenant and collegeTenant
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
    }
    """
    When method DELETE
    Then status 200
    And match response == {pcId: '#notnull'}
    * def pcId = response.pcId

    # 2. Check details from publication request by using response pc ('IN_PROGRESS' status should be 'COMPLETE')
    Given path 'consortia', consortiumId, 'publications', pcId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.status == 'COMPLETE'

    # 3.1. Check removed object from database for CENTRAL TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 3.2. Check removed object from database for UNIVERSITY TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 3.3. Check removed object from database for COLLEGE TENANT by using request id(#settingId) and url(#/departments)
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404

  @Negative
  Scenario: Verify publication status to Error, in case of publication request fails for one of three tenants
    # In order to create this situation, we create a department object in universityTenant,
    # and then, it throw 422 exception (because of having same name, code), when we save object for this tenant.
    # As a result, one of them will fail and others will completed. Last status of publication request should be ERROR

    # 1. We will create department object in second tenant
    Given path 'departments'
    And header x-okapi-tenant = universityTenant
    And request
    """
    {
        "id": "#(settingId)",
        "name": "#(name)",
        "code": "#(code)",
        "usageNumber": 10,
        "source": "#(source)"
    }
    """
    When method POST
    Then status 201

    # 2. Create sharing setting for 3 tenants: centralTenant, universityTenant and collegeTenant
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
          id: '#(settingId)',
          name: '#(name)',
          code: '#(code)',
          usageNumber: 5,
          source: '#(source)'
      }
    }
    """
    When method POST
    Then status 201
    And match response == {createSettingsPCId: '#notnull'}
    * def createSettingsPCId = response.createSettingsPCId

    # 3. Check details from publication request by using response createSettingsPCId
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200
    And match response.status == 'ERROR'
    And print response.request

    # 4. Check created object from database for central tenant by using request id(#settingId) and url(#/departments)
    # Central and college tenant sharing settings should not be affected by error of university tenant tenant
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == 'consortium'

    # 5. Check results of publication request which should be 422 error code
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def universityResponse = response.publicationResults[1]
    * match universityResponse.statusCode == 422
