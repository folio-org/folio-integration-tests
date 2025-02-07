Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login admin
    * def desiredPermissions = karate.get('desiredPermissions', [])

  Scenario: create new tenant
    * print "create new tenant"
    Given call read('classpath:common/tenant.feature@create') { tenant: '#(testTenant)'}

  Scenario: enable mod-authtoken module
    * print "enable mod-authtoken module"
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testTenant)'}

  Scenario: get and install configured modules
    * print "get and install configured modules"
    Given call read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testTenant)'}

  Scenario: disable mod-authtoken module
    * print "disable mod-authtoken module"
    * def disabledModules = call read('classpath:common/tenant.feature@disable') { modules: '#(modules)', tenant: '#(testTenant)'}
    * call read('classpath:common/user-permissions.feature') { tenant: '#(testTenant)' }
    * call read('classpath:common/tenant.feature@InstallAfterDisabling') { tenant: '#(testTenant)', disabledModules: '#(disabledModules)' }
