Feature: mod-gobi integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testmodgobi' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/mod-gobi/init-gobi.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: GOBI api tests
    * call read('features/gobi-api-tests.feature')

  Scenario: Find holdings by location and instance
    * call read('features/find-holdings-by-location-and-instance.feature')
