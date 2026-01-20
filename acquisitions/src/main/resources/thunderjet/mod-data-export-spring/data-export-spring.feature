@parallel=false
Feature: mod-data-export-spring integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testexport' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * callonce read('classpath:thunderjet/mod-data-export-spring/init-data-export-spring.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Edifact Orders Export
    * call read('features/edifact-orders-export.feature')

  Scenario: Claims Export
    * call read('features/claims-export.feature')
