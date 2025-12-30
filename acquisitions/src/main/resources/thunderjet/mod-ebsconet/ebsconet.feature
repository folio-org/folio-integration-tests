@parallel=false
Feature: mod-ebsconet integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testebsconet' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/mod-ebsconet/init-ebsconet.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Cancel order lines with ebsconet
    * call read('features/cancel-order-lines-with-ebsconet.feature')

  Scenario: Close Order With Order Line
    * call read('features/close-order-with-order-line')

  Scenario: Get Ebsconet Order Line
    * call read('features/get-ebsconet-order-line.feature')

  Scenario: Update Ebsconet Order Line
    * call read('features/update-ebsconet-order-line.feature')

  Scenario: Update order lines having empty locations
    * call read('features/update-ebsconet-order-line-empty-locations.feature')

  Scenario: Update Ebsconet Order Line mixed format
    * call read('features/update-mixed-order-line.feature')