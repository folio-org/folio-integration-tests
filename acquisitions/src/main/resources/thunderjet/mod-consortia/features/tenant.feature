Feature: Tenant object in mod-consortia api tests

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

  Scenario: Create, Read, Update a tenant

    # Create a tenant
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    And request { "id": "1234", "code": "ABC", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method POST
    Then status 201
    And match response == {"id":"1234","code":"ABC","name":"test"}

    # Read tenants by consortiumId
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    When method GET
    Then status 200
    And match response == {"tenants":[{"id":"1234","code":"ABC","name":"test"}],"totalRecords":1}

    # Update a tenant with a different consortiumId
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    And request { "id": "1234", "code": "ABC", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c33" }
    When method PUT
    Then status 200
    And match response == {"id":"1234","code":"ABC","name":"test"}

    # Update a tenant with different name
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    And request { "id": "1234", "code": "ABC", "name": "test1", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method PUT
    Then status 200
    And match response == {"id":"1234","code":"ABC","name":"test1"}

    # Update a tenant with different code
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    And request { "id": "1234", "code": "ABD", "name": "test1", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method PUT
    Then status 200
    And match response == {"id":"1234","code":"ABD","name":"test1"}

  Scenario: Error cases (We already have a tenant {id: 1234, code: ABD, name: test1} in the database)

    # Get Error when trying to save with a existed name
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    And request { "id": "12345", "code": "ABE", "name": "test1", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method POST
    Then status 409
    And match response == {"errors":[{"message":"ERROR: duplicate key value violates unique constraint \"tenant_name_key\"\n  Detail: Key (name)=(test1) already exists.","type":"-1","code":"VALIDATION_ERROR"}]}

    # Get Error when trying to save with a existed code
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    And request { "id": "12345", "code": "ABD", "name": "test-new", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method POST
    Then status 409
    And match response == {"errors":[{"message":"ERROR: duplicate key value violates unique constraint \"tenant_code_key\"\n  Detail: Key (code)=(ABD) already exists.","type":"-1","code":"VALIDATION_ERROR"}]}

    # Get Error when trying to update a tenant with a different id
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    And request { "id": "12345", "code": "ABC", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method PUT
    Then status 400
    And match response == {"errors":[{"message":"Request body tenantId and path param tenantId should be identical","type":"-1","code":"VALIDATION_ERROR"}]}

    # Get Error when trying to save with a text with more than 150 characters and a code with more than 3 characters
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    And request { "id": "12345", "code": "TTTT", "name": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl." }
    When method POST
    Then status 422
    And match response.errors[*].message contains ['\'code\' validation failed. Invalid Code length: Must be of 3 alphanumeric characters', '\'name\' validation failed. Invalid Name: Must be of 2 - 150 characters']

  Scenario: Delete a tenant
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    When method DELETE
    Then status 204
