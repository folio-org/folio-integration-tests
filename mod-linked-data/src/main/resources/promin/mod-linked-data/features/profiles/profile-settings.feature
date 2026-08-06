Feature: Get and set profile settings

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Get default profile settings returns empty array when no settings stored
    Given path 'linked-data/profile/3/settings'
    When method GET
    Then status 200

    * match response == []

  @Positive
  Scenario: Set profile settings and verify they are returned on get
    * def monographProfileId = 3
    * def settingsRequest = { "active": true, "name": "my settings name", "children": [{ "id": "ld:Instance:Title", "visible": true, "order": 1 }] }

    # Set profile settings
    Given path 'linked-data/profile/' + monographProfileId + '/settings'
    And request settingsRequest
    When method POST
    Then status 201
    And match $.id == '#present'
    * def profileSettingsId = $.id

    # Get profile settings and verify they are returned
    Given path 'linked-data/profile/' + monographProfileId + '/settings/' + profileSettingsId
    When method GET
    Then status 200

    * match response.id == profileSettingsId
    * match response.profileId == monographProfileId
    * match response.active == true
    * match response.name == 'my settings name'

    * def titleChild = karate.filter(response.children, function(x){ return x.id == 'ld:Instance:Title' })[0]
    * match titleChild.visible == true
    * match titleChild.order == 1
