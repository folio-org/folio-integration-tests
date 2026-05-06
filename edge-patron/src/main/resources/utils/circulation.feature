@parallel=false
Feature: Create circulation policies and rules

  Background:
    * url baseUrl

  Scenario: Create circulation policies and rules for central tenant
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }
    * def circulationLoanPolicyId = call uuid
    * def circulationLostItemFeePolicyId = call uuid
    * def circulationOverdueFinePoliciesId = call uuid
    * def circulationPatronPolicyId = call uuid
    * def circulationRequestPolicyId = call uuid

    * def loanPolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/loan-policy-entity-request.json')
    * loanPolicyEntityRequest.id = circulationLoanPolicyId

    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

    * def lostItemFeePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.id = circulationLostItemFeePolicyId
    * lostItemFeePolicyEntityRequest.name = lostItemFeePolicyEntityRequest.name + ' consortia'

    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

    * def overdueFinePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.id = circulationOverdueFinePoliciesId
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' consortia'

    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

    * def patronNoticePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.id = circulationPatronPolicyId
    * patronNoticePolicyEntityRequest.name = patronNoticePolicyEntityRequest.name + ' consortia'

    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def requestPolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/request-policy-entity-request.json')
    * requestPolicyEntityRequest.id = circulationRequestPolicyId
    * requestPolicyEntityRequest.name = requestPolicyEntityRequest.name + ' consortia'

    Given path 'request-policy-storage/request-policies'
    And request requestPolicyEntityRequest
    When method POST
    Then status 201

    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + circulationLoanPolicyId + ' o ' + circulationOverdueFinePoliciesId + ' i ' + circulationLostItemFeePolicyId + ' r ' + circulationRequestPolicyId + ' n ' + circulationPatronPolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }

    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # Enable TLR for central tenant via configurations/entries (legacy)
    * def tlrConfigId = call uuid
    * def tlrConfigEntry = { id: '#(tlrConfigId)', module: 'SETTINGS', configName: 'TLR', value: '{"titleLevelRequestsFeatureEnabled":true,"tlrHoldShouldFollowCirculationRules":false,"createTitleLevelRequestsByDefault":false}' }
    Given path 'configurations/entries'
    And request tlrConfigEntry
    When method POST
    Then match [201, 422] contains responseStatus

    # Enable TLR for central tenant via circulation/settings (new API)
    * def centralTlrSettingsId = call uuid
    * def centralTlrSettingsRequest = { id: '#(centralTlrSettingsId)', name: 'TLR', value: { titleLevelRequestsFeatureEnabled: true, tlrHoldShouldFollowCirculationRules: false, createTitleLevelRequestsByDefault: false } }
    Given path 'circulation/settings'
    And request centralTlrSettingsRequest
    When method POST
    Then match [201, 422] contains responseStatus

  Scenario: Create circulation policies and rules for university tenant
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': '*/*' }
    * def uniCirculationLoanPolicyId = call uuid
    * def uniCirculationLostItemFeePolicyId = call uuid
    * def uniCirculationOverdueFinePoliciesId = call uuid
    * def uniCirculationPatronPolicyId = call uuid
    * def uniCirculationRequestPolicyId = call uuid

    * def loanPolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/loan-policy-entity-request.json')
    * loanPolicyEntityRequest.id = uniCirculationLoanPolicyId

    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

    * def lostItemFeePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.id = uniCirculationLostItemFeePolicyId
    * lostItemFeePolicyEntityRequest.name = lostItemFeePolicyEntityRequest.name + ' uni consortia'

    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

    * def overdueFinePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.id = uniCirculationOverdueFinePoliciesId
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' uni consortia'

    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

    * def patronNoticePolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.id = uniCirculationPatronPolicyId
    * patronNoticePolicyEntityRequest.name = patronNoticePolicyEntityRequest.name + ' uni consortia'

    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def requestPolicyEntityRequest = read('classpath:vega/edge-patron/features/samples/policies/request-policy-entity-request.json')
    * requestPolicyEntityRequest.id = uniCirculationRequestPolicyId
    * requestPolicyEntityRequest.name = requestPolicyEntityRequest.name + ' uni consortia'

    Given path 'request-policy-storage/request-policies'
    And request requestPolicyEntityRequest
    When method POST
    Then status 201

    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + uniCirculationLoanPolicyId + ' o ' + uniCirculationOverdueFinePoliciesId + ' i ' + uniCirculationLostItemFeePolicyId + ' r ' + uniCirculationRequestPolicyId + ' n ' + uniCirculationPatronPolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }

    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # Enable TLR for university tenant via configurations/entries (legacy)
    * def uniTlrConfigId = call uuid
    * def uniTlrConfigEntry = { id: '#(uniTlrConfigId)', module: 'SETTINGS', configName: 'TLR', value: '{"titleLevelRequestsFeatureEnabled":true,"tlrHoldShouldFollowCirculationRules":false,"createTitleLevelRequestsByDefault":false}' }
    Given path 'configurations/entries'
    And request uniTlrConfigEntry
    When method POST
    Then match [201, 422] contains responseStatus

    # Enable TLR for university tenant via circulation/settings (new API)
    * def uniTlrSettingsId = call uuid
    * def uniTlrSettingsRequest = { id: '#(uniTlrSettingsId)', name: 'TLR', value: { titleLevelRequestsFeatureEnabled: true, tlrHoldShouldFollowCirculationRules: false, createTitleLevelRequestsByDefault: false } }
    Given path 'circulation/settings'
    And request uniTlrSettingsRequest
    When method POST
    Then match [201, 422] contains responseStatus

    # Re-login to central tenant to restore okapitoken for subsequent operations
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
