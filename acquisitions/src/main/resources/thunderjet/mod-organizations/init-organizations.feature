@parallel=false
Feature: Initialize mod-organizations integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-permissions'           |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |

    * table userPermissions
      | name                                                        |
      | 'organizations.organizations.collection.get'                |
      | 'organizations.organizations.item.get'                      |
      | 'organizations.organizations.item.post'                     |
      | 'organizations.organizations.item.put'                      |

    * table adminPermissions
      | name                                                        |
      | 'acquisitions-units.memberships.item.get'                   |
      | 'acquisitions-units.memberships.item.post'                  |
      | 'acquisitions-units-storage.memberships.item.post'          |
      | 'acquisitions-units-storage.memberships.item.put'           |
      | 'acquisitions-units-storage.units.item.post'                |
      | 'acquisitions-units.units.item.post'                        |
      | 'users.collection.get'                                      |


  Scenario: Create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)',  userPermissions: '#(adminPermissions)' }
