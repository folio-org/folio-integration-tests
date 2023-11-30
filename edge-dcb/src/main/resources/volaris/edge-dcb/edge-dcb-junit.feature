Feature: edge-dcb integration tests

  Background:
    * url baseUrl

    * table modules
      | name                                |

    * table userPermissions
      | name                                |

  Scenario: create tenant and users for testing
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

  Scenario: init data
    Given call read('classpath:volaris/edge-dcb/features/util/init-data.feature')




