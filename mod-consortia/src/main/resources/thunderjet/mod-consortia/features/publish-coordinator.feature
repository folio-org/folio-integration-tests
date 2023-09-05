Feature: Consortia publish coordinator tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 10, interval: 1000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def tagsPayload = { label: 'pc-request-test', description: 'consortia pc test tag' }
    * def tenants = [ '#(centralTenant)', '#(universityTenant)', '#(collegeTenant)' ]
    * def departmentId = 'c1a80e50-45a9-430c-a25e-e0adcc28ff67'
    * def departmentUrl = '/departments/' + departmentId
    * def name = 'Accounting'
    * def updateName = 'Management'
    * def code = 'ABC'
    * def updateCode = 'QWE'
    * def source = 'System'

  @Positive
  Scenario: Verify publish coordinator has persisted requests:
    # 1. Publish requests to endpoint /tags
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          url: '/tags',
          method: 'POST',
          tenants: '#(tenants)',
          payload: '#(tagsPayload)'
      }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request) == tagsPayload

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3
    And match JSON.parse(response.publicationResults[0].response) contains tagsPayload
    And match JSON.parse(response.publicationResults[0].response).metadata.createdByUserId == consortiaAdmin.id
    And match JSON.parse(response.publicationResults[1].response) contains tagsPayload
    And match JSON.parse(response.publicationResults[1].response).metadata.createdByUserId == consortiaAdmin.id
    And match JSON.parse(response.publicationResults[2].response) contains tagsPayload
    And match JSON.parse(response.publicationResults[2].response).metadata.createdByUserId == consortiaAdmin.id
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedStatusCodes = [201, 201, 201]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

  @Negative
  Scenario: Get error when publishing duplicate requests:
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          url: '/tags',
          method: 'POST',
          tenants: '#(tenants)',
          payload: '#(tagsPayload)'
      }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def failedPublicationId = response.id

    # 2. Retrieve publication status with errors. expected status ERROR
    Given path 'consortia', consortiumId, 'publications', failedPublicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200
    And match response.id == failedPublicationId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request) == tagsPayload
    * def actualTenants = get response.errors[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedErrorCodes = [400, 400, 400]
    * def actualErrorCodes = get response.errors[*].errorCode
    And match actualErrorCodes == '#(^^expectedErrorCodes)'

    # 3. Retrieve failed publication results
    Given path 'consortia', consortiumId, 'publications', failedPublicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3

    # Negative case for send request with path non-existing consortiumId
    Given path 'consortia', 'a051a9f0-3512-11ee-be56-0242ac120002', 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          url: '/tags',
          method: 'POST',
          tenants: '#(tenants)',
          payload: '#(tagsPayload)'
      }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [a051a9f0-3512-11ee-be56-0242ac120002] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

  @Positive
  Scenario: Sending GET request and check the results
    * def departmentsPayload = { id: '#(departmentId)', name: '#(name)', code: '#(code)', usageNumber: 0, source: '#(source)' }

    # 1. Publish requests to endpoint /departments
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        url: '/departments',
        method: 'POST',
        tenants: '#(tenants)',
        payload: '#(departmentsPayload)'
    }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request) == departmentsPayload

    # 3. Publish requests to endpoint /departments with GET request
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          "url": '/departments',
          "method": 'GET',
          "tenants": '#(tenants)'
      }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 4. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match response.request == 'null'

    # 5. Retrieve succeeded publication results and check previous created department are returned
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3
    And match JSON.parse(response.publicationResults[0].response).departments[0] contains departmentsPayload
    And match JSON.parse(response.publicationResults[0].response).departments[0].metadata.createdByUserId == consortiaAdmin.id
    And match JSON.parse(response.publicationResults[1].response).departments[0] contains departmentsPayload
    And match JSON.parse(response.publicationResults[1].response).departments[0].metadata.createdByUserId == consortiaAdmin.id
    And match JSON.parse(response.publicationResults[2].response).departments[0] contains departmentsPayload
    And match JSON.parse(response.publicationResults[2].response).departments[0].metadata.createdByUserId == consortiaAdmin.id
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedStatusCodes = [200, 200, 200]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

  @Positive
  Scenario: Sending PUT request to update and check results
    * def departmentsPayload = { id: '#(departmentId)', name: '#(updateName)', code: '#(updateCode)', usageNumber: 10, source: '#(source)' }

    # 1. Publish requests to endpoint /departments with PUT request to update department name and code
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          url: '#(departmentUrl)',
          method: "PUT",
          tenants: '#(tenants)',
          payload: '#(departmentsPayload)'
      }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request) == departmentsPayload

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedResponses = ['null', 'null', 'null']
    * def actualResponses = get response.publicationResults[*].response
    And match actualResponses == '#(^^expectedResponses)'
    * def expectedStatusCodes = [204, 204, 204]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

    # 4.1 Check from /departments endpoint that department has been created in 'centralTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id

    # 4.2 Check from /departments endpoint that department has been created in 'universityTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id

    # 4.3 Check from /departments endpoint that department has been created in 'collegeTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id

  @Positive
  Scenario: Sending DELETE request to delete tag
    # 1. Publish requests to endpoint /departments with DELETE request to delete tag which already exists
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          url: '#(departmentUrl)',
          method: 'DELETE',
          tenants: '#(tenants)',
      }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match response.request == 'null'

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedResponses = ['null', 'null', 'null']
    * def actualResponses = get response.publicationResults[*].response
    And match actualResponses == '#(^^expectedResponses)'
    * def expectedStatusCodes = [204, 204, 204]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

    # 4.1 Check from /departments endpoint that department has been deleted in 'centralTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 4.2 Check from /departments endpoint that department has been deleted in 'universityTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 4.3 Check from /departments endpoint that department has been deleted in 'collegeTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404

  @Negative
  Scenario: Verify publication status is Error if there is a failed publication request to tenants
    * def departmentId = '6b757b4c-202f-4187-a674-e16ab07f5e39'
    * def name = 'Finance'
    * def code = 'XYZ'
    * def source = 'System'
    * def departmentsPayload = { id: '#(departmentId)', name: '#(name)', code: '#(code)', usageNumber: 0, source: '#(source)' }

    # Setup:
    # We will create department object in 'universityTenant'
    Given path 'departments'
    And header x-okapi-tenant = universityTenant
    And request departmentsPayload
    When method POST
    Then status 201

    # 1. Publish requests to endpoint /departments
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        url: '/departments',
        method: 'POST',
        tenants: '#(tenants)',
        payload: '#(departmentsPayload)'
    }
    """
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.status == 'IN_PROGRESS'

    * def publicationId = response.id

    # 2. Retrieve error publication status. expected status ERROR
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200
    And match response.id == publicationId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request) == departmentsPayload

    And match response.errors[0].tenantId == universityTenant
    And match response.errors[0].errorCode == 400

    * def errorBodyForUniversity = response.errors[0]

    # 3. Retrieve publication results and verify response body for each tenant
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.totalRecords == 3

    # verify status codes and tenant names
    * def actualTenants = get response.publicationResults[*].tenantId
    And match actualTenants == '#(^^tenants)'
    * def expectedStatusCodes = [201, 201, 400]
    * def actualStatusCodes = get response.publicationResults[*].statusCode
    And match actualStatusCodes == '#(^^expectedStatusCodes)'

    # verify response body for each tenant
    * def funCentral = function(publicationResult) {return  publicationResult.tenantId == centralTenant }
    * def prCentral = karate.filter(response.publicationResults, funCentral)
    And match JSON.parse(prCentral[0].response) contains departmentsPayload
    And match JSON.parse(prCentral[0].response).metadata.createdByUserId == consortiaAdmin.id

    * def funUniversity = function(publicationResult) {return  publicationResult.tenantId == universityTenant }
    * def prUniversity = karate.filter(response.publicationResults, funUniversity)
    And match prUniversity[0].tenantId == errorBodyForUniversity.tenantId
    And match prUniversity[0].response == errorBodyForUniversity.errorMessage
    And match prUniversity[0].statusCode == errorBodyForUniversity.errorCode

    * def funCollege = function(publicationResult) {return  publicationResult.tenantId == collegeTenant }
    * def prCollege = karate.filter(response.publicationResults, funCollege)
    And match JSON.parse(prCollege[0].response) contains departmentsPayload
    And match JSON.parse(prCollege[0].response).metadata.createdByUserId == consortiaAdmin.id

    # 4.1 Check from /departments endpoint that department has been created in 'centralTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == name
    And match response.code == code
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id

    # 4.2 Check from /departments endpoint that department exists in 'universityTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == name
    And match response.code == code
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id

    # 4.3 Check from /departments endpoint that department has been created in 'collegeTenant'
    Given path 'departments', departmentId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == name
    And match response.code == code
    And match response.source == source
    And match response.metadata.createdByUserId == consortiaAdmin.id