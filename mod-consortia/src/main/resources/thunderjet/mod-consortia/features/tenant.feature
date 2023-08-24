Feature: Tenant object in mod-consortia api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure retry = { count: 20, interval: 1000 }

  @Negative
  Scenario: Attempt to POST a tenant to the consortium
    # cases for 400
    # attempt to create a tenant for consortia without 'adminUserId' query param ('isCentral' = false)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test', isCentral: false }
    When method POST
    Then status 400
    And match response == { errors: [{message: "Required request parameter 'adminUserId' for method parameter type UUID is not present", type: '-1', code: 'VALIDATION_ERROR'}] }

    # cases for 404
    # attempt to create a tenant for consortia before 'central' tenant has been created
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '1234', code: 'ABC', name: 'test', isCentral: false }
    When method POST
    Then status 404
    And match response == { errors: [{message: 'A central tenant is not found. The central tenant must be created', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to create a tenant for non-existing consortium
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '1234', code: 'ABC', name: 'test', isCentral: true }
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [111841e3-e6fb-4191-8fd8-5674a5107c33] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # cases for 422
    # attempt to create a tenant without an id
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { code: 'ABC', name: 'test', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'id' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without a code
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '1234', name: 'test', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'code' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without a name
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '1234', code: 'ABC', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'name' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without isCentral
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '1234', code: 'ABC', name: 'test' }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'isCentral' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant with a name that has length more than 150 characters and a code with more than 3 characters
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request
    """
    {
      id: '12345',
      code: 'TTTT',
      name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl.',
      isCentral: true
    }
    """
    When method POST
    Then status 422
    And match response.errors[*].message contains ['\'name\' validation failed. size must be between 2 and 150','\'code\' validation failed. size must be between 3 and 3']

  @Positive
  Scenario: Do POST a tenant, GET list of tenant(s) (isCentral = true), check value of 'setupStatus'
    # get tenants of the consortium (before posting any tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # post 'centralTenant' (isCentral = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }

    # get tenant details for 'centralTenant'
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until
    When method GET
    Then status 200
    And match response.id == centralTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (after posting 'centralTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }], totalRecords: 1 }

    # get tenant details for 'centralTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == centralTenant
    And match response.code == 'ABC'
    And match response.name == 'Central tenants name'
    And match response.isCentral == true

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

  @Negative
  # At this point we have one record in consortium = { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
  Scenario: Attempt to POST a second tenant with existing 'isCentral' = true, 'id', 'name', 'code'
    # cases for 409
    # attempt to create a second central tenant ('isCentral' = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'XYZ', name: 'Test tenants name', isCentral: true }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'Object with isCentral [true] is already presented in the system', type : '-1', code: 'DUPLICATE_ERROR' }] }

    # attempt to create a tenant with an existing id
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(centralTenant)', code: 'ABE', name: 'test1', isCentral: false }
    When method POST
    Then status 409
    And match response.errors[0].message == 'Object with id [' + centralTenant +'] is already presented in the system'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'DUPLICATE_ERROR'

    # attempt to create a tenant with an existing code
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: 'non-existing-tenant', code: 'ABC', name: 'test1', isCentral: false }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'Object with code [ABC] is already presented in the system', type : '-1', code: 'DUPLICATE_ERROR' }] }

    # attempt to create a tenant with an existing name
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: 'non-existing-tenant', code: 'ABE', name: 'Central tenants name', isCentral: false }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'Object with name [Central tenants name] is already presented in the system', type : '-1', code: 'DUPLICATE_ERROR' }] }

  @Negative
  # At this point we have one record in consortium = { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
  Scenario: Attempt to PUT existing tenant with invalid payload
    # cases for 400
    # attempt to update a tenant with a different id
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: true}
    When method PUT
    Then status 400
    And match response == { errors: [{ message: 'Request body tenantId and path param tenantId should be identical', type: '-1', code: 'VALIDATION_ERROR' }] }

    # cases for 404
    # attempt to update the tenant for non-existing consortium
    Given path 'consortia', 'd9acad2f-2aac-4b48-9097-e6ab85906b25', 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABD', name: 'test', isCentral: true }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to update non-existing tenant
    Given path 'consortia', consortiumId, 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: true }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with id [12345] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # cases for 422
    # attempt to update the tenant without an id
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { code: 'ABC', name: 'test', isCentral: true }
    When method PUT
    Then status 422
    And match response == { errors: [{ message: "'id' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to update the tenant without a code
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', name: 'test', isCentral: true }
    When method PUT
    Then status 422
    And match response == { errors: [{ message: "'code' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to update the tenant without a name
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABC', isCentral: true }
    When method PUT
    Then status 422
    And match response == { errors: [{ message: "'name' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to update the tenant without isCentral
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABC', name: 'test' }
    When method PUT
    Then status 422
    And match response == { errors: [{ message: "'isCentral' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to update the tenant with a name that has length more than 150 characters and a code with more than 3 characters
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And param adminUserId = consortiaAdmin.id
    And request
    """
    {
      id: '#(centralTenant)',
      code: 'TTTT',
      name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl.',
      isCentral: true
    }
    """
    When method PUT
    Then status 422
    And match response.errors[*].message contains ['\'code\' validation failed. size must be between 3 and 3','\'name\' validation failed. size must be between 2 and 150']

  @Positive
  Scenario: Do PUT the tenant
    # update the tenants' code
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name', isCentral: true}
    When method PUT
    Then status 200
    And match response == { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name', isCentral: true }

    # update the tenants' name
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true}
    When method PUT
    Then status 200
    And match response == { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true }

  @Negative
  Scenario: Attempt to GET, DELETE non-existing tenant, with non-existing consortiumId
    # cases for 404
    # attempt to get non-existing tenant in the consortium
    Given path 'consortia', consortiumId, 'tenants', '1234'
    When method GET
    Then status 404
    And match response == { errors: [{message: 'Object with id [1234] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to get tenant by non-existing consortiumId
    Given path 'consortia', 'd9acad2f-2aac-4b48-9097-e6ab85906b25', 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false }
    When method GET
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to delete non-existing tenant in the consortium
    Given path 'consortia', consortiumId, 'tenants', '1234'
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with id [1234] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to delete tenant by non-existing consortiumId
    Given path 'consortia', 'd9acad2f-2aac-4b48-9097-e6ab85906b25', 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false }
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

  @Positive
  # This is for registering 'universityTenant'
  Scenario: Do POST a non-central tenant (isCentral = false), GET list of tenant(s), check value of 'setupStatus'
    # post 'universityTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }

    # get tenant details for 'universityTenant'
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    And retry until
    When method GET
    Then status 200
    And match response.id == universityTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (should return 'centralTenant' and 'universityTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    * match response.tenants contains deep { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true }
    * match response.tenants contains deep { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }

    # get tenant details for 'universityTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == universityTenant
    And match response.code == 'XYZ'
    And match response.name == 'University tenants name'
    And match response.isCentral == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'university_mod_users.user_tenant'
    * call read(login) universityUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant

  @Positive
  # This is for registering 'collegeTenant'
  Scenario: Do POST a non-central tenant (isCentral = false), GET list of tenant(s), check value of 'setupStatus'
    # post 'collegeTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(collegeTenant)', code: 'QWE', name: 'College tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(collegeTenant)', code: 'QWE', name: 'College tenants name', isCentral: false }

    # get tenant details for 'collegeTenant'
    Given path 'consortia', consortiumId, 'tenants', collegeTenant
    And retry until
    When method GET
    Then status 200
    And match response.id == collegeTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (should return 'centralTenant' and 'universityTenant' and 'collegeTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 3
    * match response.tenants contains deep { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true }
    * match response.tenants contains deep { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
    * match response.tenants contains deep { id: '#(collegeTenant)', code: 'QWE', name: 'College tenants name', isCentral: false }

    # get tenant details for 'collegeTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', collegeTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == collegeTenant
    And match response.code == 'QWE'
    And match response.name == 'College tenants name'
    And match response.isCentral == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'university_mod_users.user_tenant'
    * call read(login) collegeUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == collegeTenant