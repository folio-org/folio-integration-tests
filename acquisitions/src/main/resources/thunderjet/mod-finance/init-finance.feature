@parallel=false
Feature: Initialize mod-finance integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-settings'              |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations-storage' |

    * table userPermissions
      | name                                                          |
      | 'finance-storage.budget-expense-classes.collection.get'       |
      | 'finance-storage.budget-expense-classes.item.post'            |
      | 'finance-storage.budgets.item.get'                            |
      | 'finance-storage.budgets.item.post'                           |
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
      | 'acquisitions-units.memberships.collection.get'               |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.memberships.item.put'                     |
      | 'acquisitions-units.units.item.delete'                        |
      | 'acquisitions-units.units.item.post'                          |
      | 'orders-storage.settings.collection.get'                      |
      | 'orders-storage.settings.item.post'                           |
      | 'orders-storage.settings.item.put'                            |
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
      | 'orders.collection.get'                                       |
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.item.put'                                             |
      | 'orders.item.unopen'                                          |
      | 'orders.po-lines.collection.get'                              |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.post'                                   |
      | 'orders.po-lines.item.put'                                    |
      | 'organizations.organizations.item.post'                       |
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
