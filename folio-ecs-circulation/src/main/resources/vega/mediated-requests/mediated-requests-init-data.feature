@ignore
Feature: Reusable setup helpers for mediated-requests scenarios

  # Parameters accepted by @CreatePatronUser:
  #   uniOkapitoken  - university tenant token
  #   universityTenant
  #   collegeOkapitoken - college tenant token
  #   collegeTenant
  #   centralOkapitoken - central tenant token
  #   centralTenant
  #   patronTenant, patronOkapitoken - optional patron's home tenant (defaults to university)
  # Returns: requesterId, requesterBarcode, groupId

  # Parameters accepted by @CreateSharedInstanceWithItemInUniversity:
  #   centralOkapitoken, uniOkapitoken, centralTenant, universityTenant,
  #   consortiumId, mrInstanceTypeId, mrUniLocationId, mrUniHoldingsSourceId,
  #   mrMaterialTypeId, mrLoanTypeId, instanceTitle
  # Returns: inventory (instanceId, holdingId, itemId, itemBarcode)

  # Parameters accepted by @CreateSharedInstanceWithItemInCollege:
  #   centralOkapitoken, uniOkapitoken, collegeOkapitoken,
  #   centralTenant, universityTenant, collegeTenant,
  #   consortiumId, mrInstanceTypeId, mrCollegeLocationId, mrCollegeHoldingsSourceId,
  #   mrMaterialTypeId, mrLoanTypeId, instanceTitle
  # Returns: inventory (instanceId, holdingId, itemId, itemBarcode)

  Background:
    * url baseUrl

  @CreatePatronUser
  Scenario: create a patron in its home tenant, with the same group in university, college and central
    * def groupId = uuid()
    * def groupName = "mr-grp-" + randomMillis()

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    Given path 'groups'
    And request { id: '#(groupId)', group: '#(groupName)', desc: 'Mediated request test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeOkapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }
    Given path 'groups'
    And request { id: '#(groupId)', group: '#(groupName)', desc: 'Mediated request test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralOkapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    Given path 'groups'
    And request { id: '#(groupId)', group: '#(groupName)', desc: 'Mediated request test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def patronTenant = karate.get('patronTenant', universityTenant)
    * def patronOkapitoken = karate.get('patronOkapitoken', uniOkapitoken)
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(patronOkapitoken)', 'x-okapi-tenant': '#(patronTenant)' }
    * def requesterId = uuid()
    * def requesterBarcode = 'MR-USER-' + randomMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(requesterId)",
        "username": "#(requesterBarcode)",
        "barcode": "#(requesterBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "MRTest", "firstName": "Requester", "email": "mr-test@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

  @CreateSharedInstanceWithItemInUniversity
  Scenario: create instance in central, share to university, create holding and item
    * def okapitoken = centralOkapitoken
    * def instanceTypeId = mrInstanceTypeId
    * def locationId = mrUniLocationId
    * def holdingsSourceId = mrUniHoldingsSourceId
    * def materialTypeId = mrMaterialTypeId
    * def loanTypeId = mrLoanTypeId
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature@CreateItemForSharedInstanceInUniversity')
    * def inventory = call setupInventory { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(instanceTypeId)', locationId: '#(locationId)', holdingsSourceId: '#(holdingsSourceId)', materialTypeId: '#(materialTypeId)', loanTypeId: '#(loanTypeId)', instanceTitle: '#(instanceTitle)' }

  @CreateSharedInstanceWithItemInCollege
  Scenario: create instance in central, share to university and college, create holding and item in college
    * def okapitoken = centralOkapitoken
    * def instanceTypeId = mrInstanceTypeId
    * def locationId = mrCollegeLocationId
    * def holdingsSourceId = mrCollegeHoldingsSourceId
    * def materialTypeId = mrMaterialTypeId
    * def loanTypeId = mrLoanTypeId
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature@CreateItemForSharedInstanceInCollege')
    * def inventory = call setupInventory { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', instanceTypeId: '#(instanceTypeId)', locationId: '#(locationId)', holdingsSourceId: '#(holdingsSourceId)', materialTypeId: '#(materialTypeId)', loanTypeId: '#(loanTypeId)', instanceTitle: '#(instanceTitle)' }
