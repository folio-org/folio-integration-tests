@ignore
Feature: Reusable function to init circulation request. All @Policy ids is being used in @CirculationRules. If policy id has changes, appropriate id in rules need to be changed.

  Background:
    * url baseUrl

  @CreateLoanPolicy
  Scenario: Create loan policy
    * table resourceDetails
      | resourcePath                        | queryVal                               | tenantId |
      | 'loan-policy-storage/loan-policies' | 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231' | tenant   |
    * def exists = call resourceExists resourceDetails
    * if (exists[0].result) karate.abort()

    Given path 'loan-policy-storage/loan-policies'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
        "name": "loanPolicyName",
        "loanable": true,
        "loansPolicy": {
          "profileId": "Rolling",
          "period": {
            "duration": 1,
            "intervalId": "Hours"
          },
          "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
        },
        "renewable": true,
        "renewalsPolicy": {
          "unlimited": false,
          "numberAllowed": 3.0,
          "renewFromId": "SYSTEM_DATE",
          "differentPeriod": false
        }
      }
      """
    When method POST
    Then status 201


  @CreateRequestPolicy
  Scenario: Create request policy
    * table resourceDetails
      | resourcePath                              | queryVal                               | tenantId |
      | 'request-policy-storage/request-policies' | 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231' | tenant   |
    * def exists = call resourceExists resourceDetails
    * if (exists[0].result) karate.abort()

    Given path 'request-policy-storage/request-policies'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
        "name": "requestPolicyName",
        "description": "Allow all request types",
        "requestTypes": [
          "Hold",
          "Page",
          "Recall"
        ]
      }
      """
    When method POST
    Then status 201


  @CreateNoticePolicy
  Scenario: Create notice policy
    * table resourceDetails
      | resourcePath                                          | queryVal                               | tenantId |
      | 'patron-notice-policy-storage/patron-notice-policies' | '122b3d2b-4788-4f1e-9117-56daa91cb75c' | tenant   |
    * def exists = call resourceExists resourceDetails
    * if (exists[0].result) karate.abort()

    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "122b3d2b-4788-4f1e-9117-56daa91cb75c",
        "name": "patronNoticePolicyName",
        "description": "A basic notice policy that does not define any notices",
        "active": true,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": []
      }
      """
    When method POST
    Then status 201


  @CreateOverdueFinePolicy
  Scenario: Create overdue fine policy
    * table resourceDetails
      | resourcePath             | queryVal                               | tenantId |
      | 'overdue-fines-policies' | 'cd3f6cac-fa17-4079-9fae-2fb28e521412' | tenant   |
    * def exists = call resourceExists resourceDetails
    * if (exists[0].result) karate.abort()

    Given path 'overdue-fines-policies'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "cd3f6cac-fa17-4079-9fae-2fb28e521412",
        "name": "overdueFinePolicyName",
        "description": "Test overdue fine policy",
        "countClosed": true,
        "maxOverdueFine": 0.0,
        "forgiveOverdueFine": true,
        "gracePeriodRecall": true,
        "maxOverdueRecallFine": 0.0
      }
      """
    When method POST
    Then status 201


  @CreateLostItemFeesPolicy
  Scenario: Create lost item fees policy
    * table resourceDetails
      | resourcePath              | queryVal                               | tenantId |
      | 'lost-item-fees-policies' | 'ed892c0e-52e0-4cd9-8133-c0ef07b4a709' | tenant   |
    * def exists = call resourceExists resourceDetails
    * if (exists[0].result) karate.abort()

    Given path 'lost-item-fees-policies'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "ed892c0e-52e0-4cd9-8133-c0ef07b4a709",
        "name": "lostItemFeesPolicyName",
        "description": "Test lost item fee policy",
        "chargeAmountItem": {
          "chargeType": "actualCost",
          "amount": 0.0
        },
        "lostItemProcessingFee": 0.0,
        "chargeAmountItemPatron": true,
        "chargeAmountItemSystem": true,
        "lostItemChargeFeeFine": {
          "duration": 2,
          "intervalId": "Days"
        },
        "returnedLostItemProcessingFee": true,
        "replacedLostItemProcessingFee": true,
        "replacementProcessingFee": 0.0,
        "replacementAllowed": true,
        "lostItemReturned": "Charge"
      }
      """
    When method POST
    Then status 201


  @CirculationRules
  Scenario: Update circulation rules
    Given path 'circulation/rules'
    And header x-okapi-tenant = tenant
    And request
      """
      {
        "id": "1721f01b-e69d-5c4c-5df2-523428a04c55",
        "rulesAsText": "priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709 \nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
      }
      """
    When method PUT
    Then status 204