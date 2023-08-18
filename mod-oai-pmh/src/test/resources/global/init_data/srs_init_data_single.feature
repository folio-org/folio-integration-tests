Feature: init datas for srs

  Background:
    * url baseUrl

  Scenario: create snapshot and post records
    Given path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
      "jobExecutionId": "67dfac11-1caf-4470-9ad1-d533f6360bc8",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    * def instancesId = ['1b74ab75-9f41-4837-8662-a1d99118008d', '6b4ae089-e1ee-431f-af83-e1133f8e3da0', 'ce00bca2-9270-4c6b-b096-b83a2e56e8e9', '62ca5b43-0f11-40af-a6b4-1a9ee2db33cb', '1640f178-f243-4e4a-bf1c-9e1e62b3171d', '8be05cf5-fb4f-4752-8094-8e179d08fb99', '3c4ae3f3-b460-4a89-a2f9-78ce3145e4fc', 'c1d3be12-ecec-4fab-9237-baf728575185', '6eee8eb9-db1a-46e2-a8ad-780f19974efa', '54cc0262-76df-4cac-acca-b10e9bc5c79a']
    * def recordsId = ['a2d6893e-c6b3-4c95-bec5-8b997aa1776d', '67dfac11-1caf-4470-9ad1-d533f6360ad4', '009286d6-f89e-4881-9562-11158f02664a', '0f0fe962-d502-4a4f-9e74-7732bec94ee8', 'e567b8e2-a45b-45f1-a85a-6b6312bdf4d8', '4c0ff739-3f4d-4670-a693-84dd48e31c53', '7293f287-bb51-41f5-805d-00ff18a1f791', '8fb19e31-0920-49d7-9438-b573c292b1a6' , 'be1b25ae-4a9d-4077-93e6-7f8e59efd609', '8f462542-387c-4f06-a01b-50829c7c7b13']
    * def matchedsId = ['332473da-b180-11ea-b3de-0242ac130004', '33247632-b180-11ea-b3de-0242ac130004', '33247722-b180-11ea-b3de-0242ac130004', '332477f4-b180-11ea-b3de-0242ac130004', '33247a92-b180-11ea-b3de-0242ac130004', '33247baa-b180-11ea-b3de-0242ac130004', '33247c7c-b180-11ea-b3de-0242ac130004', '33247d4e-b180-11ea-b3de-0242ac130004', '33247e16-b180-11ea-b3de-0242ac130004', '33247ee8-b180-11ea-b3de-0242ac130004']
    * def fun = function(i){ return { id: recordsId[i], instanceId: instancesId[i], matchedId: matchedsId[i]}}
    * def data = karate.repeat(1, fun)
    * call read('classpath:global/init_data/postRecord.feature') data
