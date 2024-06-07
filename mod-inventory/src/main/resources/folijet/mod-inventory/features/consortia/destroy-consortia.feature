@Ignore
Feature: Destroy consortia
  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin

  Scenario: Destroy created ['central', 'university', 'college'] tenants
  * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
  * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(collegeTenant)'}
  * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}