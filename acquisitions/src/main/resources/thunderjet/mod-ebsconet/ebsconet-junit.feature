@parallel=false
Feature: mod-ebsconet integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-configuration'         |
      | 'mod-ebsconet'              |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |

    * table userPermissions
      | name                                                          |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'configuration.entries.item.post'                             |
      | 'ebsconet.order-lines.item.get'                               |
      | 'ebsconet.order-lines.item.put'                               |
      | 'finance.budgets.collection.get'                              |
      | 'finance.budgets.item.delete'                                 |
      | 'finance.budgets.item.get'                                    |
      | 'finance.budgets.item.post'                                   |
      | 'finance.budgets.item.put'                                    |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.fiscal-years.item.get'                               |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.fiscal-years.item.put'                               |
      | 'finance.fund-types.item.post'                                |
      | 'finance.funds.item.get'                                      |
      | 'finance.funds.item.post'                                     |
      | 'finance.funds.item.put'                                      |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.transactions.batch.execute'                          |
      | 'finance.transactions.collection.get'                         |
      | 'finance.transactions.item.get'                               |
      | 'inventory-storage.contributor-name-types.item.post'          |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.holdings-sources.item.post'                |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.identifier-types.item.post'                |
      | 'inventory-storage.instance-statuses.item.post'               |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.loan-types.item.post'                      |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.service-points.item.post'                  |
      | 'inventory.instances.item.post'                               |
      | 'orders.check-in.collection.post'                             |
      | 'orders.collection.get'                                       |
      | 'orders.item.approve'                                         |
      | 'orders.item.delete'                                          |
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.item.put'                                             |
      | 'orders.item.reopen'                                          |
      | 'orders.item.unopen'                                          |
      | 'orders.pieces.collection.get'                                |
      | 'orders.pieces.item.delete'                                   |
      | 'orders.pieces.item.post'                                     |
      | 'orders.po-lines.collection.get'                              |
      | 'orders.po-lines.item.delete'                                 |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.post'                                   |
      | 'orders.po-lines.item.put'                                    |
      | 'orders.re-encumber.item.post'                                |
      | 'orders.titles.collection.get'                                |
      | 'orders.titles.item.post'                                     |
      | 'organizations.organizations.item.get'                        |
      | 'organizations.organizations.item.post'                       |
      | 'organizations.organizations.item.put'                        |
      | 'perms.users.get'                                             |
      | 'perms.users.item.put'                                        |
      | 'pieces.send-claims.collection.post'                          |

  Scenario: create tenant and users for testing
    * def testUser = testAdmin
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
