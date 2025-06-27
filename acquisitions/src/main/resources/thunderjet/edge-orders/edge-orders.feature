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


  Scenario: COMMON
    Given call read("features/common.feature")

  Scenario: EBSCONET
    Given call read("features/ebsconet.feature")

  Scenario: GOBI
    Given call read("features/gobi.feature")

  Scenario: MOSAIC
    Given call read("features/mosaic.feature")