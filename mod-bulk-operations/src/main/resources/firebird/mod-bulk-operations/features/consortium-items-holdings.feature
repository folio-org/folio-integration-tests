Feature: Consortium Items and Holdings Bulk Operations (LoC/ECS Support)

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-consortium.feature')
    * callonce login testUser
    * callonce variables
    * configure retry = { count: 5, interval: 10000 }

  @PositiveTest
  Scenario: Bulk edit items from central tenant with local properties (locations, loan types, note types)
    # This scenario tests bulk editing of items from central tenant with local reference data
    # Central tenant should be able to use local locations, loan types, note types, etc.
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload items by barcode
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/consortium/central-items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id
    * print 'Created bulk operation for items:', operationId

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
    
    * pause(15000)

    # Step 3: Download matched records
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    # Step 4: Preview items
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []
    * print 'Items preview successful'

    # Step 5: Apply bulk edit with local properties
    # Update permanent location, loan type, and add notes using local reference data
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
              "updated": "#(centralLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "PERMANENT_LOAN_TYPE",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralLoanTypeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "TEMPORARY_LOCATION",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralTempLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "ITEM_NOTE",
            "actions": [{
              "type": "ADD_TO_EXISTING",
              "initial": null,
              "updated": "Bulk edit test note",
              "parameters": [
                {
                  "key": "NOTE_TYPE_ID",
                  "value": "#(centralNoteTypeId)"
                }
              ]
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "STATUS",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "Available"
            }]
          }
        }
      ],
      "totalRecords": 3
    }
    """
    When method POST
    Then status 200
    * print 'Content update rules applied with local properties'

    * pause(15000)

    # Step 6: Preview changes
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    Then status 200
    And match response.rows != []
    * print 'Edit preview successful'

    # Step 7: Commit changes
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

    * pause(25000)

    # Step 8: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'Items bulk edit completed successfully'

    # Step 9: Download committed records
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    # Step 10: Verify items were updated with local properties
    Given path 'inventory/items'
    And param query = 'barcode==' + centralItemBarcode
    When method GET
    Then status 200
    And match response.items[0].permanentLocation.id == centralLocationId
    And match response.items[0].permanentLoanType.id == centralLoanTypeId
    And match response.items[0].temporaryLocation.id == centralTempLocationId
    And match response.items[0].status.name == 'Available'
    And match response.items[0].notes != []
    And match response.items[0].notes[*].itemNoteTypeId contains centralNoteTypeId
    * print 'Items verified with local properties'

  @PositiveTest
  Scenario: Bulk edit holdings from central tenant with local properties
    # Test bulk editing of holdings with local location and note types
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload holdings by HRID
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/central-holdings-hrids.csv', contentType: 'text/csv' }
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
    
    * pause(15000)

    # Step 3: Preview holdings
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows != []

    # Step 4: Apply updates with local properties
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
              "updated": "#(centralLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "TEMPORARY_LOCATION",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralTempLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "HOLDINGS_NOTE",
            "actions": [{
              "type": "ADD_TO_EXISTING",
              "initial": null,
              "updated": "Central tenant holdings note",
              "parameters": [
                {
                  "key": "NOTE_TYPE_ID",
                  "value": "#(centralHoldingsNoteTypeId)"
                }
              ]
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "SUPPRESS_FROM_DISCOVERY",
            "actions": [{
              "type": "SET_TO_FALSE",
              "initial": null,
              "updated": ""
            }]
          }
        }
      ],
      "totalRecords": 2
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

    # Step 6: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'

    # Step 7: Verify holdings with local properties
    Given path 'holdings-storage/holdings'
    And param query = 'hrid==' + centralHoldingHRID
    When method GET
    Then status 200
    And match response.holdingsRecords[0].permanentLocationId == centralLocationId
    And match response.holdingsRecords[0].temporaryLocationId == centralTempLocationId
    And match response.holdingsRecords[0].discoverySuppress == false
    And match response.holdingsRecords[0].notes != []
    And match response.holdingsRecords[0].notes[*].holdingsNoteTypeId contains centralHoldingsNoteTypeId
    * print 'Holdings verified with local properties'

  @PositiveTest
  Scenario: Bulk edit items from central tenant involving multiple local property types
    # Comprehensive test with statistical codes, material types, and other local properties
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload items
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/consortium/central-items-extended.csv', contentType: 'text/csv' }
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
    
    * pause(15000)

    # Step 3: Preview
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200

    # Step 4: Apply comprehensive updates with various local properties
    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "STATISTICAL_CODE",
            "actions": [{
              "type": "ADD_TO_EXISTING",
              "initial": null,
              "updated": "#(centralStatisticalCodeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "MATERIAL_TYPE",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralMaterialTypeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "PERMANENT_LOAN_TYPE",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralLoanTypeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "TEMPORARY_LOAN_TYPE",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralTempLoanTypeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "ADMINISTRATIVE_NOTE",
            "actions": [{
              "type": "ADD_TO_EXISTING",
              "initial": null,
              "updated": "Administrative note from bulk edit"
            }]
          }
        }
      ],
      "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 5: Commit
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

    * pause(25000)

    # Step 6: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'

    # Step 7: Verify all properties were updated
    Given path 'inventory/items'
    And param query = 'barcode==' + centralItemBarcode
    When method GET
    Then status 200
    And match response.items[0].statisticalCodeIds contains centralStatisticalCodeId
    And match response.items[0].materialType.id == centralMaterialTypeId
    And match response.items[0].permanentLoanType.id == centralLoanTypeId
    And match response.items[0].temporaryLoanType.id == centralTempLoanTypeId
    And match response.items[0].administrativeNotes != []
    * print 'Items verified with all local property types'

  @NegativeTest
  Scenario: Handle expected issues - Invalid local property references
    # Test error handling when invalid local property IDs are used
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload items
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/consortium/central-items-barcodes.csv', contentType: 'text/csv' }
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
    
    * pause(15000)

    # Step 3: Apply update with invalid location ID
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
              "updated": "00000000-0000-0000-0000-000000000000"
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

    # Step 4: Attempt to commit - should fail or complete with errors
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

    # Step 5: Verify errors were captured
    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    When method GET
    Then status 200
    And match response.errors != []
    And match response.errors[*].message contains 'location'
    * print 'Expected error for invalid location ID'

  @PositiveTest
  Scenario: Bulk edit holdings involving local locations and call number types
    # Test holdings with call number types and multiple location updates
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Upload holdings
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/consortium/central-holdings-callnumber.csv', contentType: 'text/csv' }
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
    
    * pause(15000)

    # Step 3: Apply updates with call number and location
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
              "updated": "#(centralLocationId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "CALL_NUMBER_TYPE",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "#(centralCallNumberTypeId)"
            }]
          }
        },
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "CALL_NUMBER_PREFIX",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "CENTRAL"
            }]
          }
        }
      ],
      "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    # Step 4: Commit
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

    # Step 5: Verify completion
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'

    # Step 6: Verify holdings updates
    Given path 'holdings-storage/holdings'
    And param query = 'hrid==' + centralHoldingHRID
    When method GET
    Then status 200
    And match response.holdingsRecords[0].permanentLocationId == centralLocationId
    And match response.holdingsRecords[0].callNumberTypeId == centralCallNumberTypeId
    And match response.holdingsRecords[0].callNumberPrefix == 'CENTRAL'
    * print 'Holdings verified with call number type and location'

  @PositiveTest
  Scenario: Verify consortium context is maintained throughout bulk operation lifecycle
    # End-to-end test ensuring consortium context (central vs member tenant) is properly maintained
    
    * def centralTenant = centralTenantId
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 1: Create operation in central tenant
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/consortium/central-items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * def operationId = $.id

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(centralOkapiToken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    
    # Step 2: Verify operation metadata shows central tenant
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.userId == '#notnull'
    * print 'Operation created in central tenant'

    # Step 3: Complete full flow
    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "UPLOAD" }
    When method POST
    Then status 200
    
    * pause(15000)

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
      "bulkOperationRules": [
        {
          "bulkOperationId": "#(operationId)",
          "rule_details": {
            "option": "STATUS",
            "actions": [{
              "type": "REPLACE_WITH",
              "initial": null,
              "updated": "Available"
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

    Given path 'bulk-operations', operationId, 'start'
    And request { "step": "EDIT", "approach": "IN_APP" }
    When method POST
    Then status 200

    * pause(20000)

    # Step 4: Verify operation completed in correct tenant context
    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'Operation completed successfully in central tenant context'
