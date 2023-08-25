Feature: init data for mod-circulation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @PostServicePoint
  Scenario: create service point
    * def id = call uuid1
    * def servicePoint = read('samples/service-point.json')
    * servicePoint.id = karate.get('extId', id)
    * servicePoint.name = servicePoint.name + ' ' + random_string()
    * servicePoint.code = servicePoint.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePoint
    When method POST
    Then status 201

  @PostServicePointNonPickupLocation
  Scenario: create service point
    * def id = call uuid1
    * def servicePoint = read('samples/service-point.json')
    * servicePoint.id = karate.get('extId', id)
    * servicePoint.name = servicePoint.name + ' ' + random_string()
    * servicePoint.code = servicePoint.code + ' ' + random_string()
    * servicePoint.pickupLocation = false
    * remove servicePoint.holdShelfExpiryPeriod
    Given path 'service-points'
    And request servicePoint
    When method POST
    Then status 201

  @PostRequestPolicy
  Scenario: create request policy
    * def requestPolicyId = call uuid1
    * def requestTypes = ["Hold", "Page", "Recall"]

    * def requestPolicy = read('samples/policies/request-policy.json')
    * requestPolicy.id = karate.get('extId', requestPolicyId)
    * requestPolicy.name = requestPolicy.name + ' ' + random_string()
    * requestPolicy.requestTypes = karate.get('extRequestTypes', requestTypes)
    * requestPolicy.allowedServicePoints = karate.get('extAllowedServicePoints', null)
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201
