Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                 |
      | 'mod-configuration'  |
      | 'mod-login'          |
      | 'mod-orders'         |
      | 'mod-invoice'        |
      | 'mod-permissions'    |
      | 'mod-tags'           |
      | 'mod-audit'          |

    * table adminAdditionalPermissions
      | name                                                           |
      | 'orders-storage.module.all'                                    |
      | 'finance.module.all'                                           |
      | 'acquisitions-units.memberships.item.delete'                   |
      | 'acquisitions-units.memberships.item.post'                     |
      | 'acquisitions-units.units.item.post'                           |


    * table userPermissions
      | name                                   |
      | 'orders.all'                           |
      | 'finance.all'                          |
      | 'inventory.all'                        |
      | 'tags.all'                             |
      | 'orders.item.approve'                  |
      | 'orders.item.reopen'                   |
      | 'orders.item.unopen'                   |
      | 'invoice.all'                          |
      | 'audit.all'                            |
      | 'inventory-storage.holdings.item.post' |

# Looks like already exist, but if not pleas uncomment
#    * table desiredPermissions
#      | desiredPermissionName |
#      | 'orders.item.approve' |
#      | 'orders.item.reopen'  |
#      | 'orders.item.unopen'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/orders.feature')
