Feature: cross-module integration tests

  Background:
    * url baseUrl
    # Order of the modules below is important: mod-pubsub should come before mod-circulation

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations-storage' |

    * table userPermissions
      | name                                                          |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'acquisitions-units-storage.memberships.collection.get'       |
      | 'acquisitions-units-storage.memberships.item.delete'          |
      | 'acquisitions-units-storage.memberships.item.get'             |
      | 'acquisitions-units-storage.memberships.item.post'            |
      | 'acquisitions-units-storage.memberships.item.put'             |
      | 'configuration.entries.item.post'                             |
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
      | 'finance.funds.item.put'                                      |
      | 'finance.ledger-rollovers.item.post'                          |
      | 'finance.ledger-rollovers-errors.collection.get'              |
      | 'finance.ledger-rollovers-logs.item.get'                      |
      | 'finance.ledger-rollovers-progress.collection.get'            |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.release-encumbrance.item.post'                       |
      | 'finance.transactions.batch.execute'                          |
      | 'finance.transactions.collection.get'                         |
      | 'finance.transactions.item.get'                               |
      | 'finance-storage.funds.item.post'                             |
      | 'finance-storage.ledgers.item.post'                           |
      | 'finance-storage.transactions.batch.execute'                  |
      | 'finance-storage.transactions.collection.get'                 |
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
      | 'invoice.invoice-lines.collection.get'                        |
      | 'invoice.invoice-lines.item.delete'                           |
      | 'invoice.invoice-lines.item.get'                              |
      | 'invoice.invoice-lines.item.post'                             |
      | 'invoice.invoice-lines.item.put'                              |
      | 'invoice.invoices.item.delete'                                |
      | 'invoice.invoices.item.get'                                   |
      | 'invoice.invoices.item.post'                                  |
      | 'invoice.invoices.item.put'                                   |
      | 'invoice.item.approve.execute'                                |
      | 'invoice.item.cancel.execute'                                 |
      | 'invoice.item.pay.execute'                                    |
      | 'invoice-storage.invoices.item.get'                           |
      | 'invoice-storage.invoices.item.put'                           |
      | 'invoices.acquisitions-units-assignments.assign'              |
      | 'invoices.acquisitions-units-assignments.manage'              |
      | 'invoices.fiscal-year.update.execute'                         |
      | 'orders.acquisitions-units-assignments.assign'                |
      | 'orders.acquisitions-units-assignments.manage'                |
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
      | 'orders.pieces.collection.get'                                |
      | 'orders.pieces.item.delete'                                   |
      | 'orders.re-encumber.item.post'                                |
      | 'orders-storage.order-invoice-relationships.collection.get'   |
      | 'orders-storage.po-lines.item.get'                            |
      | 'orders-storage.po-lines.item.put'                            |
      | 'organizations-storage.organizations.item.post'               |
      | 'voucher.vouchers.collection.get'                             |
      | 'users.collection.get'                                        |

    * def random = callonce randomMillis
    * def testTenant = 'testcrossmodules' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
  #    "id": "82065a2b-cb25-4574-825d-edb0beb4f303",
  #    "name": "testtenant5823528056434509762",
  #    "description": "Tenant for test purpose"

  Scenario: create tenant and users for testing
    * def testUser = testAdmin
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: dummyUser creation
    * table userPermissions
      | name                                                          |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'acquisitions-units-storage.memberships.collection.get'       |
      | 'acquisitions-units-storage.memberships.item.delete'          |
      | 'acquisitions-units-storage.memberships.item.get'             |
      | 'acquisitions-units-storage.memberships.item.post'            |
      | 'acquisitions-units-storage.memberships.item.put'             |
      | 'configuration.entries.item.post'                             |
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
      | 'finance.funds.item.put'                                      |
      | 'finance.ledger-rollovers.item.post'                          |
      | 'finance.ledger-rollovers-errors.collection.get'              |
      | 'finance.ledger-rollovers-logs.item.get'                      |
      | 'finance.ledger-rollovers-progress.collection.get'            |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.release-encumbrance.item.post'                       |
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
      | 'invoice.invoice-lines.collection.get'                        |
      | 'invoice.invoice-lines.item.delete'                           |
      | 'invoice.invoice-lines.item.get'                              |
      | 'invoice.invoice-lines.item.post'                             |
      | 'invoice.invoice-lines.item.put'                              |
      | 'invoice.invoices.item.delete'                                |
      | 'invoice.invoices.item.get'                                   |
      | 'invoice.invoices.item.post'                                  |
      | 'invoice.invoices.item.put'                                   |
      | 'invoice.item.approve.execute'                                |
      | 'invoice.item.cancel.execute'                                 |
      | 'invoice.item.pay.execute'                                    |
      | 'invoice-storage.invoices.item.get'                           |
      | 'invoice-storage.invoices.item.put'                           |
      | 'invoices.acquisitions-units-assignments.assign'              |
      | 'invoices.acquisitions-units-assignments.manage'              |
      | 'invoices.fiscal-year.update.execute'                         |
      | 'orders.acquisitions-units-assignments.assign'                |
      | 'orders.acquisitions-units-assignments.manage'                |
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
      | 'orders.pieces.collection.get'                                |
      | 'orders.pieces.item.delete'                                   |
      | 'orders.re-encumber.item.post'                                |
      | 'organizations-storage.organizations.item.post'               |
      | 'voucher.vouchers.collection.get'                             |
      | 'users.collection.get'                                        |

    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    * call read('classpath:common/eureka/setup-users.feature@createTestUser') {testUser: '#(dummyUser)'}
    * call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials') {testUser: '#(dummyUser)'}
    * call read('classpath:common/eureka/setup-users.feature@addUserCapabilities') {userPermissions: '#(userPermissions)'}
