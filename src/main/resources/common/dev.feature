Feature: dev

  Scenario: init dev data

    * def testAdmin = { tenant: '#(tenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(tenant)', name: 'test-user', password: 'test' }
