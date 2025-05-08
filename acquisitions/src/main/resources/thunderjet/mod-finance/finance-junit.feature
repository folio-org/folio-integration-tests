@parallel=false
Feature: mod-finance integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
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
      | 'finance-storage.budget-expense-classes.collection.get'       |
      | 'finance-storage.budget-expense-classes.item.post'            |
      | 'finance-storage.budgets.item.get'                            |
      | 'finance-storage.budgets.item.post'                           |
      | 'finance-storage.budgets.item.put'                            |
      | 'finance-storage.fund-update-logs.collection.get'             |
      | 'finance-storage.funds.item.delete'                           |
      | 'finance-storage.funds.item.post'                             |
      | 'finance-storage.group-fund-fiscal-years.collection.get'      |
      | 'finance-storage.group-fund-fiscal-years.item.post'           |
      | 'finance-storage.ledger-rollovers-errors.collection.get'      |
      | 'finance-storage.ledger-rollovers.item.delete'                |
      | 'finance-storage.ledgers.item.post'                           |
      | 'finance-storage.transactions.batch.execute'                  |
      | 'finance-storage.transactions.collection.get'                 |
      | 'finance.budgets-expense-classes-totals.collection.get'       |
      | 'finance.budgets.collection.get'                              |
      | 'finance.budgets.item.delete'                                 |
      | 'finance.budgets.item.get'                                    |
      | 'finance.budgets.item.post'                                   |
      | 'finance.budgets.item.put'                                    |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.finance-data.collection.get'                         |
      | 'finance.finance-data.collection.put'                         |
      | 'finance.fiscal-years.item.delete'                            |
      | 'finance.fiscal-years.item.get'                               |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.fiscal-years.item.put'                               |
      | 'finance.fund-types.item.post'                                |
      | 'finance.funds.budget.item.get'                               |
      | 'finance.funds.collection.get'                                |
      | 'finance.funds.item.get'                                      |
      | 'finance.funds.item.post'                                     |
      | 'finance.funds.item.put'                                      |
      | 'finance.group-fiscal-year-summaries.collection.get'          |
      | 'finance.group-fund-fiscal-years.item.post'                   |
      | 'finance.groups-expense-classes-totals.collection.get'        |
      | 'finance.groups.item.post'                                    |
      | 'finance.ledger-rollovers-budgets.collection.get'             |
      | 'finance.ledger-rollovers-budgets.item.get'                   |
      | 'finance.ledger-rollovers-errors.collection.get'              |
      | 'finance.ledger-rollovers-logs.collection.get'                |
      | 'finance.ledger-rollovers-logs.item.get'                      |
      | 'finance.ledger-rollovers-progress.collection.get'            |
      | 'finance.ledger-rollovers-progress.item.put'                  |
      | 'finance.ledger-rollovers.item.post'                          |
      | 'finance.ledgers.collection.get'                              |
      | 'finance.ledgers.current-fiscal-year.item.get'                |
      | 'finance.ledgers.item.delete'                                 |
      | 'finance.ledgers.item.get'                                    |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.release-encumbrance.item.post'                       |
      | 'finance.transactions.batch.execute'                          |
      | 'finance.transactions.collection.get'                         |
      | 'finance.transactions.item.get'                               |

    * table adminPermissions
      | name                                                          |
      | 'acquisitions-units-storage.memberships.collection.get'       |
      | 'acquisitions-units-storage.memberships.item.delete'          |
      | 'acquisitions-units-storage.memberships.item.post'            |
      | 'acquisitions-units-storage.memberships.item.put'             |
      | 'acquisitions-units-storage.units.item.delete'                |
      | 'acquisitions-units-storage.units.item.get'                   |
      | 'acquisitions-units-storage.units.item.post'                  |
      | 'acquisitions-units-storage.units.item.put'                   |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'configuration.entries.collection.get'                        |
      | 'configuration.entries.item.delete'                           |
      | 'configuration.entries.item.post'                             |
      | 'configuration.entries.item.put'                              |
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
      | 'invoice.invoice-lines.item.post'                             |
      | 'invoice.invoices.item.get'                                   |
      | 'invoice.invoices.item.post'                                  |
      | 'invoice.invoices.item.put'                                   |
      | 'invoice.item.approve.execute'                                |
      | 'invoice.item.pay.execute'                                    |
      | 'orders-storage.order-invoice-relationships.collection.get'   |
      | 'orders-storage.po-lines.item.get'                            |
      | 'orders-storage.po-lines.item.put'                            |
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
      | 'organizations-storage.organizations.item.post'               |
      | 'organizations.organizations.item.get'                        |
      | 'organizations.organizations.item.post'                       |
      | 'organizations.organizations.item.put'                        |
      | 'users.collection.get'                                        |

  Scenario: Create tenant and test user
    * call read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)',  userPermissions: '#(adminPermissions)' }

  Scenario: Init global data
    * call login testUser
    * callonce read('classpath:global/finances.feature')
    * call login testAdmin
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/inventory.feature')
