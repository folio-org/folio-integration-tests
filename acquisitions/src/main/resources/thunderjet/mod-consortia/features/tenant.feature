Feature: Tenant object in mod-consortia api tests

  Background:
    * url baseUrl
    * callonce login universityUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

  Scenario: Create, Read, Update a tenant for positive cases

    # create a tenant
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 201
    And match response == { id: '1234', code: 'ABC', "name": 'test' }

    # get tenants by consortiumId
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '1234', code: 'ABC', name: 'test' }], totalRecords: 1 }

    # update a tenant with a different consortiumId
    Given path 'consortia', consortiumId, 'tenants', '1234'
    And request { id: '1234', code: 'ABC', name: 'test', consortiumId: '111841e3-e6fb-4191-8fd8-5674a5107c33' }
    When method PUT
    Then status 200
    And match response == { id : '1234', code:'ABC', name: 'test' }

    # update a tenant with different name
    Given path 'consortia', consortiumId, 'tenants', '1234'
    And request { id: '1234', code: 'ABC', name: 'test1', consortiumId: '#(consortiumId)' }
    When method PUT
    Then status 200
    And match response == { id: '1234', code: 'ABC', name: 'test1' }

    # update a tenant with different code
    Given path 'consortia', consortiumId, 'tenants', '1234'
    And request { id: '1234', code: 'ABD', name: 'test1', consortiumId: '#(consortiumId)' }
    When method PUT
    Then status 200
    And match response == { id: '1234', code: 'ABD', name: 'test1' }

  Scenario: Create, Read, Update a tenant for negative cases (We already have a tenant {id: '1234', code: 'ABD', name: 'test1' })
    * def nonExistingConsortiumId = 'd9acad2f-2aac-4b48-9097-e6ab85906b25'

    # POST:
    # cases for 400
    # attempt to create a tenant without an id
    Given path 'consortia', consortiumId, 'tenants'
    And request { code: 'ABC', name: 'test', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 400

    # attempt to create a tenant without a code
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', name: 'test', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 400

    # attempt to create a tenant without a name
    Given path 'consortia', consortiumId, 'tenants'
    And request  { id: '1234', code: 'ABC', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 400

    # cases for 404
    # attempt to create a tenant for non-existing consortia
    Given path 'consortia', nonExistingConsortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # cases for 409
    # attempt to create a tenant with an existing id
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABE', name: 'test1', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'Object with id [1234] is already presented in the system', type : '-1', code: 'DUPLICATE_ERROR' }] }

    # Get Error when trying to save with a existed code
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '12345', code: 'ABD', name: 'test-new', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'ERROR: duplicate key value violates unique constraint \"tenant_code_key\"\n  Detail: Key (code)=(ABD) already exists.', type : '-1', code: 'VALIDATION_ERROR' }] }

    # attempt to create a tenant with an existing name
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '12345', code: 'ABE', name: 'test1', consortiumId: '#(consortiumId)' }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'ERROR: duplicate key value violates unique constraint \"tenant_name_key\"\n  Detail: Key (name)=(test1) already exists.', type : '-1', code: 'VALIDATION_ERROR' }] }

    # cases for 409
    # attempt to create a tenant with a name that has length more than 150 characters and a code with more than 3 characters
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '12345', code: 'TTTT', name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl.' }
    When method POST
    Then status 422
    And match response.errors[*].message contains ['\'code\' validation failed. Invalid Code length: Must be of 3 alphanumeric characters', '\'name\' validation failed. Invalid Name: Must be of 2 - 150 characters']

    # PUT:
    # cases for 400
    # attempt to update a tenant with a different id
    Given path 'consortia', consortiumId, 'tenants', '1234'
    And request { id: '12345', code: 'ABD', name: 'test', consortiumId: '#(consortiumId)' }
    When method PUT
    Then status 400
    And match response == { errors: [{ message: 'Request body tenantId and path param tenantId should be identical', type: '-1', code: 'VALIDATION_ERROR' }] }

    # cases for 404
    # attempt to update a tenant for non-existing consortia
    Given path 'consortia', nonExistingConsortiumId, 'tenants', '1234'
    And request { id: '12345', code: 'ABD', name: 'test', consortiumId: '#(consortiumId)' }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to update non-existing tenant
    Given path 'consortia', consortiumId, 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', consortiumId: '#(consortiumId)' }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with id [12345] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

  Scenario: Delete a tenant
    Given path 'consortia', consortiumId, 'tenants', '1234'
    When method DELETE
    Then status 204
