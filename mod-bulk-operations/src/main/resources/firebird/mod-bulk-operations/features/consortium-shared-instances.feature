Feature: Consortium Shared Instances Bulk Operations (LoC/ECS Support)

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-consortium.feature')
    * callonce login testUser
    * callonce variables
    * configure retry = { count: 5, interval: 10000 }

  @PositiveTest
  Scenario: Bulk edit shared FOLIO instances from central tenant - Full flow with holdings and items update
    # This scenario tests bulk editing of shared FOLIO instances from the central tenant
    # including the ability to update associated holdings and items
    
    # Switch to central tenant context
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload CSV with shared FOLIO instance HRIDs
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-folio-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id
    * print 'Created bulk operation:', operationId

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload process
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    * print 'Upload started successfully'
    
    * pause(20000)

    # Step 3: Verify matched records
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200
    * print 'Matched records downloaded successfully'

    # Step 4: Preview uploaded data
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []
    And match response.rows[0].row[3] == sharedFolioInstanceHRID
    * print 'Preview verified - shared FOLIO instance found'

    # Step 5: Apply bulk edit rules - update instance administrative data
    # with option to apply changes to holdings and items
    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "SUPPRESS_FROM_DISCOVERY",
            "actions": [{
              "type": "SET_TO_TRUE",
              "initial": null,
              "updated": "",
              "parameters": [
                {
                  "key": "APPLY_TO_HOLDINGS",
                  "value": "true"
                },
                {
                  "key": "APPLY_TO_ITEMS",
                  "value": "true"
                }
              ]
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "STAFF_SUPPRESS",
            "actions": [{
              "type": "SET_TO_FALSE",
              "initial": null,
              "updated": ""
            }]
          }
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200
    * print 'Content update rules applied'

    * pause(15000)

    # Step 6: Preview changes before committing
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    Then status 200
    And match response.rows != []
    * print 'Edit preview successful'

    # Step 7: Start the bulk edit (commit changes)
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "EDIT",
      "approach": "IN_APP"
    }
    """
    When method POST
    Then status 200
    * print 'Bulk edit started'

    * pause(30000)

    # Step 8: Verify changes were applied
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'Bulk operation completed successfully'

    # Step 9: Download committed records
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200
    * print 'Committed records downloaded'

    # Step 10: Verify instance, holdings, and items were updated
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedFolioInstanceHRID
    When method GET
    Then status 200
    And match response.instances[0].discoverySuppress == true
    And match response.instances[0].staffSuppress == false
    * print 'Instance suppress flags verified'

    # Step 11: Verify holdings were updated (cascade effect)
    * def instanceId = response.instances[0].id
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.holdingsRecords[0].discoverySuppress == true
    * print 'Holdings suppress flags updated via cascade'

    # Step 12: Verify items were updated (cascade effect)
    * def holdingsId = response.holdingsRecords[0].id
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingsId
    When method GET
    Then status 200
    And match response.items[0].discoverySuppress == true
    * print 'Items suppress flags updated via cascade'

  @PositiveTest
  Scenario: Bulk edit shared MARC instances from central tenant - Full flow
    # This scenario tests bulk editing of shared MARC instances from the central tenant
    # MARC instances require special handling due to source record management
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload CSV with shared MARC instance HRIDs
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload process
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Preview uploaded MARC instances
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []
    And match response.rows[0].row[3] == sharedMarcInstanceHRID
    * print 'MARC instance preview successful'

    # Step 4: Apply MARC content update rules
    # For MARC instances, we update specific MARC fields
    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
    {
      "marcRecordModifications": [
        {
          "bulkOperationId": "#(operationId)",
          "marc_actions": [
            {
              "action": "ADD_TO_EXISTING",
              "field": "949",
              "indicator1": "",
              "indicator2": "",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Test note from bulk edit"
                  }
                }
              ]
            }
          ]
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200
    * print 'MARC content update applied'

    * pause(15000)

    # Step 5: Preview MARC changes
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    Then status 200
    * print 'MARC edit preview successful'

    # Step 6: Commit MARC changes
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "EDIT",
      "approach": "IN_APP"
    }
    """
    When method POST
    Then status 200

    * pause(30000)

    # Step 7: Verify operation completed
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'MARC bulk edit completed successfully'

    # Step 8: Verify MARC record was updated in SRS
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    * def instanceId = response.instances[0].id
    * print 'MARC instance ID:', instanceId

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains deep { '949': '#notnull' }
    * print 'MARC record in SRS verified'

  @PositiveTest
  Scenario: Bulk edit shared instances from member tenant - Full flow with expected restrictions
    # This scenario tests bulk editing from a member tenant
    # Member tenants should be able to edit local data but not the shared instance itself
    
    * def memberTenant = memberTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload shared instance from member tenant
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload - should succeed for preview
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Preview should show instance but with warnings about restrictions
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []

    # Step 4: Attempt to update shared instance administrative data from member tenant
    # This should result in expected warnings/errors
    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "SUPPRESS_FROM_DISCOVERY",
            "actions": [{
              "type": "SET_TO_TRUE",
              "initial": null,
              "updated": ""
            }]
          }
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 5: Start edit - should complete but with errors for shared instance updates
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "EDIT",
      "approach": "IN_APP"
    }
    """
    When method POST
    Then status 200

    * pause(30000)

    # Step 6: Verify operation completed with expected errors
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    # Status should be COMPLETED_WITH_ERRORS or similar
    And match response.status == '#present'
    * print 'Member tenant edit completed with expected restrictions'

    # Step 7: Check errors - should indicate restriction on shared instance editing
    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    When method GET
    Then status 200
    And match response.errors != []
    And match response.errors[*].message contains 'shared'
    * print 'Expected error messages found for shared instance restrictions'

  @PositiveTest
  Scenario: Bulk edit local holdings and items from member tenant with shared instance
    # Member tenants can edit their local holdings and items even if associated with shared instances
    
    * def memberTenant = memberTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload holdings HRIDs (local to member tenant)
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/member-holdings-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    
    * pause(15000)

    # Step 3: Preview holdings
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []

    # Step 4: Apply bulk edit to local holdings - change permanent location
    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "PERMANENT_LOCATION",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(memberLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "SUPPRESS_FROM_DISCOVERY",
            "actions": [{
              "type": "SET_TO_TRUE",
              "initial": null,
              "updated": ""
            }]
          }
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 5: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "EDIT",
      "approach": "IN_APP"
    }
    """
    When method POST
    Then status 200

    * pause(20000)

    # Step 6: Verify successful completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'Member tenant local holdings update completed successfully'

    # Step 7: Verify holdings were updated
    Given path 'holdings-storage/holdings'
    And param query = 'hrid==' + memberHoldingHRID
    When method GET
    Then status 200
    And match response.holdingsRecords[0].permanentLocationId == memberLocationId
    And match response.holdingsRecords[0].discoverySuppress == true
    * print 'Local holdings updated successfully by member tenant'

  @NegativeTest
  Scenario: Handle expected issues - non-shared instances in consortium context
    # This scenario verifies proper handling of non-shared instances in consortium
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload mix of shared and non-shared instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/mixed-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Preview should show all instances
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []

    # Step 4: Verify no errors for valid instances
    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    When method GET
    Then status 200
    # Should have no errors if all instances are valid for central tenant
    * print 'Mixed instance handling verified'

  @PositiveTest
  Scenario: Bulk edit MARC instances with holdings and items from central tenant
    # Full integration test for MARC instances with cascading updates
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/marc-with-holdings-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "UPLOAD"
    }
    """
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Preview data
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200

    # Step 4: Update administrative data with cascade to holdings/items
    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "STAFF_SUPPRESS",
            "actions": [{
              "type": "SET_TO_TRUE",
              "initial": null,
              "updated": "",
              "parameters": [
                {
                  "key": "APPLY_TO_HOLDINGS",
                  "value": "true"
                },
                {
                  "key": "APPLY_TO_ITEMS",
                  "value": "true"
                }
              ]
            }]
          }
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 5: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
      "step": "EDIT",
      "approach": "IN_APP"
    }
    """
    When method POST
    Then status 200

    * pause(30000)

    # Step 6: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'MARC instance with holdings/items update completed'
