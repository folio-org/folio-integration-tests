Feature: Get and set profile settings

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Get default profile settings returns inactive response when no settings stored
    Given path 'linked-data/profile/settings/3'
    When method GET
    Then status 200

    * match response.profileId == 3
    * match response.active == false
    * match response.children == '#notpresent'

  @Positive
  Scenario: Set profile settings and verify they are returned on get
    * def monographProfileId = 3
    * def settingsRequest = { "active": true, "children": [{ "id": "ld:Instance:Title", "visible": true, "order": 1 }] }

    # Set profile settings
    Given path 'linked-data/profile/settings/' + monographProfileId
    And request settingsRequest
    When method POST
    Then status 204

    # Get profile settings and verify they are returned
    Given path 'linked-data/profile/settings/' + monographProfileId
    When method GET
    Then status 200

    * match response.profileId == monographProfileId
    * match response.active == true

    * def titleChild = karate.filter(response.children, function(x){ return x.id == 'ld:Instance:Title' })[0]
    * match titleChild.visible == true
    * match titleChild.order == 1
