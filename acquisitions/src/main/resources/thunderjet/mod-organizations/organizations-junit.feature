Feature: mod-organizations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-permissions'           |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |

    * table userPermissions
      | name                                      |
      | 'organizations.module.all'                |
      | 'organizations-storage.organizations.all' |
      | 'orders-storage.module.all'               |
      | 'acquisition.organization.events.get'     |

  Scenario: Create tenant and users for testing
    * call read('classpath:common/setup-users.feature')