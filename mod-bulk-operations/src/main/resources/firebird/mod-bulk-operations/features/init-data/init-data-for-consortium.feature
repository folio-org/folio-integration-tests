Feature: Initialize data for consortium bulk operations testing

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  Scenario: Setup consortium structure with central and member tenants
    # This scenario sets up the consortium environment with central and member tenants
    # It creates necessary reference data for both tenants including:
    # - Institutions, campuses, libraries, locations
    # - Loan types, material types, note types
    # - Statistical codes
    # - Shared instances (FOLIO and MARC)
    # - Holdings and items

    # ========== SETUP CENTRAL TENANT ==========
    * def centralTenantId = 'consortium-central'
    * def centralOkapiToken = okapitoken
    
    # Note: In real consortium setup, you would need to:
    # 1. Create central tenant through tenant API
    # 2. Install required modules for central tenant
    # 3. Get proper authentication token for central tenant
    # For this feature file, we assume the tenant setup is done externally
    
    * print 'Setting up central tenant:', centralTenantId

    # Create service points for central tenant
    * def centralServicePoint = 
    """
    {
      "id": "c4c90014-c8c9-4ade-8f24-b5e313319f4b",
      "name": "Central Service Point",
      "code": "CSP",
      "discoveryDisplayName": "Central Service Point",
      "pickupLocation": true
    }
    """
    Given path 'service-points'
    And request centralServicePoint
    When method POST
    Then status 201

    # Create institution for central tenant
    * def centralInstitution = 
    """
    {
      "id": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
      "name": "Central Institution",
      "code": "CINST"
    }
    """
    Given path 'location-units/institutions'
    And request centralInstitution
    When method POST
    Then status 201

    # Create campus for central tenant
    * def centralCampus = 
    """
    {
      "id": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
      "name": "Central Campus",
      "code": "CCMP",
      "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57"
    }
    """
    Given path 'location-units/campuses'
    And request centralCampus
    When method POST
    Then status 201

    # Create library for central tenant
    * def centralLibrary = 
    """
    {
      "id": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
      "name": "Central Library",
      "code": "CLIB",
      "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848"
    }
    """
    Given path 'location-units/libraries'
    And request centralLibrary
    When method POST
    Then status 201

    # Create permanent location for central tenant
    * def centralLocation = 
    """
    {
      "id": "fcd64ce1-6995-48f0-840e-89ffa2288371",
      "name": "Central Main Stack",
      "code": "CMAIN",
      "isActive": true,
      "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
      "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
      "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
      "primaryServicePoint": "c4c90014-c8c9-4ade-8f24-b5e313319f4b",
      "servicePointIds": ["c4c90014-c8c9-4ade-8f24-b5e313319f4b"]
    }
    """
    * def centralLocationId = 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    Given path 'locations'
    And request centralLocation
    When method POST
    Then status 201

    # Create temporary location for central tenant
    * def centralTempLocation = 
    """
    {
      "id": "758258bc-ecc1-41b8-abca-f7b610822ffd",
      "name": "Central Temporary Stack",
      "code": "CTEMP",
      "isActive": true,
      "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
      "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
      "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
      "primaryServicePoint": "c4c90014-c8c9-4ade-8f24-b5e313319f4b",
      "servicePointIds": ["c4c90014-c8c9-4ade-8f24-b5e313319f4b"]
    }
    """
    * def centralTempLocationId = '758258bc-ecc1-41b8-abca-f7b610822ffd'
    Given path 'locations'
    And request centralTempLocation
    When method POST
    Then status 201

    # Create loan types for central tenant
    * def centralLoanType = 
    """
    {
      "id": "2b94c631-fca9-4892-a730-03ee529ffe27",
      "name": "Central Can Circulate",
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      }
    }
    """
    * def centralLoanTypeId = '2b94c631-fca9-4892-a730-03ee529ffe27'
    Given path 'loan-types'
    And request centralLoanType
    When method POST
    Then status 201

    * def centralTempLoanType = 
    """
    {
      "id": "e8b311a6-3b70-4ed0-be33-d9cd0bfc6c8e",
      "name": "Central Short Term Loan",
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      }
    }
    """
    * def centralTempLoanTypeId = 'e8b311a6-3b70-4ed0-be33-d9cd0bfc6c8e'
    Given path 'loan-types'
    And request centralTempLoanType
    When method POST
    Then status 201

    # Create material types for central tenant
    * def centralMaterialType = 
    """
    {
      "id": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
      "name": "Central Book",
      "source": "folio"
    }
    """
    * def centralMaterialTypeId = '1a54b431-2e4f-452d-9cae-9cee66c9a892'
    Given path 'material-types'
    And request centralMaterialType
    When method POST
    Then status 201

    # Create note types for central tenant (items)
    * def centralNoteType = 
    """
    {
      "id": "8d0a5eca-25de-4391-81a9-236eeefdd20b",
      "name": "Central Item Note",
      "source": "folio"
    }
    """
    * def centralNoteTypeId = '8d0a5eca-25de-4391-81a9-236eeefdd20b'
    Given path 'item-note-types'
    And request centralNoteType
    When method POST
    Then status 201

    # Create note types for central tenant (holdings)
    * def centralHoldingsNoteType = 
    """
    {
      "id": "b160f13a-ddba-4053-b9c4-60ec5ea45d56",
      "name": "Central Holdings Note",
      "source": "folio"
    }
    """
    * def centralHoldingsNoteTypeId = 'b160f13a-ddba-4053-b9c4-60ec5ea45d56'
    Given path 'holdings-note-types'
    And request centralHoldingsNoteType
    When method POST
    Then status 201

    # Create statistical code type for central tenant
    * def centralStatCodeType = 
    """
    {
      "id": "b899a5b1-4a7f-4f1e-8c5b-2f3c6e2a1f4d",
      "name": "Central Stat Code Type",
      "source": "folio"
    }
    """
    Given path 'statistical-code-types'
    And request centralStatCodeType
    When method POST
    Then status 201

    # Create statistical code for central tenant
    * def centralStatCode = 
    """
    {
      "id": "c3a5b1d2-4f1e-4e5c-9d3b-8a7f6e5d4c3b",
      "code": "CSTAT",
      "name": "Central Statistical Code",
      "statisticalCodeTypeId": "b899a5b1-4a7f-4f1e-8c5b-2f3c6e2a1f4d",
      "source": "folio"
    }
    """
    * def centralStatisticalCodeId = 'c3a5b1d2-4f1e-4e5c-9d3b-8a7f6e5d4c3b'
    Given path 'statistical-codes'
    And request centralStatCode
    When method POST
    Then status 201

    # Create call number type for central tenant
    * def centralCallNumberType = 
    """
    {
      "id": "95467209-6d7b-468b-94df-0f5d7ad2747d",
      "name": "Library of Congress classification",
      "source": "folio"
    }
    """
    * def centralCallNumberTypeId = '95467209-6d7b-468b-94df-0f5d7ad2747d'
    Given path 'call-number-types'
    And request centralCallNumberType
    When method POST
    Then status 201

    # Create instance types
    * def instanceType = 
    """
    {
      "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "name": "text",
      "code": "txt",
      "source": "rdacontent"
    }
    """
    Given path 'instance-types'
    And request instanceType
    When method POST
    Then status 201

    # Create identifier types
    * def identifierType = 
    """
    {
      "id": "8261054f-be78-422d-bd51-4ed9f33c3422",
      "name": "ISBN",
      "source": "folio"
    }
    """
    Given path 'identifier-types'
    And request identifierType
    When method POST
    Then status 201

    # Create contributor name types
    * def contributorNameType = 
    """
    {
      "id": "2b94c631-fca9-4892-a730-03ee529ffe27",
      "name": "Personal name",
      "ordering": "lastName, firstName"
    }
    """
    Given path 'contributor-name-types'
    And request contributorNameType
    When method POST
    Then status 201

    # Create holdings source
    * def holdingsSource = 
    """
    {
      "id": "f32d531e-df79-46b3-8932-cdd35f7a77d8",
      "name": "FOLIO",
      "source": "folio"
    }
    """
    Given path 'holdings-sources'
    And request holdingsSource
    When method POST
    Then status 201

    # Create shared FOLIO instance
    * def sharedFolioInstance = 
    """
    {
      "id": "5bf370e0-8cca-4d9c-82e4-5170ab2a0a39",
      "hrid": "inst000000000099",
      "source": "FOLIO",
      "title": "Shared FOLIO Instance for Bulk Edit",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "Test Author",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe27"
        }
      ],
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      },
      "_version": 1
    }
    """
    * def sharedFolioInstanceHRID = 'inst000000000099'
    Given path 'instance-storage/instances'
    And request sharedFolioInstance
    When method POST
    Then status 201

    # Create shared MARC instance
    * def sharedMarcInstance = 
    """
    {
      "id": "f4529ca9-3720-4967-ac5f-9ed2d37ade9d",
      "hrid": "inst000000000100",
      "source": "MARC",
      "title": "Shared MARC Instance for Bulk Edit",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "MARC Author",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe27"
        }
      ],
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      },
      "_version": 1
    }
    """
    * def sharedMarcInstanceHRID = 'inst000000000100'
    Given path 'instance-storage/instances'
    And request sharedMarcInstance
    When method POST
    Then status 201

    # Create holdings for shared instance
    * def centralHolding = 
    """
    {
      "id": "e3ff6133-b9a2-4d4c-a1c9-dc1867d4df19",
      "hrid": "hold000000000099",
      "instanceId": "5bf370e0-8cca-4d9c-82e4-5170ab2a0a39",
      "permanentLocationId": "fcd64ce1-6995-48f0-840e-89ffa2288371",
      "holdingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
      "sourceId": "f32d531e-df79-46b3-8932-cdd35f7a77d8",
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      },
      "_version": 1
    }
    """
    * def centralHoldingHRID = 'hold000000000099'
    Given path 'holdings-storage/holdings'
    And request centralHolding
    When method POST
    Then status 201

    # Create items for holdings
    * def centralItem = 
    """
    {
      "id": "7212ba6a-8dcf-45a1-be9a-ffaa847c4423",
      "hrid": "item000000000099",
      "holdingsRecordId": "e3ff6133-b9a2-4d4c-a1c9-dc1867d4df19",
      "barcode": "CENT10001",
      "status": {
        "name": "Available"
      },
      "permanentLoanTypeId": "2b94c631-fca9-4892-a730-03ee529ffe27",
      "materialTypeId": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      },
      "_version": 1
    }
    """
    * def centralItemBarcode = 'CENT10001'
    Given path 'item-storage/items'
    And request centralItem
    When method POST
    Then status 201

    # ========== SETUP MEMBER TENANT ==========
    * def memberTenantId = 'consortium-member'
    * def memberOkapiToken = okapitoken
    
    * print 'Setting up member tenant:', memberTenantId

    # Create service point for member tenant
    * def memberServicePoint = 
    """
    {
      "id": "7c5abc9f-f3d7-4856-b8d7-6712462ca007",
      "name": "Member Service Point",
      "code": "MSP",
      "discoveryDisplayName": "Member Service Point",
      "pickupLocation": true
    }
    """
    Given path 'service-points'
    And request memberServicePoint
    When method POST
    Then status 201

    # Create institution for member tenant
    * def memberInstitution = 
    """
    {
      "id": "5b8c6b00-6e6f-4c0b-a0f0-6e0d1d4e4e4e",
      "name": "Member Institution",
      "code": "MINST"
    }
    """
    Given path 'location-units/institutions'
    And request memberInstitution
    When method POST
    Then status 201

    # Create campus for member tenant
    * def memberCampus = 
    """
    {
      "id": "83a67d5f-4f0f-4c0b-a0f0-6e0d1d4e4e4f",
      "name": "Member Campus",
      "code": "MCMP",
      "institutionId": "5b8c6b00-6e6f-4c0b-a0f0-6e0d1d4e4e4e"
    }
    """
    Given path 'location-units/campuses'
    And request memberCampus
    When method POST
    Then status 201

    # Create library for member tenant
    * def memberLibrary = 
    """
    {
      "id": "a1b2c3d4-5e6f-7890-abcd-ef1234567890",
      "name": "Member Library",
      "code": "MLIB",
      "campusId": "83a67d5f-4f0f-4c0b-a0f0-6e0d1d4e4e4f"
    }
    """
    Given path 'location-units/libraries'
    And request memberLibrary
    When method POST
    Then status 201

    # Create location for member tenant
    * def memberLocation = 
    """
    {
      "id": "b1c2d3e4-5f6a-7b8c-9d0e-1f2a3b4c5d6e",
      "name": "Member Main Stack",
      "code": "MMAIN",
      "isActive": true,
      "institutionId": "5b8c6b00-6e6f-4c0b-a0f0-6e0d1d4e4e4e",
      "campusId": "83a67d5f-4f0f-4c0b-a0f0-6e0d1d4e4e4f",
      "libraryId": "a1b2c3d4-5e6f-7890-abcd-ef1234567890",
      "primaryServicePoint": "7c5abc9f-f3d7-4856-b8d7-6712462ca007",
      "servicePointIds": ["7c5abc9f-f3d7-4856-b8d7-6712462ca007"]
    }
    """
    * def memberLocationId = 'b1c2d3e4-5f6a-7b8c-9d0e-1f2a3b4c5d6e'
    Given path 'locations'
    And request memberLocation
    When method POST
    Then status 201

    # Create member holdings for shared instance
    * def memberHolding = 
    """
    {
      "id": "c1d2e3f4-5a6b-7c8d-9e0f-1a2b3c4d5e6f",
      "hrid": "hold000000000100",
      "instanceId": "5bf370e0-8cca-4d9c-82e4-5170ab2a0a39",
      "permanentLocationId": "b1c2d3e4-5f6a-7b8c-9d0e-1f2a3b4c5d6e",
      "holdingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
      "sourceId": "f32d531e-df79-46b3-8932-cdd35f7a77d8",
      "metadata": {
        "createdDate": "2024-01-01T00:00:00.000Z"
      },
      "_version": 1
    }
    """
    * def memberHoldingHRID = 'hold000000000100'
    Given path 'holdings-storage/holdings'
    And request memberHolding
    When method POST
    Then status 201

    * print '========== Consortium setup completed =========='
    * print 'Central Tenant ID:', centralTenantId
    * print 'Member Tenant ID:', memberTenantId
    * print 'Shared FOLIO Instance HRID:', sharedFolioInstanceHRID
    * print 'Shared MARC Instance HRID:', sharedMarcInstanceHRID
