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

  Scenario: Validate POL receipt not required with checkin items
    * call read('features/validate-pol-receipt-not-required-with-checkin-items.feature')

  Scenario: Validate POL suppress instance from discovery
    * call read('features/validate-pol-suppress-instance-from-discovery.feature')

  Scenario: Verify tenant address lookup populates billTo on order
    * call read('features/verify-tenant-address-lookup.feature')

  Scenario: Verify expense class lookup populates fundDistribution.expenseClassId on order
    * call read('features/verify-expense-class-lookup.feature')

  Scenario: Receipt not required sets receiving workflow to Independent for Pending order
    * call read('features/receipt-not-required-pending-order-independent-workflow.feature')

  Scenario: Receipt not required sets receiving workflow to Independent for Open order
    * call read('features/receipt-not-required-open-order-independent-workflow.feature')

  Scenario: Order without location fails when Inventory interaction requires holdings
    * call read('features/order-without-location-fails-when-holdings-required.feature')

  Scenario: Order can be created without configured locations in the system
    * call read('features/order-without-configured-locations.feature')

  Scenario: TenantId is not populated by mod-gobi on non-ECS environment
    * call read('features/tenant-id-not-populated-on-non-ecs.feature')