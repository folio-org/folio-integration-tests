@parallel=false
Feature: BORROWING-PICKUP | Update transaction with shadow location and patron notice verification

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }
    * configure headers = headersAdmin
    * callonce variables
    * configure retry = { count: 10, interval: 1000 }

    * def cancelNoticeGroupId = 'c1307938-0001-4000-8000-c1307938ff03'
    * def cancelNoticePatronId = 'c1307938-0001-4000-8000-c1307938ff04'
    * def cancelNoticeTemplateId = 'c1307938-0001-4000-8000-c1307938ff01'
    * def cancelNoticePolicyId = 'c1307938-0001-4000-8000-c1307938ff02'
    * def cancelNoticeAgencyCode = 'CANCEL-NTC'
    * def cancelNoticeTemplateHeader = 'Request Cancelled Notice'

    Given path 'groups'
    And request { id: '#(cancelNoticeGroupId)', group: 'Cancel Notice Group', desc: 'Test group for cancel notice' }
    When method POST
    Then status 201

    Given path 'users'
    And request
      """
      {
        "active": true,
        "departments": [],
        "id": "#(cancelNoticePatronId)",
        "patronGroup": "#(cancelNoticeGroupId)",
        "barcode": "cancel-notice-patron",
        "personal": {
          "email": "cancel-notice@test.com",
          "firstName": "CancelNotice",
          "lastName": "TestUser",
          "preferredContactTypeId": "002"
        }
      }
      """
    When method POST
    Then status 201

    # Create patron notice template (category=Request, contains {{item.barcode}} and {{request.reasonForCancellation}})
    Given path 'templates'
    And request
      """
      {
        "id": "#(cancelNoticeTemplateId)",
        "name": "Cancel Request Notice Template",
        "active": true,
        "category": "Request",
        "localizedTemplates": {
          "en": {
            "header": "#(cancelNoticeTemplateHeader)",
            "body": "request is cancelled:\nitem.barcode - {{item.barcode}}\nrequest.reasonForCancellation - {{request.reasonForCancellation}}"
          }
        },
        "outputFormats": ["text/html"],
        "templateResolver": "mustache"
      }
      """
    When method POST
    Then status 201

    # Create patron notice policy: active, request notices, sendWhen=Cancel request, format=Email
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
      """
      {
        "id": "#(cancelNoticePolicyId)",
        "name": "Cancel Request Notice Policy",
        "description": "Patron notice policy: fires on cancel request",
        "active": true,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": [
          {
            "name": "Cancel Request Notice",
            "templateId": "#(cancelNoticeTemplateId)",
            "format": "Email",
            "realTime": true,
            "sendOptions": {
              "sendWhen": "Request cancellation"
            }
          }
        ]
      }
      """
    When method POST
    Then status 201

    Given path '/dcb/shadow-locations/refresh'
    And request { agencies: [ { name: 'Cancel Notice Shadow Agency', code: '#(cancelNoticeAgencyCode)' } ] }
    When method POST
    Then status 201
    And match $.locations[*].code contains only ['#(cancelNoticeAgencyCode)']
    And match $.locations[*].status contains only ['SUCCESS']

    Given path 'locations'
    And param query = 'code=="' + cancelNoticeAgencyCode + '"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.locations[0].isShadow == true
    * def cancelNoticeShadowLocationId = $.locations[0].id

    Given path 'locations'
    And param query = 'name=="DCB" and code=="000"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.locations[0].isShadow == false
    * def cancelNoticeDefaultDcbLocationId = $.locations[0].id

    Given path 'circulation/rules'
    When method GET
    Then status 200
    * def currentRulesText = response.rulesAsText
    * def cancelNoticeRule = '\ng ' + cancelNoticeGroupId + ': l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n ' + cancelNoticePolicyId + ' o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def updatedRulesText = currentRulesText + cancelNoticeRule

    Given path 'circulation/rules'
    And request { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(updatedRulesText)' }
    When method PUT
    Then status 204

    * def startDate = call getCurrentUtcDate

  @C1307938
  Scenario: Update BORROWING-PICKUP transaction - shadow location is applied and patron notice fires only on explicit cancellation

    * def dcbTransactionId = call uuid1
    * def initialItemBarcode = 'borrowing-pickup-item-' + random_string()

    Given path '/transactions/' + dcbTransactionId
    And request
      """
      {
        "item": {
          "title": "Borrowing Pickup Test Book",
          "barcode": "#(initialItemBarcode)",
          "materialType": "namebook",
          "lendingLibraryCode": "LEND-KU"
        },
        "patron": {
          "id": "#(cancelNoticePatronId)",
          "barcode": "cancel-notice-patron"
        },
        "pickup": {
          "servicePointId": "#(servicePointId21)"
        },
        "role": "BORROWING-PICKUP"
      }
      """
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == initialItemBarcode
    And match $.patron.id == cancelNoticePatronId
    * def initialVirtualItemId = $.item.id

    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + initialItemBarcode + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].requestType == 'Hold'
    And match $.requests[0].status == 'Open - Not yet filled'
    * def initialRequestId = $.requests[0].id

    Given path 'circulation-item', initialVirtualItemId
    When method GET
    Then status 200
    And match $.effectiveLocationId == cancelNoticeDefaultDcbLocationId

    * def updatedItemBarcode = 'borrowing-pickup-updated-' + random_string()

    Given path '/transactions/' + dcbTransactionId
    And request
      """
      {
        "item": {
          "barcode": "#(updatedItemBarcode)",
          "materialType": "namebook",
          "lendingLibraryCode": "#(cancelNoticeAgencyCode)"
        }
      }
      """
    When method PUT
    Then status 204

    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + updatedItemBarcode + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].requestType == 'Hold'
    And match $.requests[0].status == 'Open - Not yet filled'
    * def updatedRequestId = $.requests[0].id
    * def updatedHoldingsRecordId = $.requests[0].holdingsRecordId
    * def updatedInstanceId = $.requests[0].instanceId
    * def updatedRequestType = $.requests[0].requestType
    * def updatedItemId = $.requests[0].itemId
    And match updatedRequestId != initialRequestId

    Given path 'circulation-item', updatedItemId
    When method GET
    Then status 200
    And match $.effectiveLocationId == cancelNoticeShadowLocationId

    Given path 'circulation', 'requests', initialRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'
    And match $.requestType == 'Hold'
    And match $.item.barcode == initialItemBarcode
    And match $.item.itemEffectiveLocationId == cancelNoticeDefaultDcbLocationId

    * call pause 10000
    Given path 'email'
    And param query = 'to=cancel-notice@test.com and header=' + cancelNoticeTemplateHeader
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * call pause 5000
    * def endDate = call getCurrentUtcDate
    Given path '/transactions/status'
    And param fromDate = startDate
    And param toDate = endDate
    And param pageSize = 50
    And param pageNumber = 0
    When method GET
    Then status 200
    * def createdTransactions = karate.jsonPath(response, "$.transactions[?(@.id == '" + dcbTransactionId + "' && @.status == 'CREATED')]")
    And match createdTransactions == '#[1]'
    And match createdTransactions[0].item.barcode == updatedItemBarcode
    And match createdTransactions[0].item.lendingLibraryCode == cancelNoticeAgencyCode
    And match createdTransactions[0].item.materialType == 'namebook'
    And match createdTransactions[0].patron.id == cancelNoticePatronId
    And match createdTransactions[0].pickup.servicePointId == servicePointId21
    And match createdTransactions[0].role == 'BORROWING-PICKUP'
    * def cancelledTransactions = karate.jsonPath(response, "$.transactions[?(@.id == '" + dcbTransactionId + "' && @.status == 'CANCELLED')]")
    And match cancelledTransactions == '#[_ > 0]'

    * def cancelRequestBody = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestBody.cancellationReasonId = cancellationReasonId
    * cancelRequestBody.cancelledByUserId = cancelNoticePatronId
    * cancelRequestBody.requesterId = cancelNoticePatronId
    * cancelRequestBody.requestLevel = 'Item'
    * cancelRequestBody.requestType = updatedRequestType
    * cancelRequestBody.holdingsRecordId = updatedHoldingsRecordId
    * cancelRequestBody.instanceId = updatedInstanceId
    * cancelRequestBody.itemId = updatedItemId
    * cancelRequestBody.pickupServicePointId = servicePointId21
    * cancelRequestBody.status = 'Closed - Cancelled'
    * cancelRequestBody.id = updatedRequestId

    Given path 'circulation', 'requests', updatedRequestId
    And request cancelRequestBody
    When method PUT
    Then status 204
    * call pause 5000

    Given path 'circulation', 'requests', updatedRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    * call pause 15000
    Given path 'email'
    And param query = 'to=cancel-notice@test.com and header=' + cancelNoticeTemplateHeader
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.emailEntity[0].body contains updatedItemBarcode
