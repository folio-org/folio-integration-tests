Feature: Get Profile by ID

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Get profile by id 2 and verify Profile:Work entry
    Given path 'linked-data/profile/2'
    When method GET
    Then status 200

    * def profileWork = karate.filter(response, function(x){ return x.id == 'Profile:Work' })[0]

    * match profileWork.id == 'Profile:Work'
    * match profileWork.bfid == 'lde:Profile:Work'
    * match profileWork.type == 'block'
    * match profileWork.uriBFLite == 'http://bibfra.me/vocab/lite/Work'
    * match profileWork.displayName == 'Work components - Books'

  @Positive
  Scenario: Get profile by id 3 and verify Profile:Instance entry
    Given path 'linked-data/profile/3'
    When method GET
    Then status 200

    * def profileInstance = karate.filter(response, function(x){ return x.id == 'Profile:Instance' })[0]

    * match profileInstance.id == 'Profile:Instance'
    * match profileInstance.bfid == 'lde:Profile:Instance'
    * match profileInstance.type == 'block'
    * match profileInstance.uriBFLite == 'http://bibfra.me/vocab/lite/Instance'
    * match profileInstance.displayName == 'Instance components - Monographs'

  @Positive
  Scenario: Get profile by id 4 and verify Profile:Instance entry
    Given path 'linked-data/profile/4'
    When method GET
    Then status 200

    * def profileInstance = karate.filter(response, function(x){ return x.id == 'Profile:Instance' })[0]

    * match profileInstance.id == 'Profile:Instance'
    * match profileInstance.bfid == 'lde:Profile:Instance'
    * match profileInstance.type == 'block'
    * match profileInstance.uriBFLite == 'http://bibfra.me/vocab/lite/Instance'
    * match profileInstance.displayName == 'Instance components - Rare Books'

  @Positive
  Scenario: Get profile by id 5 and verify Profile:Instance entry
    Given path 'linked-data/profile/5'
    When method GET
    Then status 200

    * def profileInstance = karate.filter(response, function(x){ return x.id == 'Profile:Instance' })[0]

    * match profileInstance.id == 'Profile:Instance'
    * match profileInstance.bfid == 'lde:Profile:Instance'
    * match profileInstance.type == 'block'
    * match profileInstance.uriBFLite == 'http://bibfra.me/vocab/lite/Instance'
    * match profileInstance.displayName == 'Instance components - Serials'

  @Positive
  Scenario: Get profile by id 6 and verify Profile:Work entry
    Given path 'linked-data/profile/6'
    When method GET
    Then status 200

    * def profileWork = karate.filter(response, function(x){ return x.id == 'Profile:Work' })[0]

    * match profileWork.id == 'Profile:Work'
    * match profileWork.bfid == 'lde:Profile:Work'
    * match profileWork.type == 'block'
    * match profileWork.uriBFLite == 'http://bibfra.me/vocab/lite/Work'
    * match profileWork.displayName == 'Work components - Serials'

  @Positive
  Scenario: Get profile by id 7 and verify Profile:Hub entry
    * configure headers = testUserHeaders

    Given path 'linked-data/profile/7'
    When method GET
    Then status 200

    * def profileHub = karate.filter(response, function(x){ return x.id == 'Profile:Hub' })[0]

    * match profileHub.id == 'Profile:Hub'
    * match profileHub.bfid == 'lde:Profile:Hub'
    * match profileHub.type == 'block'
    * match profileHub.uriBFLite == 'http://bibfra.me/vocab/lite/Hub'
    * match profileHub.displayName == 'Hub components'
