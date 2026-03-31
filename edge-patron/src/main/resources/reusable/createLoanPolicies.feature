@ignore
Feature: Create loan policies

  Background:
    * url baseUrl
    * def samplesPath = 'classpath:vega/edge-patron/features/samples/policies/'

  Scenario: create policies
    * def loanPolicyId = call uuid
    * def lostItemFeePolicyId = call uuid
    * def overdueFinePoliciesId = call uuid
    * def patronPolicyId = call uuid
    * def requestPolicyId = call uuid
    * def loanPolicyEntityRequest = read(samplesPath + 'loan-policy-entity-request.json')

    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

    * def lostItemFeePolicyEntityRequest = read(samplesPath + 'lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.name = lostItemFeePolicyEntityRequest.name + ' ' + random_string()

    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

    * def overdueFinePolicyEntityRequest = read(samplesPath + 'overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' ' + random_string()

    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

    * def patronNoticePolicyEntityRequest = read(samplesPath + 'patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.name = patronNoticePolicyEntityRequest.name + ' ' + random_string()

    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def policyEntityRequest = read(samplesPath + 'request-policy-entity-request-for-all-types.json')
    * policyEntityRequest.name = policyEntityRequest.name + ' ' + random_string()

    Given path 'request-policy-storage/request-policies'
    And request policyEntityRequest
    When method POST
    Then status 201

    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronPolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }

    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204
