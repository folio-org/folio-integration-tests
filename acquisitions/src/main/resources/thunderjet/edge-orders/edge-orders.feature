@parallel=false
Feature: edge-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testedgeorders' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/edge-orders/init-edge-orders.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Ebsconet
    * call read('features/ebsconet.feature')

  Scenario: GOBI
    * call read('features/gobi.feature')
