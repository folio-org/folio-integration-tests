Feature: create reference data

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant': '#(testUser.tenant)', 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: create holdings records source
    Given path 'holdings-sources'
    And request read('classpath:samples/holdings_source.json')
    When method POST
    Then status 201

  Scenario: create instance type
    Given path 'instance-types'
    And request
    """
     {
        "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "name": "text",
        "code": "txt",
        "source": "rdacontent"
     }
    """
    When method POST
    Then status 201

    Given path 'instance-types'
    And request
      """
      {
        "id": "30fffe0e-e985-4144-b2e2-1e8179bdb41f",
        "name": "unspecified",
        "code": "zzz",
        "source": "rdacontent"
      }
      """
    When method POST
    Then status 201

#  Scenario: post instance
#  * call read('init_data/create-instance.feature') { instanceId: '#(instanceId)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(instanceHrid)', instanceSource: 'MARC'}

  Scenario: create location
    Given path 'location-units/institutions'
    And request
    """
    {
        "id": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "name": "Københavns Universitet",
        "code": "KU"
    }
    """
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request
    """
    {
        "id": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "name": "City Campus",
        "code": "CC",
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57"
    }
    """
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request
    """
    {
        "id": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "name": "Datalogisk Institut",
        "code": "DI",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848"
    }
    """
    When method POST
    Then status 201

    Given path 'locations'
    And request
    """
     {
        "id": "d5629ec6-7259-4644-bb94-41bd30b2d1c6",
        "name": "SECOND FLOOR",
        "code": "KU/CC/DI/2",
        "isActive": true,
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [
            "3a40852d-49fd-4df2-a1f9-6e2641a6e91f"
        ],
        "servicePoints": []
        }
    """
    When method POST
    Then status 201

  Scenario: create call number type
    Given path 'call-number-types'
    And request
    """
        {
          "id": "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f",
          "name": "UDC",
          "source": "folio"
        }
    """
    When method POST
    Then status 201