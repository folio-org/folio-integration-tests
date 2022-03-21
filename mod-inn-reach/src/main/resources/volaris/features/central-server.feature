@parallel=false
Feature: Central server

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_inn_reach_integration1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def notExistedCentralServerId1 = globalCentralServerId1

  Scenario: Create and check central servers
    * configure headers = headersUser
    * print 'Create central server 1'
    Given path 'inn-reach/central-servers'
    And request
    """
     {
      "name": "name 1",
      "description": "description 1",
      "localServerCode": "fli01",
      "centralServerCode": "d2ir",
      "centralServerAddress": "https://rssandbox-api.iii.com",
      "loanTypeId": "6dae9cd4-ae7c-11eb-8529-0242ac130003",
      "localAgencies": [
        {
          "code": "q1w2e",
          "folioLibraryIds": [
            "7c244444-ae7c-11eb-8529-0242ac130004",
            "7f58859e-ae7c-11eb-8529-0242ac130004"
          ]
        },
        {
          "code": "w2e3r",
          "folioLibraryIds": [
            "71fb3252-ae7c-11eb-8529-0242ac130004",
            "761451d4-ae7c-11eb-8529-0242ac130005"
        ]
        }
      ],
      "centralServerKey": "b55f2568-e03a-4cc2-8f30-5fb69aa14f5f",
      "centralServerSecret": "0c3ae7f3-4e70-4d5d-b94d-5a6605166494",
      "localServerKey": "0a8eebdb-40e9-49c3-921d-2c753ee3f33a",
      "localServerSecret": "761451d4-ae7c-11eb-8529-0242ac130005"
      }
    """
    When method POST
    Then status 201
    * def centralServerId1 = $.id

    * configure headers = headersUser
    * print 'Get central server by id 1'
    Given path '/inn-reach/central-servers', centralServerId1
    When method GET
    Then status 200

    * def centralServerResponse = $
    And match centralServerResponse.id == centralServerId1
    And match centralServerResponse.description == "description 1"
    And match centralServerResponse.localServerCode == "fli01"
    And match centralServerResponse.centralServerAddress == "https://rssandbox-api.iii.com"
    And match centralServerResponse.localAgencies[0].code == "q1w2e"
    And match centralServerResponse.localAgencies[0].folioLibraryIds[0] == "7c244444-ae7c-11eb-8529-0242ac130004"

    * print 'Create central server 2'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request
    """
    {
      "id": "5033c5b3-7064-469a-af27-181b995aecff",
      "name": "name 2",
      "description": "description 2",
      "localServerCode": "fli02",
      "centralServerCode": "d1ir",
      "centralServerAddress": "https://rssandbox-api.iii.com",
      "loanTypeId": "f0d8f521-9d06-44a3-b38c-523eec7c4325",
      "localAgencies": [
      {
        "code": "b1w2e",
        "folioLibraryIds": [
          "e580a78d-5281-445e-9d54-b8ede32c8026",
          "3d75fbb6-f7da-42f1-82a5-f287bbccd2ae"
        ]
      },
      {
        "code": "b2e4r",
        "folioLibraryIds": [
          "360a61ad-2591-446f-8d92-84910fcd0bb4",
          "bd8b139e-e739-4484-925e-0772a7927b8b"
        ]
      }
      ],
      "centralServerKey": "a55f2568-e03a-4cc2-8f30-5fb69aa14f5f",
      "centralServerSecret": "0c3ae7f3-4e70-4d5d-b94d-5a6605166494",
      "localServerKey": "f1d33fd9-3ba0-4bdc-ba35-4c9ef2e8fdd1",
      "localServerSecret": "91533e9b-2172-429a-90f4-362983e04c1b"
    }
    """
    When method POST
    Then status 201
    * def centralServerId2 = $.id

    * print 'Get central server by id 2'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers', centralServerId2
    When method GET
    Then status 200

    * def centralServerResponse = $
    And match centralServerResponse.id == centralServerId2
    And match centralServerResponse.description == "description 2"
    And match centralServerResponse.localServerCode == "fli02"
    And match centralServerResponse.centralServerAddress == "https://rssandbox-api.iii.com"
    And match centralServerResponse.localAgencies[0].code == "b1w2e"
    And match centralServerResponse.localAgencies[0].folioLibraryIds[0] == "e580a78d-5281-445e-9d54-b8ede32c8026"

    * print 'Get central servers'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.centralServers[0].id == centralServerId1
    And match response.centralServers[1].id == centralServerId2

  Scenario: Check not existed central server
    * configure headers = headersUser
    * print 'Check not existed central server'
    Given path '/inn-reach/central-servers', notExistedCentralServerId1
    * configure headers = headersUser
    When method GET
    Then status 404
