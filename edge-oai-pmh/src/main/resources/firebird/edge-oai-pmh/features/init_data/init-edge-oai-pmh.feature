Feature: post instance, holdings and items

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testAdmin
    * def okapiTokenAdmin = okapitoken

  Scenario: post instance type
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And request
    """
     {
            "id": "#(instanceTypeId)",
            "name": "text",
            "code": "txt",
            "source": "rdacontent"
     }
    """
    When method POST
    Then status 201

  Scenario: post instance
  * call read('init_data/create-instance.feature') { instanceId: '#(instanceId)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(instanceHrid)'}

  Scenario: create location
    Given path 'location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
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
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
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
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
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
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And request
    """
     {
            "id": "#(permanentLocationId)",
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
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
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

  Scenario: post electronic relationship
   * call read('init_data/create-electronic-access-relationship.feature') {electronicRelationshipId : 'f4d0068e-6272-458e-8a81-b85e7b9a14aa', name : 'No display constant generated'}
   * call read('init_data/create-electronic-access-relationship.feature') {electronicRelationshipId : 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', name : 'No information provided'}
   * call read('init_data/create-electronic-access-relationship.feature') {electronicRelationshipId : 'f6d0068e-6272-458e-8a81-b85e7b9a14aa', name : 'Related resource'}
   * call read('init_data/create-electronic-access-relationship.feature') {electronicRelationshipId : 'f7d0068e-6272-458e-8a81-b85e7b9a14aa', name : 'Resource'}
   * call read('init_data/create-electronic-access-relationship.feature') {electronicRelationshipId : 'f8d0068e-6272-458e-8a81-b85e7b9a14aa', name : 'Version of resource'}

  Scenario: create holding for instance
    * callonce read('init_data/create-holding.feature') { holdingId: '#(holdingId)', instanceId: '#(instanceId)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(holdingHrid)'}

  Scenario: create loan type ,material type, item
    Given path 'loan-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And request
    """
    {
          "id": "#(permanentLoanTypeId)",
          "name": "Can circulate"
    }
    """
    When method POST
    Then status 201

    Given path 'material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And request
    """
    {
          "id": "#(materialTypeId)",
          "name": "book",
          "source": "folio"
    }
    """
    When method POST
    Then status 201

    * callonce read('init_data/create-item.feature') { holdingId: '#(holdingId)', itemId: '#(itemId)', itemHrid: '#(itemHrid)', barcode: '#(barcode)'}

  Scenario: create snapshot and post record
    * callonce read('init_data/create-srs-record.feature') { jobExecutionId: '#(jobExecutionId)', instanceId: '#(instanceId)', recordId: '#(recordId)', matchedId: '#(matchedId)'}
