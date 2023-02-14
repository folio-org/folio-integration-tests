@parallel=false
Feature: Central patron type mapping

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = get[0] response.centralServers[?(@.name == 'Central server 1')]
    * def centralServer2 = get[0] response.centralServers[?(@.name == 'Central server 2')]

  Scenario: Update central patron type mappings
    * print 'Prepare central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    And request read(samplesPath + 'central-patron-type-mappings/create-central-patron-type-mappings-request.json')
    When method PUT
    Then status 204

    * print 'Update central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    And request read(samplesPath + 'central-patron-type-mappings/update-central-patron-type-mappings-request.json')
    When method PUT
    Then status 204

    * print 'Check updated central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    * def validResponse = read(samplesPath + "central-patron-type-mappings/valid-central-patron-type-mappings-response.json")
    * def actualResponse = get response.centralPatronTypeMappings[*]
    And match actualResponse contains only validResponse

  Scenario: Update patron type mappings with invalid data
    * print 'update patron type mappings with invalid data'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    And request
    """
    {
      "centralPatronTypeMappings": [
        {
          "centralPatronType": 999999999
        }
      ]
    }
    """
    When method PUT
    Then status 400

  Scenario: Get central patron type mappings
    * print 'Get central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    * def validResponse = read(samplesPath + "central-patron-type-mappings/valid-central-patron-type-mappings-response.json")
    * def actualResponse = get response.centralPatronTypeMappings[*]
    And match actualResponse contains only validResponse

    * print 'Get not existed central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/central-patron-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')