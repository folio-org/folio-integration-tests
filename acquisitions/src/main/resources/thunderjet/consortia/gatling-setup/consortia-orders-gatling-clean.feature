Feature: mod-consortia integration tests

  Scenario: Destroy created ['central', 'university'] tenants
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
