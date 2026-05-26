@ignore
Feature: Setup circulation policies and TLR setting for a tenant

  # Parameters:
  #   tenant      - tenant name (x-okapi-tenant)
  #   okapitoken  - valid token for the tenant
  #   loanPolicyName, lostItemPolicyName, overdueFinePolicyName, patronNoticePolicyName, requestPolicyName
  #   (all names are optional — defaults are derived from tenant)

  Background:
    * url baseUrl

  Scenario: create circulation policies, set rules and enable TLR
    * def policyLabel = karate.get('policyLabel', tenant)

    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)' }

    * def loanPolicyId = uuid()
    Given path 'loan-policy-storage/loan-policies'
    And request
      """
      {
        "id": "#(loanPolicyId)",
        "name": "ECS Loan Policy #(policyLabel)",
        "loanable": true,
        "loansPolicy": {
          "profileId": "Rolling",
          "period": { "duration": 1, "intervalId": "Months" },
          "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
        },
        "renewable": true,
        "renewalsPolicy": {
          "unlimited": false,
          "numberAllowed": 3,
          "renewFromId": "CURRENT_DUE_DATE",
          "differentPeriod": false
        }
      }
      """
    When method POST
    Then status 201

    * def lostItemFeePolicyId = uuid()
    Given path 'lost-item-fees-policies'
    And request
      """
      {
        "id": "#(lostItemFeePolicyId)",
        "name": "ECS Lost Item Fee Policy #(policyLabel)",
        "itemAgedLostOverdue": { "duration": 1, "intervalId": "Months" },
        "patronBilledAfterAgedLost": { "duration": 1, "intervalId": "Months" },
        "lostItemChargeFeeFine": { "duration": 6, "intervalId": "Months" },
        "chargeAmountItem": { "amount": 0.00, "chargeType": "actualCost" },
        "lostItemProcessingFee": 0.00,
        "chargeAmountItemPatron": true,
        "chargeAmountItemSystem": true,
        "lostItemReturned": "Charge",
        "replacedLostItemProcessingFee": true,
        "replacementProcessingFee": 0.00,
        "replacementAllowed": true
      }
      """
    When method POST
    Then status 201

    * def overdueFinePolicyId = uuid()
    Given path 'overdue-fines-policies'
    And request
      """
      {
        "id": "#(overdueFinePolicyId)",
        "name": "ECS Overdue Fine Policy #(policyLabel)",
        "overdueFine": { "quantity": 0.00, "intervalId": "hour" },
        "overdueRecallFine": { "quantity": 0.00, "intervalId": "hour" },
        "gracePeriodRecall": false,
        "maxOverdueFine": 0.00,
        "forgiveOverdueFine": false,
        "maxOverdueRecallFine": 0.00
      }
      """
    When method POST
    Then status 201

    * def patronNoticePolicyId = uuid()
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
      """
      {
        "id": "#(patronNoticePolicyId)",
        "name": "ECS Patron Notice Policy #(policyLabel)",
        "active": false,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": []
      }
      """
    When method POST
    Then status 201

    * def requestPolicyId = uuid()
    Given path 'request-policy-storage/request-policies'
    And request
      """
      {
        "id": "#(requestPolicyId)",
        "name": "ECS Request Policy #(policyLabel)",
        "requestTypes": ["Hold", "Page", "Recall"]
      }
      """
    When method POST
    Then status 201

    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    Given path 'circulation-rules-storage'
    And request { "rulesAsText": "#(rules)" }
    When method PUT
    Then status 204

    * def tlrSettingsId = uuid()
    Given path 'circulation/settings'
    And request { id: '#(tlrSettingsId)', name: 'TLR', value: { titleLevelRequestsFeatureEnabled: true, tlrHoldShouldFollowCirculationRules: false, createTitleLevelRequestsByDefault: false } }
    When method POST
    Then match [201, 422] contains responseStatus

