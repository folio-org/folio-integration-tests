@parallel=false
Feature:  Item contribution options configuration

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = get[0] response.centralServers[?(@.name == 'Central server 1')]
    * def centralServer2 = get[0] response.centralServers[?(@.name == 'Central server 2')]

  @create
  Scenario: Create item contribution options configuration

    * print 'Create item contribution options configuration'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    And request read(samplesPath + "item-contribution-options-configuration/create-item-contr-opt-conf-request.json")
    When method POST
    Then status 201
    And match response.id == '#notnull'
    And match response.notAvailableItemStatuses[*] contains only ["Awaiting delivery", "Missing"]
    And match response.nonLendableLoanTypes[*] == ["f417f250-43c6-4e5f-8020-f68c1fa9ef8c"]
    And match response.nonLendableLocations[*] == ["67a90a35-6ded-487e-9ff5-4443340f017d"]
    And match response.nonLendableMaterialTypes[*] == ["a4ccc368-e8f5-466b-8304-f713e14ff563"]

  Scenario: Create existed item contribution options configuration and with invalid data

    * print 'Create existed item contribution options configuration'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    And request read(samplesPath + "item-contribution-options-configuration/create-item-contr-opt-conf-request.json")
    When method POST
    Then status 409

    * print 'Create item contribution options configuration with invalid data'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/item-contribution-options'
    And request read(samplesPath + "item-contribution-options-configuration/create-item-contr-opt-conf-invalid-request.json")
    When method POST
    Then status 409

  Scenario: Get item contribution options configuration by central server id and not existed

    * print 'Get item contribution options configuration by central server id'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    When method GET
    Then status 200
    And match response.id == '#notnull'
    And match response.notAvailableItemStatuses[*] contains only ["Missing", "Awaiting delivery"]
    And match response.nonLendableLoanTypes[*] == ["f417f250-43c6-4e5f-8020-f68c1fa9ef8c"]
    And match response.nonLendableLocations[*] == ["67a90a35-6ded-487e-9ff5-4443340f017d"]
    And match response.nonLendableMaterialTypes[*] == ["a4ccc368-e8f5-466b-8304-f713e14ff563"]

    * print 'Get not existed item contribution options configuration by central server id'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/item-contribution-options'
    When method GET
    Then status 404

  Scenario: Update item contribution options configuration with negative scenarios

    * print 'Prepare request for update item contribution options configuration'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    When method GET
    Then status 200
    * def itemCoOpConf = response
    * set itemCoOpConf.notAvailableItemStatuses[0] = "Missing"
    * set itemCoOpConf.notAvailableItemStatuses[1] = "In process"
    * set itemCoOpConf.nonLendableLoanTypes[0] = "65bfc462-5af3-4d8e-899e-ff554f55c16f"
    * set itemCoOpConf.nonLendableLocations[0] = "2934b4db-a347-4405-b86f-0ff743141340"
    * set itemCoOpConf.nonLendableMaterialTypes[0] = "90b7b9e6-c429-4965-a0f4-f7cca1980a12"

    * print 'Update item contribution options configuration'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    And request itemCoOpConf
    When method PUT
    Then status 204

    * print 'Check successful update item contribution options configuration'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    When method GET
    Then status 200
    And match response.id == itemCoOpConf.id
    And match response.notAvailableItemStatuses[*] contains only ["In process", "Missing"]
    And match response.nonLendableLoanTypes[*] == ["65bfc462-5af3-4d8e-899e-ff554f55c16f"]
    And match response.nonLendableLocations[*] == ["2934b4db-a347-4405-b86f-0ff743141340"]
    And match response.nonLendableMaterialTypes[*] == ["90b7b9e6-c429-4965-a0f4-f7cca1980a12"]

    * print 'Attempt to update item contribution options configuration which not exist'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/item-contribution-options'
    And request itemCoOpConf
    When method PUT
    Then status 404

    * print 'Attempt to update item contribution options configuration with invalid data'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/item-contribution-options'
    * set itemCoOpConf.notAvailableItemStatuses[0] = "Available"
    And request itemCoOpConf
    When method PUT
    Then status 409

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')