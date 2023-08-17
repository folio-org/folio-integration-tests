Feature: init data for mod-configuration

  Background:
    * url baseUrl

  Scenario: post instances, holdings and items
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
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

    Given path 'location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
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
    And header x-okapi-token = testUserToken
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
    And header x-okapi-token = testUserToken
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
    And header x-okapi-token = testUserToken
    And request
    """
     {
            "id": "f34d27c6-a8eb-461b-acd6-5dea81771e70",
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

    Given path 'loan-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
            "id": "2b94c631-fca9-4892-a730-03ee529ffe27",
            "name": "Can circulate"
    }
    """
    When method POST
    Then status 201

    Given path 'material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
            "id": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
            "name": "book",
            "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "id": "ef03d582-219c-4221-8635-bc92f1107021",
      "name": "No display constant generated",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "id": "f50c90c9-bae0-4add-9cd0-db9092dbc9dd",
      "name": "No information provided",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "id": "5bfe1b7b-f151-4501-8cfa-23b321d5cd1e",
      "name": "Related resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
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

    Given path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "id": "3b430592-2e09-4b48-9a0c-0636d66b9fb3",
      "name": "Version of resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given path 'call-number-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "id": "512173a7-bd09-490e-b773-17d83f2b63fe",
      "name": "LC Modified",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    * def instancesId = ['1b74ab75-9f41-4837-8662-a1d99118008d', '6b4ae089-e1ee-431f-af83-e1133f8e3da0', 'ce00bca2-9270-4c6b-b096-b83a2e56e8e9', '62ca5b43-0f11-40af-a6b4-1a9ee2db33cb', '1640f178-f243-4e4a-bf1c-9e1e62b3171d', '8be05cf5-fb4f-4752-8094-8e179d08fb99', '3c4ae3f3-b460-4a89-a2f9-78ce3145e4fc', 'c1d3be12-ecec-4fab-9237-baf728575185', '6eee8eb9-db1a-46e2-a8ad-780f19974efa', '54cc0262-76df-4cac-acca-b10e9bc5c79a']
    * def holdingsId = ['e8e3db08-dc39-48ea-a3db-08dc3958eafb', '67dfac11-1caf-4470-9ad1-d533f6360ad4', '009286d6-f89e-4881-9562-11158f02664a', '0f0fe962-d502-4a4f-9e74-7732bec94ee8', 'e567b8e2-a45b-45f1-a85a-6b6312bdf4d8', '4c0ff739-3f4d-4670-a693-84dd48e31c53', '7293f287-bb51-41f5-805d-00ff18a1f791', '8fb19e31-0920-49d7-9438-b573c292b1a6' , 'be1b25ae-4a9d-4077-93e6-7f8e59efd609', '8f462542-387c-4f06-a01b-50829c7c7b13']
    * def itemsId = ['645549b1-2a73-4251-b8bb-39598f773a93', '6b4ae089-e1ee-431f-af83-e1133f8e3da0', 'ce00bca2-9270-4c6b-b096-b83a2e56e8e9', '62ca5b43-0f11-40af-a6b4-1a9ee2db33cb', '1640f178-f243-4e4a-bf1c-9e1e62b3171d', '8be05cf5-fb4f-4752-8094-8e179d08fb99', '3c4ae3f3-b460-4a89-a2f9-78ce3145e4fc', 'c1d3be12-ecec-4fab-9237-baf728575185', '6eee8eb9-db1a-46e2-a8ad-780f19974efa', '54cc0262-76df-4cac-acca-b10e9bc5c79a']
    * def hridsId = ['inst000000000145', 'inst000000000148', 'inst000000000151', 'inst000000000155', 'inst000000000158', 'inst000000000160', 'inst000000000162', 'inst000000000165', 'inst000000000168', 'inst000000000170']
    * def fun = function(i){ return { instanceId: instancesId[i], holdingId: holdingsId[i], itemId: itemsId[i], hridId: hridsId[i]}}
    * def data = karate.repeat(1, fun)
    * call read('classpath:global/init_data/postToInventory.feature') data
