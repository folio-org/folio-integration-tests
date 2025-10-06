@ignore
Feature: Share Instance Improved

  Background:
    * url baseUrl

  Scenario: shareInstance
    * def sharingId = call uuid
    * def sharingId = karate.get('sharingId', sharingId)
    * print 'Starting instance sharing with ID:', sharingId

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
    * print 'Successfully posted instance sharing request, ID:', sharingInstanceId

    # Verify status is 'COMPLETE' with more robust error handling
    * configure retry = { count: 60, interval: 15000 }
    * print 'Starting to poll for sharing status, will retry up to 60 times with 15 second intervals'

    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = sourceTenantId

    # More robust retry condition with better error handling
    * def sharingStatus = null
    * def verifySharing =
    """
    function(response) {
      if (!response) return false;
      if (!response.sharingInstances || response.sharingInstances.length === 0) return false;
      var status = response.sharingInstances[0].status;
      sharingStatus = status;
      karate.log('Current sharing status: ' + status);
      return status === 'COMPLETE' || status === 'ERROR';
    }
    """

    And retry until verifySharing(response)
    When method GET
    Then status 200
    * print 'Final polling result:', response

    * def sharingInstance = response.sharingInstances[0]
    * match sharingInstance.id == sharingInstanceId
    * match sharingInstance.instanceIdentifier == instanceId
    * match sharingInstance.sourceTenantId == sourceTenantId
    * match sharingInstance.targetTenantId == targetTenantId

    # Add better error handling
    * if (sharingStatus === 'ERROR') karate.fail('Instance sharing failed with ERROR status')
    * match sharingStatus == 'COMPLETE'

    * print 'Instance sharing completed successfully'

    # Verify shared instance is updated in source tenant with source = 'CONSORTIUM-FOLIO'
    # Add a delay before checking to ensure consistency
    * java.lang.Thread.sleep(5000)

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'
    * print 'Instance source verified as CONSORTIUM-FOLIO'
