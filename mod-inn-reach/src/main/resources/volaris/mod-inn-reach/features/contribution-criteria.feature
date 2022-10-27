@parallel=false
Feature: Contribution criteria

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

    * def criteriaPath1 = '/inn-reach/central-servers/' + centralServer1.id + '/contribution-criteria'
    * def criteriaPath2 = '/inn-reach/central-servers/' + centralServer2.id + '/contribution-criteria'

  Scenario: Create and get contribution criteria
    * print 'Create criteria'
    Given path criteriaPath1
    And request read(samplesPath + 'contribution-criteria/contribution-criteria.json')
    When method POST
    Then status 201

    Given path criteriaPath2
    And request read(samplesPath + 'contribution-criteria/contribution-criteria.json')
    When method POST
    Then status 201

    * print 'Get criteria'
    Given path criteriaPath1
    When method GET
    Then status 200

    And match response.id == '#notnull'
    And match response.metadata == '#notnull'
    And match response.contributeButSuppressId == '6ececda6-2f92-4dd4-8d4c-e41d057d288a'
    And match response.doNotContributeId == 'fdbbf57a-3de8-487a-bb5b-1744bb64c9e8'
    And match response.contributeAsSystemOwnedId == 'ef61ec3f-f22c-4af1-a861-4a8414086204'

  Scenario: Update contribution criteria
    * print 'Update criteria'

    Given path criteriaPath1
    When method GET
    Then status 200
    * def criteria = response
    * set criteria.contributeAsSystemOwnedId = '3727a0da-ece3-4e3f-9b1d-7f626e31ac4f'
    * set criteria.doNotContributeId = 'f3e1d9b7-e4c1-4056-bdbe-6884fb698d1b'
    * set criteria.contributeButSuppressId = '640443c1-dc22-4865-b8bf-862bad5b44e8'
    * set criteria.locationIds = [ '1d588bc4-d291-49cf-896c-c7f0f30f7c55' ]

    Given path criteriaPath1
    And request criteria
    When method PUT
    Then status 204

    * print 'Get updated criteria'
    Given path criteriaPath1
    When method GET
    Then status 200
    And match response.id == criteria.id
    And match response.metadata == '#notnull'
    And match response.contributeButSuppressId == criteria.contributeButSuppressId
    And match response.doNotContributeId == criteria.doNotContributeId
    And match response.contributeAsSystemOwnedId == criteria.contributeAsSystemOwnedId

    * print 'Update criteria - bad request'
    Given path criteriaPath1
    And request criteria
    And set criteria.contributeAsSystemOwnedId = 'not a uuid'
    When method PUT
    Then status 500

  Scenario: Unknown central server
    * print 'Get criteria for unknown central server'
    Given path '/inn-reach/central-servers/' + uuid() + '/contribution-criteria'
    When method GET
    Then status 404

  Scenario: Delete contribution criteria
    * print 'Delete criteria'
    Given path criteriaPath1
    When method DELETE
    Then status 204

 Scenario: Non-existing contribution criteria
   * print 'Get non-existing criteria'
   Given path criteriaPath1
   When method GET
   Then status 404

   * print 'Update non-existing criteria'
   Given path criteriaPath1
   And request read(samplesPath + 'contribution-criteria/contribution-criteria.json')
   When method PUT
   Then status 404

   * print 'Delete non-existing criteria'
   Given path criteriaPath1
   When method DELETE
   Then status 404

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')

    Given path criteriaPath1
    When method GET
    Then status 404

    Given path criteriaPath2
    When method GET
    Then status 404
