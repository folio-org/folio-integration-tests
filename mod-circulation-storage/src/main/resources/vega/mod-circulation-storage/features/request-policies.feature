Feature: Tests for Request Policies API

  Background:
    * url baseUrl

  Scenario: Allowed service points are validated before request policy creation/update
    * def requestPolicyId = call uuid1
    * def servicePointId1 = call uuid1
    * def servicePointId2 = call uuid1
    * def servicePointId3 = call uuid1

    # create service points
    * def postServicePointResponse1 = call read('classpath:vega/mod-circulation-storage/features/util/init-data.feature@PostServicePoint') { extId: #(servicePointId1) }
    * def postServicePointResponse2 = call read('classpath:vega/mod-circulation-storage/features/util/init-data.feature@PostServicePointNonPickupLocation') { extId: #(servicePointId2) }
    * def postServicePointResponse3 = call read('classpath:vega/mod-circulation-storage/features/util/init-data.feature@PostServicePointNonPickupLocation') { extId: #(servicePointId3) }

    # attempt to create a request policy, should fail because service point 2 is not a pickup location
    * def requestPolicy = read('samples/policies/request-policy.json')
    * requestPolicy.id = requestPolicyId
    * requestPolicy.name = requestPolicy.name + ' ' + random_string()
    * requestPolicy.requestTypes = ['Hold', 'Recall']
    * requestPolicy.allowedServicePoints = {'Hold' : [servicePointId1, servicePointId2] }
    Given path 'request-policy-storage', 'request-policies'
    And request requestPolicy
    When method POST
    Then status 422
    And match response.errors == '#[1]'
    * def error = response.errors[0]
    And match error.message == 'Service point is not a pickup location'
    And match error.code == 'INVALID_ALLOWED_SERVICE_POINT'
    And match error.parameters == '#[1]'
    And match error.parameters[0].key contains 'servicePointId'
    And match error.parameters[0].value contains servicePointId2

    # make service point #2 a pickup location
    * def servicePoint2 = postServicePointResponse2.response
    * servicePoint2.pickupLocation = true
    * servicePoint2.holdShelfExpiryPeriod = {'duration': 1, 'intervalId': 'Hours'}
    Given path 'service-points', servicePointId2
    And request servicePoint2
    When method PUT
    Then status 204

    # attempt to create the request policy again, should succeed because service point #2 is now a pickup location
    Given path 'request-policy-storage', 'request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # allow service point #3, which is not a pickup location
    * requestPolicy.allowedServicePoints = {'Hold' : [servicePointId1, servicePointId2, servicePointId3] }

    # attempt to update request policy, should fail because service point 3 is not a pickup location
    Given path 'request-policy-storage', 'request-policies', requestPolicyId
    And request requestPolicy
    When method PUT
    Then status 422
    And match response.errors == '#[1]'
    * def error = response.errors[0]
    And match error.message == 'Service point is not a pickup location'
    And match error.code == 'INVALID_ALLOWED_SERVICE_POINT'
    And match error.parameters == '#[1]'
    And match error.parameters[0].key contains 'servicePointId'
    And match error.parameters[0].value contains servicePointId3

    # allow a non-existent service point for recall requests
    * def nonExistentServicePointId = call uuid1
    * requestPolicy.allowedServicePoints = {'Hold' : [servicePointId1, servicePointId2, servicePointId3], 'Recall' : [nonExistentServicePointId] }

    # attempt to update request policy, should fail with multiple errors
    Given path 'request-policy-storage', 'request-policies', requestPolicyId
    And request requestPolicy
    When method PUT
    Then status 422
    And match response.errors == '#[2]'
    And match response.errors[*] contains {'message': 'Service point does not exist', 'code': 'INVALID_ALLOWED_SERVICE_POINT', parameters: [ { 'key': 'servicePointId', 'value': #(nonExistentServicePointId) } ] }
    And match response.errors[*] contains {'message': 'Service point is not a pickup location', 'code': 'INVALID_ALLOWED_SERVICE_POINT', parameters: [ { 'key': 'servicePointId', 'value': #(servicePointId3) } ] }