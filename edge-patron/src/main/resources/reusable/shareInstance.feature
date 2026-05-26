@ignore
Feature: Share Instance

  Background:
    * url baseUrl

  Scenario: shareInstance
    * def sharingId = call uuid
    * def sharingId = karate.get('sharingId', sharingId)

    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
    """
    {
      id: '#(sharingId)',
      instanceIdentifier: '#(instanceId)',
      sourceTenantId:  '#(sourceTenantId)',
      targetTenantId:  '#(targetTenantId)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == sourceTenantId
    And match response.targetTenantId == targetTenantId
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = sourceTenantId
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId
    And match sharingInstance.sourceTenantId == sourceTenantId
    And match sharingInstance.targetTenantId == targetTenantId
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is update in source tenant with source = 'CONSORTIUM-FOLIO'
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'