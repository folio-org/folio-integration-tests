Feature: Consortia Sharing Settings api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * configure retry = { count: 10, interval: 1000 }
    * def settingId = 'cf23adf0-61ba-4887-bf87-956c4aae2277'
    * def name = 'History'
    * def code = 'ABD'
    * def source = 'System'
    * def sourceConsortium = 'consortium'
    * def sourceLocal = 'local'
    * def updateName = 'Philosophy'
    * def updateCode = 'QWS'

  @Negative
  Scenario: Attempt to POST and DELETE a sharingSetting with different incorrect ways (invalid request body, non-existing path id...)
    # Case for 404
    # attempt to create a sharingSetting for non-existing consortium
    Given path 'consortia', 'a051a9f0-3512-11ee-be56-0242ac120002', 'sharing/settings'
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
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [a051a9f0-3512-11ee-be56-0242ac120002] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # Cases for 400
    # attempt to create a sharingSetting with request which has mismatch settingId with id in payload
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '96533f13-8904-47b6-961d-1626f5d5cdd0',
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
          id: '#(settingId)',
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
          id: '#(settingId)',
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

    # attempt to delete a non-existing setting
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
        id: '#(settingId)',
        name: '#(name)'
      }
    }
    """
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with settingId [cf23adf0-61ba-4887-bf87-956c4aae2277] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to delete a setting with mismatch id in path and body
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
    Then status 400
    And match response == { errors: [{message: 'Payload must not be null', type: '-1', code: 'VALIDATION_ERROR'}] }

    # attempt to delete a setting without payload
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '96533f13-8904-47b6-961d-1626f5d5cdd0',
      url: '/departments',
      payload: {
          id: '#(settingId)',
          name: '#(name)'
      }
    }
    """
    When method DELETE
    Then status 400
    And match response == { errors: [{message: 'Mismatch id in path to settingId in request body', type: '-1', code: 'VALIDATION_ERROR'}] }

  @Positive
  Scenario: POST request to start sharing setting and and check request details
    # 1. Create sharing setting ( to be shared for all tenants)
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
    And match response.createSettingsPCId == '#uuid'

    * def createSettingsPCId = response.createSettingsPCId

    # 2. Check details from publication request by createSettingsPCId
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == createSettingsPCId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).name == name
    And match JSON.parse(response.request).code == code
    And match JSON.parse(response.request).source == '#(sourceConsortium)'

    # 3.1 Check from /departments endpoint that setting has been created in 'centralTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == '#(sourceConsortium)'

    # 3.2 Check from /departments endpoint that setting has been created in 'universityTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == '#(sourceConsortium)'

    # 3.3 Check from /departments endpoint that setting has been created in 'collegeTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(name)'
    And match response.code == '#(code)'
    And match response.source == '#(sourceConsortium)'

  @Positive
  Scenario: POST request to UPDATE existing sharing setting and check request details
    # 1. Update sharing setting for all tenants
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
    And match response.updateSettingsPCId == '#uuid'

    * def updateSettingsPCId = response.updateSettingsPCId

    # 2. Check details from publication request by using response updateSettingsPCId
    Given path 'consortia', consortiumId, 'publications', updateSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == updateSettingsPCId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).name == updateName
    And match JSON.parse(response.request).code == updateCode
    And match JSON.parse(response.request).source == '#(sourceConsortium)'

    # 3.1 Check from /departments endpoint that setting has been updated in 'centralTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == '#(sourceConsortium)'
    And match response.metadata.createdDate != response.metadata.updatedDate

    # 3.2 Check from /departments endpoint that setting has been updated in 'universityTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == '#(sourceConsortium)'
    And match response.metadata.createdDate != response.metadata.updatedDate

    # 3.3 Check from /departments endpoint that setting has been updated in 'collegeTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.name == '#(updateName)'
    And match response.code == '#(updateCode)'
    And match response.source == '#(sourceConsortium)'
    And match response.metadata.createdDate != response.metadata.updatedDate

  @Positive
  Scenario: DELETE request to delete existing shared settings and check request details
    # 1. Delete sharing setting for all tenants
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
        id: '#(settingId)'
      }
    }
    """
    When method DELETE
    Then status 200
    And match response.pcId == '#uuid'

    * def pcId = response.pcId

    # 2. Check details from publication request by using response pcId ('IN_PROGRESS' status should be 'COMPLETE')
    Given path 'consortia', consortiumId, 'publications', pcId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == pcId
    And match response.dateTime == '#notnull'
    And match response.request == 'null'

    # 3.1 Check from /departments endpoint that setting has been deleted in 'centralTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 3.2 Check from /departments endpoint that setting has been deleted in 'universityTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 3.3 Check from /departments endpoint that setting has been deleted in 'collegeTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404

  @Negative
  Scenario: Verify publication status to Error, in case of publication request fails for one of three tenants
    * def settingId = '6b757b4c-212f-4771-a674-e11ab07f7a71'
    * def name = 'Biology'
    * def code = 'UVW'
    * def source = 'System'
    * def settingsPayload = { id: '#(settingId)', name: '#(name)', code: '#(code)', usageNumber: 0, source: '#(source)' }

    # Setup:
    # We will create department object in 'universityTenant'
    Given path 'departments'
    And header x-okapi-tenant = universityTenant
    And request settingsPayload
    When method POST
    Then status 201

    # 1. Start sharing settings
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: '#(settingsPayload)'
    }
    """
    When method POST
    Then status 201
    And match response.createSettingsPCId == '#uuid'

    * def createSettingsPCId = response.createSettingsPCId

    # 2. Check details from publication request by createSettingsPCId
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200
    And match response.id == createSettingsPCId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).name == name
    And match JSON.parse(response.request).code == code
    And match JSON.parse(response.request).source == sourceConsortium

    And match response.errors[0].tenantId == universityTenant
    And match response.errors[0].errorCode == 400

    * def errorBodyForUniversity = response.errors[0]

    # 3. Retrieve publication results and verify response body for each tenant
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3

    # verify status codes and tenant names
    * def expectedTenants = [ '#(centralTenant)', '#(universityTenant)', '#(collegeTenant)' ]
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^expectedTenants)'
    * def expectedStatusCodes = [201, 201, 400]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

    # verify response body for each tenant
    * def funCentral = function(publicationResult) {return  publicationResult.tenantId == centralTenant }
    * def prCentral = karate.filter(response.publicationResults, funCentral)
    And match JSON.parse(prCentral[0].response).id == settingsPayload.id
    And match JSON.parse(prCentral[0].response).name == settingsPayload.name
    And match JSON.parse(prCentral[0].response).code == settingsPayload.code
    And match JSON.parse(prCentral[0].response).source == sourceConsortium

    * def funUniversity = function(publicationResult) {return  publicationResult.tenantId == universityTenant }
    * def prUniversity = karate.filter(response.publicationResults, funUniversity)
    And match prUniversity[0].tenantId == errorBodyForUniversity.tenantId
    And match prUniversity[0].response == errorBodyForUniversity.errorMessage
    And match prUniversity[0].statusCode == errorBodyForUniversity.errorCode

    * def funCollege = function(publicationResult) {return  publicationResult.tenantId == collegeTenant }
    * def prCollege = karate.filter(response.publicationResults, funCollege)
    And match JSON.parse(prCollege[0].response).id == settingsPayload.id
    And match JSON.parse(prCollege[0].response).name == settingsPayload.name
    And match JSON.parse(prCollege[0].response).code == settingsPayload.code
    And match JSON.parse(prCollege[0].response).source == sourceConsortium

    # 4.1 Check from /departments endpoint that department has been created in 'centralTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == settingId
    And match response.name == name
    And match response.code == code
    And match response.source == sourceConsortium

    # 4.2 Check from /departments endpoint that department exists in 'universityTenant'
    # source =/= sourceConsortium as this is not a shared one, but pre-existing one
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == settingId
    And match response.name == name
    And match response.code == code
    And match response.source == source

    # 4.3 Check from /departments endpoint that department has been created in 'collegeTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == settingId
    And match response.name == name
    And match response.code == code
    And match response.source == sourceConsortium

  @Positive
  Scenario: Verify changing source consortium to local after any fails in delete request
    * def settingId = '6b757b4c-212f-4771-a674-e11ab07f7a71'
    * def group = 'Space'
    * def desc = 'Space exploration'
    * def payloadForCreateRequest = { id:'#(settingId)', group: '#(group)', desc: '#(desc)', expirationOffsetInDays: '' }

    # 1. Start sharing settings to create user group
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/groups',
      payload: {
        group: '#(group)'
      }
    }
    """
    When method POST
    Then status 201
    And match response.createSettingsPCId == '#uuid'

    * def createSettingsPCId = response.createSettingsPCId

    # 2. Check the request to verify it complete
    Given path 'consortia', consortiumId, 'publications', updateSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == createSettingsPCId
    And match response.dateTime == '#notnull'
    And match response.status == 'COMPLETE'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).group == group
    And match JSON.parse(response.request).desc == desc
    # check its source and we will verify its source changes in further steps currently its source - consortium
    And match JSON.parse(response.request).source == '#(sourceConsortium)'

    # 3. Create a user with group, which we created above, in order to create delete request failed situation.
    Given path 'users'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "FF",
        "preferredContactTypeId": "002",
        "lastName": "LL",
        "email": "AA@gamil.com"
      },
      "username": "AA",
      "type": "patron",
      "patronGroup": "#(settingId)",
      "expirationDate": "2024-09-19T23:59:59Z",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204de",
      "departments": []
    }
    """

    # 4. We send delete sharing setting request to delete settings across all tenants.
    #    One of them should fail because groups is used by user in central tenant
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/departments',
      payload: {
        id: '#(settingId)'
      }
    }
    """
    When method DELETE
    Then status 200
    And match response.pcId == '#uuid'

    * def pcId = response.pcId

    # 5. Check details from publication request by using response pcId ('IN_PROGRESS' status should be 'COMPLETE')
    Given path 'consortia', consortiumId, 'publications', pcId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == pcId
    And match response.dateTime == '#notnull'
    And match response.request == 'null'

    # 6.1 Check from /groups endpoint that group has not been deleted in 'centralTenant' because it is used by user
    Given path 'departments', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 201
    And match response.id == settingId
    And match response.group == group
    And match response.desc == desc
    # its source should be source after delete request failed
    And match response.source == sourceLocal

    # 6.2 Check from /groups endpoint that group has been deleted in 'universityTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 6.3 Check from /groups endpoint that group has been deleted in 'collegeTenant'
    Given path 'departments', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404