Feature: Print events tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = headersUser
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')

  Scenario: Save a print events log when no circulation setting found

        * def id = call uuid1
        Given path 'circulation', 'settings'
        And request
          """
          {
            "id": "#(id)",
            "name": "Enable Print event log",
            "value": {
              "Enable print log": "true"
            }
          }
          """
        When method POST
        Then status 201

      Given path 'circulation', 'settings'
      And param query = '(name=Enable Print event log)'
      When method GET
      Then status 200

        * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
      * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
      * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
      * printEventsRequest.requesterName = 'sreeja'
      And request printEventsRequest
      Given path 'circulation', 'print-events-entry'
      When method POST
      And match response == null
      Then status 422


#  Scenario: Save a print events log when duplicate circulation setting found
#    * def id = call uuid1
#    Given path 'circulation', 'settings'
#    And request
#      """
#      {
#        "id": "#(id)",
#        "name": "Enable Print event log",
#        "value": {
#          "Enable print log": "true"
#        }
#      }
#      """
#    When method POST
#    Then status 201
#
#    * def id = call uuid1
#    Given path 'circulation', 'settings'
#    And request
#      """
#      {
#        "id": "#(id)",
#        "name": "Enable Print event log",
#        "value": {
#          "Enable-print-log": "true"
#        }
#      }
#      """
#    When method POST
#    Then status 201
#
#    Given path 'circulation', 'print-events-entry'
#    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
#    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
#    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
#    * printEventsRequest.requesterName = 'sreeja'
#    And request printEventsRequest
#    When method POST
#    Then status 422
#
#  Scenario: Save a print events log when printevent setting flag is disabled
#    * def id = call uuid1
#    Given path 'circulation', 'settings'
#    And request
#      """
#      {
#        "id": "#(id)",
#        "name": "Enable Print event log",
#        "value": {
#          "Enable print log": "false"
#        }
#      }
#      """
#    When method POST
#    Then status 201
#
#    Given path 'circulation', 'print-events-entry'
#    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
#    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
#    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
#    * printEventsRequest.requesterName = 'sreeja'
#    And request printEventsRequest
#    When method POST
#    Then status 422

#    * def extItemId = call uuid1
#    * def extUserId = call uuid1
#    * def extLocationId = call uuid1
#    * def extItemBarcode = 'FAT-1043IBC'
#    * def extUserBarcode = 'FAT-1043UBC'
#    * def extServicePointId = call uuid1
#    * def extLocationId = call uuid1
#    * def extHoldingId = call uuid1
#    * def extHoldingSourceId = call uuid1
#    * def extHoldingSourceName = call random_string
#
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId) }
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }
#
#    # post an item
#    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }
#
#    # post an user
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }
#
#    # post a request
#    * def extRequestId = call uuid1
#    * def extRequestType = 'Page'
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePoint) }
#
#
#    Given path 'circulation', 'print-events-entry'
#    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
#    And request printEventsRequest
#    When method PUT
#    Then status 201















