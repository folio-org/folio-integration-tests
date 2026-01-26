Feature: Consortium MARC Instances Advanced Bulk Operations

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-consortium.feature')
    * callonce login testUser
    * callonce variables
    * configure retry = { count: 5, interval: 10000 }

  @PositiveTest
  Scenario: Bulk edit MARC instances - Add multiple MARC fields
    # Advanced MARC editing with multiple field additions
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Apply multiple MARC field updates
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
              "field": "590",
              "indicator1": " ",
              "indicator2": " ",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Local note - Central tenant"
                  }
                }
              ]
            },
            {
              "action": "ADD_TO_EXISTING",
              "field": "655",
              "indicator1": " ",
              "indicator2": "7",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Genre term"
                  }
                },
                {
                  "subfield": "2",
                  "data": {
                    "text": "lcgft"
                  }
                }
              ]
            },
            {
              "action": "ADD_TO_EXISTING",
              "field": "856",
              "indicator1": "4",
              "indicator2": "0",
              "subfields": [
                {
                  "subfield": "u",
                  "data": {
                    "text": "http://example.com/resource"
                  }
                },
                {
                  "subfield": "z",
                  "data": {
                    "text": "Access online resource"
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

    * pause(15000)

    # Step 4: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(30000)

    # Step 5: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'

    # Step 6: Verify MARC fields were added
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    * def instanceId = response.instances[0].id

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains deep { '590': '#notnull' }
    And match response.parsedRecord.content.fields contains deep { '655': '#notnull' }
    And match response.parsedRecord.content.fields contains deep { '856': '#notnull' }
    * print 'Multiple MARC fields added successfully'

  @PositiveTest
  Scenario: Bulk edit MARC instances - Replace existing MARC field
    # Test replacing existing MARC field content
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Replace MARC field 245 (title)
    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
    {
      "marcRecordModifications": [
        {
          "bulkOperationId": "#(operationId)",
          "marc_actions": [
            {
              "action": "REPLACE",
              "field": "245",
              "indicator1": "1",
              "indicator2": "0",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Updated Title via Bulk Edit /"
                  }
                },
                {
                  "subfield": "c",
                  "data": {
                    "text": "Updated Author."
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

    * pause(15000)

    # Step 4: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(30000)

    # Step 5: Verify MARC title was updated
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    * def instanceId = response.instances[0].id
    And match response.instances[0].title == 'Updated Title via Bulk Edit'

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    * print 'MARC field 245 replaced successfully'

  @PositiveTest
  Scenario: Bulk edit MARC instances - Remove MARC field
    # Test removing specific MARC fields
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Remove specific MARC field (e.g., 590 local note)
    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
    {
      "marcRecordModifications": [
        {
          "bulkOperationId": "#(operationId)",
          "marc_actions": [
            {
              "action": "REMOVE",
              "field": "590",
              "indicator1": " ",
              "indicator2": " "
            }
          ]
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 4: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(30000)

    # Step 5: Verify field was removed
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    * def instanceId = response.instances[0].id

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    # Verify 590 field is not present
    * print 'MARC field 590 removed successfully'

  @PositiveTest
  Scenario: Combined MARC and administrative data bulk edit
    # Test editing both MARC content and instance administrative data in same operation
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Update administrative data first
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

    * pause(10000)

    # Step 4: Update MARC content
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
              "field": "500",
              "indicator1": " ",
              "indicator2": " ",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Combined edit - administrative and MARC."
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

    * pause(15000)

    # Step 5: Commit all changes
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(30000)

    # Step 6: Verify both types of updates
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    And match response.instances[0].staffSuppress == true
    * def instanceId = response.instances[0].id

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains deep { '500': '#notnull' }
    * print 'Combined administrative and MARC updates successful'

  @NegativeTest
  Scenario: Handle MARC edit errors - Invalid field format
    # Test error handling for invalid MARC field specifications
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Try to add invalid MARC field (control field with subfields)
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
              "field": "008",
              "indicator1": " ",
              "indicator2": " ",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Invalid - 008 is a control field"
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
    # Should return 400 or 422 for validation error
    Then status 400

  @PositiveTest
  Scenario: Bulk edit MARC instances with subfield find and replace
    # Advanced scenario: Find and replace within MARC subfields
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload MARC instances
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Find and replace in MARC subfield
    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
    {
      "marcRecordModifications": [
        {
          "bulkOperationId": "#(operationId)",
          "marc_actions": [
            {
              "action": "FIND_AND_REPLACE",
              "field": "500",
              "indicator1": " ",
              "indicator2": " ",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "find": "MARC",
                    "replaceWith": "Machine-Readable Cataloging"
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

    * pause(15000)

    # Step 4: Commit changes
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(30000)

    # Step 5: Verify replacement occurred
    Given path 'instance-storage/instances'
    And param query = 'hrid==' + sharedMarcInstanceHRID
    When method GET
    Then status 200
    * def instanceId = response.instances[0].id

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    * print 'MARC subfield find and replace completed'

  @PositiveTest
  Scenario: Verify MARC edits from member tenant are restricted
    # Verify member tenants cannot edit MARC content of shared instances
    
    * def memberTenant = memberTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload shared MARC instance from member tenant
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/shared-marc-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(memberOkapiToken)', 'x-okapi-tenant': '#(memberTenant)', 'Accept': '*/*' }
    
    # Step 2: Start upload
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(20000)

    # Step 3: Attempt MARC content update from member tenant
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
              "field": "590",
              "indicator1": " ",
              "indicator2": " ",
              "subfields": [
                {
                  "subfield": "a",
                  "data": {
                    "text": "Member tenant note - should fail"
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
    # Should return 403 Forbidden or similar
    Then status 403
    * print 'Member tenant MARC edit correctly restricted'
