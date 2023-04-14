Feature: mod-data-export-spring integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-orders'                |
      | 'mod-organizations'         |
#      | 'mod-data-export-spring'    |

    * table userPermissions
      | name                                      |
      | 'organizations.module.all'                |
      | 'orders.item.post'                        |
      | 'orders.item.get'                         |
      | 'orders.item.put'                         |
      | 'orders.po-lines.item.post'               |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
