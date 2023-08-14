Feature: Consortia Sharing Instances api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def instanceId1 = 'cf23adf0-61ba-4887-bf82-956c4aae2261'
    * def instanceTypeId1 = '8105bd44-e7bd-487e-a8f2-b804a361d92f'

  @Positive
  Scenario: POST a sharingInstance with status = 'COMPLETE' if no error
    * def jobExecutionId = '67dfac11-1caf-4470-9ad1-d533f6360bc8'
    * def recordId = '11dfac11-1caf-4470-9ad1-d533f6360bc8'
    * def matchedId = 'c9db5b04-e1d4-11e8-9f32-f2801f1b9fd1'

    # setup 'instance' in 'centralTenant' with 'source'='marc'
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And request { id: '#(instanceId1)', title: 'Instance with source = marc', source: 'marc', instanceTypeId: '#(instanceTypeId1)' }
    When method POST
    Then status 201

    Given path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      "jobExecutionId": "#(jobExecutionId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    Given path 'source-storage/records'
    And header Accept = 'application/json'
    And header x-okapi-tenant = centralTenant
    * def record = read('classpath:samples/marc_consortia_record.json')
    * set record.snapshotId = jobExecutionId
    * set record.externalIdsHolder.instanceId = instanceId1
    * set record.id = recordId
    * set record.matchedId = matchedId
    And request record
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

