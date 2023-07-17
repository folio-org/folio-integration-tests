Feature: Consortia Sharing Instances api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def instanceId1 = 'cf23adf0-61ba-4887-bf82-956c4aae2260'
    * def instanceId2 = 'cf23adf0-61ba-4887-bf82-956c4aae2261'
    * def instanceId3 = 'cf23adf0-61ba-4887-bf82-956c4aae2262'
    * def instanceId4 = 'cf23adf0-61ba-4887-bf82-956c4aae2263'
    * def instanceId5 = 'cf23adf0-61ba-4887-bf82-956c4aae2264'
    * def instanceId6 = 'cf23adf0-61ba-4887-bf82-956c4aae2265'
    * def instanceTypeId1 = '535e3160-763a-42f9-b0c0-d8ed7df6e2a1'
    * def instanceTypeId2 = '535e3160-763a-42f9-b0c0-d8ed7df6e2a2'

  @Negative
  Scenario: Attempt to POST a sharingInstance with invalid payload
    # cases for 400
    # attempt to create a sharingInstance when both source and target tenants are member tenants
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      sourceTenantId:  '#(universityTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 400
    And match response == { errors: [{message: "Both 'sourceTenantId' and 'targetTenantId' cannot be member tenants.", type: '-1', code: 'VALIDATION_ERROR'}] }

    # cases for 404
    # attempt to create a sharingInstance for non-existing consortium
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [111841e3-e6fb-4191-8fd8-5674a5107c33] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to create a sharingInstance with non-registered sourceTenantId
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      sourceTenantId:  'non-registered',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with id [non-registered] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to create a sharingInstance with non-registered targetTenantId
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  'non-registered'
    }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with id [non-registered] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # cases for 422
    # attempt to create a sharingInstance without an instanceIdentifier
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 422
    And match response == { errors: [{message: "'instanceIdentifier' validation failed. must not be null", type: '-1', code: 'sharingInstanceValidationError'}] }

    # attempt to create a sharingInstance without a sourceTenantId
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 422
    And match response == { errors: [{message: "'sourceTenantId' validation failed. must not be null", type: '-1', code: 'sharingInstanceValidationError'}] }

    # attempt to create a sharingInstance without a targetTenantId
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      sourceTenantId:  '#(centralTenant)'
    }
    """
    When method POST
    Then status 422
    And match response == { errors: [{message: "'targetTenantId' validation failed. must not be null", type: '-1', code: 'sharingInstanceValidationError'}] }

  @Positive
  Scenario: POST a sharingInstance with status = 'COMPLETE' if no error
    # setup 'instanceType' in 'centralTenant'
    Given path 'instance-types'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceTypeId1)', name: 'still image', code: 'sti', source: 'rdacarrier' }
    When method POST
    Then status 201

    # setup 'instanceType' in 'universityTenant'
    Given path 'instance-types'
    And header x-okapi-tenant = universityTenant
    And request { id: '#(instanceTypeId1)', name: 'still image', code: 'sti', source: 'rdacarrier' }
    When method POST
    Then status 201

    # setup 'instance' in 'centralTenant' with 'source'='folio'
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceId1)', title: 'Instance with source = folio', source: 'folio', instanceTypeId: '#(instanceTypeId1)' }
    When method POST
    Then status 201

    # setup 'instance' in 'centralTenant' with 'source'='marc'
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceId2)', title: 'Instance with source = marc', source: 'marc', instanceTypeId: '#(instanceTypeId1)' }
    When method POST
    Then status 201

    # 1.1. POST sharingInstance (instance.status = 'folio') and verify status is 'COMPLETE'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId1)',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId1
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant
    And match response.status == 'COMPLETE'

    # 1.2. verify shared instance is created in target tenant with status = 'CONSORTIUM-FOLIO'
    Given path 'inventory/instances', instanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == instanceId1
    And match response.title == 'Instance with source = folio'
    And match response.source == 'CONSORTIUM-FOLIO'
    And match response.instanceTypeId == instanceTypeId1

    # 2.1. POST sharingInstance (instance.status = 'marc') and verify status is 'COMPLETE'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId2)',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId2
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant
    And match response.status == 'COMPLETE'

    # 2.2. verify shared instance is created in target tenant with status = 'CONSORTIUM-MARC'
    Given path 'inventory/instances', instanceId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == instanceId2
    And match response.title == 'Instance with source = marc'
    And match response.source == 'CONSORTIUM-MARC'
    And match response.instanceTypeId == instanceTypeId1

  @Positive
  Scenario: POST a sharingInstance with status = 'IN_PROGRESS' if source tenant is not a central tenant
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId3)',
      sourceTenantId:  '#(universityTenant)',
      targetTenantId:  '#(centralTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId3
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    And match response.status == 'IN_PROGRESS'

  @Positive
  Scenario: POST a sharingInstance with status = 'ERROR' if there is an exception while shared instance creation
    # 1.1. verify there is no instance record with id = 'instanceId4' in source tenant
    Given path 'inventory/instances', instanceId4
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 1.2. POST sharing instance and verify status is 'ERROR' (GET 'inventory/instances' failed)
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId4)',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId4
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant
    And match response.status == 'ERROR'
    And match response.error contains 'Failed to get inventory instance'

    # setup 'instanceType' in 'centralTenant'
    Given path 'instance-types'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceTypeId2)', name: 'book', code: 'xyz', source: 'rdacarrier' }
    When method POST
    Then status 201

    # setup 'instance' in 'centralTenant'
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceId5)', title: 'Instance title', source: 'folio', instanceTypeId: '#(instanceTypeId2)' }
    When method POST
    Then status 201

    # 2.1. verify there is an instance record with id = 'instanceId5' and instanceTypeId = 'instanceTypeId2' in source tenant
    Given path 'inventory/instances', instanceId5
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == instanceId5
    And match response.instanceTypeId == instanceTypeId2

    # 2.2. verify there is no instance-type-id record with id = 'instanceTypeId2' in target tenant
    Given path 'instance-types', instanceTypeId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 2.3. POST sharing instance and verify status is 'ERROR' (POST 'inventory/instances' failed)
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId5)',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId5
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant
    And match response.status == 'ERROR'
    And match response.error contains 'Failed to post inventory instance'

  @Positive
  Scenario: GET a sharingInstance by actionId
    # POST new sharing instance
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      instanceIdentifier: '#(instanceId6)',
      sourceTenantId:  '#(universityTenant)',
      targetTenantId:  '#(centralTenant)'
    }
    """
    When method POST
    Then status 201
    * def createdInstance = response

    # GET newly created sharing instance by actionId
    Given path 'consortia', consortiumId, 'sharing/instances', createdInstance.id
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == createdInstance.id
    And match response.instanceIdentifier == createdInstance.instanceIdentifier
    And match response.sourceTenantId == createdInstance.sourceTenantId
    And match response.targetTenantId == createdInstance.targetTenantId
    And match response.status == createdInstance.status

  @Positive
  Scenario: GET a sharingInstance by (optional) query parameters ['instanceIdentifier', 'sourceTenantId', 'targetTenantId', 'source']
    # GET all sharing instances
    * def queryParams = { offset: 0, limit: 100 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def allSharingInstances = response.sharingInstances

    # 1. GET sharing instances by 'instanceIdentifier'
    * def queryParams = { instanceIdentifier: '#(instanceId1)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.instanceIdentifier == instanceId1 }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 2. GET sharing instances by 'sourceTenantId'
    * def queryParams = { sourceTenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.sourceTenantId == centralTenant }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 3. GET sharing instances by 'targetTenantId'
    * def queryParams = { targetTenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.targetTenantId == universityTenant }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 4. GET sharing instances by 'status'
    * def queryParams = { status: 'COMPLETE' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.status == 'COMPLETE' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 5. GET sharing instances by 'instanceIdentifier', 'sourceTenantId'
    * def queryParams = { instanceIdentifier: '#(instanceId2)', sourceTenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.instanceIdentifier == instanceId2 && sharingInstance.sourceTenantId == centralTenant}
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 6. GET sharing instances by 'instanceIdentifier', 'targetTenantId'
    * def queryParams = { instanceIdentifier: '#(instanceId3)', targetTenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.instanceIdentifier == instanceId3 && sharingInstance.targetTenantId == centralTenant}
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 7. GET sharing instances by 'instanceIdentifier', 'status'
    * def queryParams = { instanceIdentifier: '#(instanceId4)', status: 'ERROR' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.instanceIdentifier == instanceId4 && sharingInstance.status == 'ERROR'}
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 8. GET sharing instances by 'sourceTenantId', 'targetTenantId'
    * def queryParams = { sourceTenantId: '#(centralTenant)', targetTenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.sourceTenantId == centralTenant && sharingInstance.targetTenantId == universityTenant }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 9. GET sharing instances by 'sourceTenantId', 'status'
    * def queryParams = { sourceTenantId: '#(centralTenant)', status: 'COMPLETE' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.sourceTenantId == centralTenant && sharingInstance.status == 'COMPLETE' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 10. GET sharing instances by 'targetTenantId', 'status'
    * def queryParams = { targetTenantId: '#(universityTenant)', status: 'ERROR' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(sharingInstance) {return sharingInstance.targetTenantId == universityTenant && sharingInstance.status == 'ERROR' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 11. GET sharing instances by 'instanceIdentifier', 'sourceTenantId', 'targetTenantId'
    * def queryParams = { instanceIdentifier: '#(instanceId2)', sourceTenantId: '#(centralTenant)', targetTenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(e) {return e.instanceIdentifier == instanceId2 && e.sourceTenantId == centralTenant && e.targetTenantId == universityTenant }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 12. GET sharing instances by 'instanceIdentifier', 'sourceTenantId', 'status'
    * def queryParams = { instanceIdentifier: '#(instanceId3)', sourceTenantId: '#(universityTenant)', status: 'IN_PROGRESS' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(e) {return e.instanceIdentifier == instanceId3 && e.sourceTenantId == universityTenant && e.status == 'IN_PROGRESS' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 13. GET sharing instances by 'instanceIdentifier', 'targetTenantId', 'status'
    * def queryParams = { instanceIdentifier: '#(instanceId6)', targetTenantId: '#(centralTenant)', status: 'IN_PROGRESS' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(e) {return e.instanceIdentifier == instanceId6 && e.targetTenantId == centralTenant && e.status == 'IN_PROGRESS' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 14. GET sharing instances by 'sourceTenantId', 'targetTenantId', 'status'
    * def queryParams = { sourceTenantId: '#(universityTenant)', targetTenantId: '#(centralTenant)', status: 'IN_PROGRESS' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(e) {return e.sourceTenantId == universityTenant && e.targetTenantId == centralTenant && e.status == 'IN_PROGRESS' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult

    # 15. GET sharing instances by 'instanceIdentifier', 'sourceTenantId', 'targetTenantId', 'status'
    * def queryParams = { instanceIdentifier: '#(instanceId2)', sourceTenantId: '#(centralTenant)', targetTenantId: '#(universityTenant)', status: 'COMPLETE' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And header x-okapi-tenant = centralTenant
    And params query = queryParams
    When method GET
    Then status 200
    * def actualResult = response.sharingInstances

    * def fun = function(e) {return e.instanceIdentifier == instanceId2 && e.sourceTenantId == centralTenant && e.targetTenantId == universityTenant && e.status == 'COMPLETE' }
    * def expectedResult = karate.filter(allSharingInstances, fun)

    * match karate.sizeOf(actualResult) == karate.sizeOf(expectedResult)
    * match actualResult contains deep expectedResult