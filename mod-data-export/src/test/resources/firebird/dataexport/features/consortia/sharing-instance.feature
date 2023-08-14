Feature: Consortia Sharing Instances api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def instanceId1 = 'cf23adf0-61ba-4887-bf82-956c4aae2261'
    * def instanceTypeId1 = '8105bd44-e7bd-487e-a8f2-b804a361d92f'

  @Positive
  Scenario: POST a sharingInstance with status = 'COMPLETE' if no error

    # setup 'instance' in 'centralTenant' with 'source'='marc'
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceId1)', title: 'Instance with source = marc', source: 'marc', instanceTypeId: '#(instanceTypeId1)' }
    When method POST
    Then status 201


    # 1. POST sharingInstance (instance.status = 'marc') and verify status is 'COMPLETE'
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

    # 2. verify shared instance is created in target tenant with status = 'CONSORTIUM-MARC'
    * call read(login) universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    Given path 'inventory/instances', instanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == instanceId1
    And match response.title == 'Instance with source = marc'
    And match response.source == 'CONSORTIUM-MARC'
    And match response.instanceTypeId == instanceTypeId1

