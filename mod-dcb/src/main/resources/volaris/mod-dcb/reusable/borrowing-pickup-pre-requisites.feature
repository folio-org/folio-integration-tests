Feature: borrwing pickup pre-requisites

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser

      # load global variables
    * callonce variables

#  @CreateLoanPolicy
#  Scenario: Create loan policy
#    Given path 'loan-policy-storage/loan-policies'
#    And request
#    """
#    {
#    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
#    "name": "loanPolicyName",
#    "loanable": true,
#    "loansPolicy": {
#        "profileId": "Rolling",
#        "period": {
#            "duration": 1,
#            "intervalId": "Hours"
#        },
#        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
#    },
#    "renewable": true,
#    "renewalsPolicy": {
#        "unlimited": false,
#        "numberAllowed": 3.0,
#        "renewFromId": "SYSTEM_DATE",
#        "differentPeriod": false
#    }
#    }
#    """
#    When method POST
#
#  @CreateRequestPolicy
#  Scenario: Create request policy
#    Given path 'request-policy-storage/request-policies'
#    And request
#    """
#    {
#    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
#    "name": "requestPolicyName",
#    "description": "Allow all request types",
#    "requestTypes": [
#        "Hold",
#        "Page",
#        "Recall"
#    ]
#    }
#    """
#    When method POST
#  @CreateNoticePolicy
#  Scenario: Create notice policy
#    Given path 'patron-notice-policy-storage/patron-notice-policies'
#    And request
#    """
#    {
#    "id": "122b3d2b-4788-4f1e-9117-56daa91cb75c",
#    "name": "patronNoticePolicyName",
#    "description": "A basic notice policy that does not define any notices",
#    "active": true,
#    "loanNotices": [],
#    "feeFineNotices": [],
#    "requestNotices": []
#    }
#    """
#    When method POST
#
#  @CreateOverdueFinePolicy
#  Scenario: Create overdue fine policy
#    Given path 'overdue-fines-policies'
#    And request
#    """
#    {
#    "name": "overdueFinePolicyName",
#    "description": "Test overdue fine policy",
#    "countClosed": true,
#    "maxOverdueFine": 0.0,
#    "forgiveOverdueFine": true,
#    "gracePeriodRecall": true,
#    "maxOverdueRecallFine": 0.0,
#    "id": "cd3f6cac-fa17-4079-9fae-2fb28e521412"
#    }
#    """
#    When method POST
#
#  @CreateLostItemFeesPolicy
#  Scenario: Create lost item fees policy
#    Given path 'lost-item-fees-policies'
#    And request
#    """
#    {
#    "name": "lostItemFeesPolicyName",
#    "description": "Test lost item fee policy",
#    "chargeAmountItem": {
#        "chargeType": "actualCost",
#        "amount": 0.0
#    },
#    "lostItemProcessingFee": 0.0,
#    "chargeAmountItemPatron": true,
#    "chargeAmountItemSystem": true,
#    "lostItemChargeFeeFine": {
#        "duration": 2,
#        "intervalId": "Days"
#    },
#    "returnedLostItemProcessingFee": true,
#    "replacedLostItemProcessingFee": true,
#    "replacementProcessingFee": 0.0,
#    "replacementAllowed": true,
#    "lostItemReturned": "Charge",
#    "id": "ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
#    }
#    """
#    When method POST
#
#  @CirculationRules
#  Scenario: Update circulation rules
#    Given path 'circulation/rules'
#    And request
#    """
#    {
#    "id": "1721f01b-e69d-5c4c-5df2-523428a04c55",
#    "rulesAsText": "priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709 \nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
#    }
#    """
#    When method PUT
#
#  @PostMaterialType
#  Scenario: create material type
#    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
#    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
#    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', materialTypeName)
#    Given path 'material-types'
#    And request materialTypeEntityRequest
#    When method POST
#    Then status 201

#  @PostGroup
#  Scenario: Create Group
#    * def groupEntityRequest = read('classpath:volaris/mod-dcb/features/samples/patron/create-patronGroup-request.json')
#    Given path 'groups'
#    And request groupEntityRequest
#    When method POST
#    Then status 201


  @PostUser
  Scenario: Create User
    * def intUserId = '8b83f6b6-77b3-11ee-b962-0242ac120003'
    * def intBarcode = 'testuser123'
    * def userEntityRequest = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest.id = karate.get('extUserId1', intUserId)
    * userEntityRequest.barcode = karate.get('patronBarcode1', intBarcode)
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201