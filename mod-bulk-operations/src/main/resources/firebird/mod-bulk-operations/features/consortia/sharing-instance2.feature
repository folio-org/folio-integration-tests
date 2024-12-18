Feature: Consortia Sharing Instances api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 5000 }

  Scenario: Share instance and wait for status = 'COMPLETE' if no error
    # get instance UUID
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And param query = 'title == "Summerland / Michael Chabon."'
    When method GET
    Then status 200
    And def instanceId = response.instances[0].id

    # share instance
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
    """
    {
      instanceIdentifier: '#(instanceId)',
      sourceTenantId:  '#(centralTenant)',
      targetTenantId:  '#(universityTenant)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant

    # wait for status COMPLETE
#    Given path 'consortia', consortiumId, 'sharing/instances'
#    And param instanceIdentifier = instanceId
#    And param sourceTenantId = universityTenant
#    And retry until response.sharingInstances[0].status == 'COMPLETE'
#    When method GET
#    Then status 200

#    * pause(30000)

    # 2. verify shared instance
    * call read(login) universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    Given path 'inventory/instances', instanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == instanceId
