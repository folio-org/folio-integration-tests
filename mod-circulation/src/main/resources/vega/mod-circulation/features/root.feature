Feature: Root feature that runs all other mod-circulation features

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def materialTypeId = call uuid1
    * def materialTypeName = 'e-book'
    * def requestPolicyIdForGroup = call uuid1
    * def requestPolicyIdForGroup2 = call uuid1
    * def requestPolicyIdForGroup3 = call uuid1
    * def requestPolicyIdForGroup4 = call uuid1
    * def extRequestTypesForFirstUserGroupRequestPolicy = ["Hold", "Recall"]
    * def extRequestTypesForSecondUserGroupRequestPolicy = ["Page", "Recall"]
    * def extRequestTypesForThirdUserGroupRequestPolicy = ["Page", "Hold"]
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }

    # groups
    * def firstUserGroupId = '188f025c-6e52-11ec-90d6-0242ac120003'
    * def secondUserGroupId = 'f1a28f58-702d-48fe-b95d-daf7fd55dc27'
    * def thirdUserGroupId = '0dfcce3e-6fb3-11ec-90d6-0242ac120003'
    * def fourthUserGroupId = 'a58053e4-6fbc-11ec-90d6-0242ac120003'
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(fourthUserGroupId)' }

    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(fourthUserGroupId)' }

    # policies
    * def loanPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1

    * def extFallbackPolicy = { loanPolicyId: #(loanPolicyId), lostItemFeePolicyId: #(lostItemFeePolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), patronPolicyId: #(patronPolicyId), requestPolicyId: #(requestPolicyId) }
    * def extMaterialTypePolicy = { materialTypeId: #(materialTypeId), loanPolicyId: #(loanPolicyMaterialId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyId), patronPolicyId: #(patronPolicyId) }
    * def extFirstGroupPolicy = { userGroupId: #(firstUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup), patronPolicyId: #(patronPolicyId) }
    * def extSecondGroupPolicy = { userGroupId: #(secondUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup2), patronPolicyId: #(patronPolicyId) }
    * def extThirdGroupPolicy = { userGroupId: #(thirdUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup3), patronPolicyId: #(patronPolicyId) }
    * def extFourthGroupPolicy = { userGroupId: #(fourthUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup4), patronPolicyId: #(patronPolicyId) }

    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup), extRequestTypes: #(extRequestTypesForFirstUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup2), extRequestTypes: #(extRequestTypesForSecondUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup3), extRequestTypes: #(extRequestTypesForThirdUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup4) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRulesWithMaterialTypeAndGroup') extFallbackPolicy, extMaterialTypePolicy, extFirstGroupPolicy, extSecondGroupPolicy, extThirdGroupPolicy, extFourthGroupPolicy

  Scenario: Run all mod-circulation features
    * call read('classpath:vega/mod-circulation/features/loans.feature')
    * call read('classpath:vega/mod-circulation/features/requests.feature')
