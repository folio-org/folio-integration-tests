@parallel=false
Feature: mod-data-export-spring integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 300000

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
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
      | 'mod-audit'                 |

    * table userPermissions
      | name                                                          |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'configuration.entries.item.post'                             |
      | 'finance.budgets.collection.get'                              |
      | 'finance.budgets.item.delete'                                 |
      | 'finance.budgets.item.post'                                   |
      | 'finance.budgets.item.put'                                    |
      | 'finance.budgets.item.get'                                    |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.fiscal-years.item.put'                               |
      | 'finance.fiscal-years.item.get'                               |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.transactions.batch.execute'                          |
      | 'finance.transactions.item.get'                               |
      | 'finance.transactions.collection.get'                         |
      | 'finance.fund-types.item.post'                                |
      | 'finance.funds.item.get'                                      |
      | 'finance.funds.item.post'                                     |
      | 'finance.funds.item.put'                                      |
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
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.item.put'                                             |
      | 'orders.item.reopen'                                          |
      | 'orders.item.unopen'                                          |
      | 'orders.po-lines.collection.get'                              |
      | 'orders.po-lines.item.delete'                                 |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.post'                                   |
      | 'orders.po-lines.item.put'                                    |
      | 'orders.re-encumber.item.post'                                |
      | 'orders.pieces.collection.get'                                |
      | 'orders-storage.order-invoice-relationships.collection.get'   |
      | 'orders-storage.po-lines.item.get'                            |
      | 'orders-storage.po-lines.item.put'                            |
      | 'organizations.organizations.item.post'                       |
      | 'voucher.vouchers.collection.get'                             |
      | 'orders.pieces.item.delete'                                   |
      | 'perms.users.get'                                             |
      | 'perms.users.item.put'                                        |
      | 'data-export.config.collection.get'                           |
      | 'data-export.config.item.get'                                 |
      | 'data-export.config.item.post'                                |
      | 'data-export.config.item.put'                                 |
      | 'data-export.config.item.delete'                              |
      | 'data-export.job.collection.get'                              |
      | 'data-export.job.item.download'                               |
      | 'data-export.job.item.resend'                                 |
      | 'pieces.send-claims.collection.post'                          |
      | 'organizations.organizations.item.post'                       |
      | 'orders.titles.item.post'                                     |
      | 'organizations.organizations.item.get'                        |
      | 'organizations.organizations.item.put'                        |
      | 'orders.pieces.item.post'                                     |
      | 'data-export.job.item.get'                                    |
      | 'orders.titles.collection.get'                                |
      | 'orders.pieces.collection.put'                                |
      | 'inventory-storage.holdings.retrieve.collection.post'         |
      | 'users.collection.get'                                        |

  Scenario: create tenant and users for testing
    * def testUser = testAdmin
    Given call read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')