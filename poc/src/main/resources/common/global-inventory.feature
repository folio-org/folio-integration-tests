Feature: global inventory

  Background:
    * url baseUrl
    * call login testAdmin

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: create identifier types
    Given path 'identifier-types'
    And request
    """
    {
      "id": "6d6f642d-0010-1111-aaaa-6f7264657273",
      "name": "ordersApiTestsIdentifierTypeName"
    }
    """
    When method POST
    Then status 201

  Scenario: create identifier types ISBN
    Given path 'identifier-types'
    And request
    """
    {
      "id": "8261054f-be78-422d-bd51-4ed9f33c3422",
      "name": "ISBN"
    }
    """
    When method POST
    Then status 201

  Scenario: create instance types
    Given path 'instance-types'
    And request
    """
    {
      "id": "6d6f642d-0000-1111-aaaa-6f7264657273",
      "code": "ordersApiTestsInstanceTypeCode",
      "name": "ordersApiTestsInstanceTypeCode",
      "source": "apiTests"
    }
    """
    When method POST
    Then status 201

  Scenario: create instance types 2
    Given path 'instance-types'
    And request
    """
    {
      "id" : "30fffe0e-e985-4144-b2e2-1e8179bdb41f",
      "name" : "unspecified",
      "code" : "zzz",
      "source" : "rdacontent"
    }
    """
    When method POST
    Then status 201


  Scenario: create instance status
    Given path 'instance-statuses'
    And request
    """
    {
      "id": "daf2681c-25af-4202-a3fa-e58fdf806183",
      "code": "temp",
       "name": "Temporary",
       "source": "folio"
    }
    """
    When method POST
    Then status 201

  Scenario: create loan-type
    Given path 'loan-types'
    And request
    """
    {"id": "2b94c631-fca9-4892-a730-03ee529ffe27", "name": "Can circulate", "metadata": {"createdDate": "2020-04-17T02:44:38.672", "updatedDate": "2020-04-17T02:44:38.672+0000"}}
    """
    When method POST
    Then status 201

  Scenario: create instance statuses
    Given path 'instance-statuses'
    And request
    """
    {
      "id": "6d6f642d-0001-1111-aaaa-6f7264657273",
      "code": "ordersApiTestsInstanceStatusCode",
      "name": "ordersApiTestsInstanceStatusCode",
      "source": "apiTests"
    }
    """
    When method POST
    Then status 201

  Scenario: create instance loan type
    Given path 'loan-types'
    And request
    """
    {
      "id": "6d6f642d-0002-1111-aaaa-6f7264657273",
      "name": "ordersApiTestsLoanTypeName"
    }
    """
    When method POST
    Then status 201

  Scenario: create instance material types
    Given path 'material-types'
    And request
    """
    {
      "id": "6d6f642d-0003-1111-aaaa-6f7264657273",
      "name": "materialTypeName"
    }
    """
    When method POST
    Then status 201

  Scenario: create instance contributor name types
    Given path 'contributor-name-types'
    And request
    """
    {
      "id": "6d6f642d-0005-1111-aaaa-6f7264657273",
      "name": "contributorNameType"
    }
    """
    When method POST
    Then status 201

  Scenario: create inventory electronic-access-relationships
    Given path 'electronic-access-relationships'
    And request
    """
    {
      "id": "f5d0068e-6272-458e-8a81-b85e7b9a14aa",
      "name": "Resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

  Scenario: create institution
    # init test data for orders

    # create institution
    Given path 'location-units/institutions'
    And request
    """
    {
        "id": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "name": "Universitet",
        "code": "TU"
    }
    """
    When method POST
    Then status 201


  Scenario: create campus
    # create campus
    Given path 'location-units/campuses'
    And request
    """
    {
        "id": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "name": " Campus",
        "code": "TC"
    }
    """
    When method POST
    Then status 201


  Scenario: create libraries
    # create libraries
    Given path 'location-units/libraries'
    And request
    """
    {
        "id": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "name": "Library",
        "code": "TL"
    }
    """
    When method POST
    Then status 201


  Scenario: create service points
    # create service-points
    Given path 'service-points'
    And request
    """
    {
        "id": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "name": "Service point",
        "code": "TSP",
        "discoveryDisplayName": "Service point 1"
    }
    """
    When method POST
    Then status 201

  Scenario: create locations
    # create locations
    Given path 'locations'
    And request
    """
    {
        "id": "b32c5ce2-6738-42db-a291-2796b1c3c4c6",
        "name": "Location 1",
        "code": "LOC1",
        "isActive": true,
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [
            "3a40852d-49fd-4df2-a1f9-6e2641a6e91f"
        ]
    }
    """
    When method POST
    Then status 201

