@parallel=false
Feature: Cross-module integration tests

  Background:
    * print karate.info.scenarioName
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
      | 'mod-audit'                 |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations-storage' |

    # User permissions: non-storage permissions for finance, orders, invoices and organizations
    * table userPermissions
      | name                                               |
      | 'finance.budgets.collection.get'                   |
      | 'finance.budgets.item.delete'                      |
      | 'finance.budgets.item.get'                         |
      | 'finance.budgets.item.post'                        |
      | 'finance.budgets.item.put'                         |
      | 'finance.expense-classes.item.post'                |
      | 'finance.fiscal-years.item.get'                    |
      | 'finance.fiscal-years.item.post'                   |
      | 'finance.fiscal-years.item.put'                    |
      | 'finance.funds.item.get'                           |
      | 'finance.funds.item.post'                          |
      | 'finance.funds.item.put'                           |
      | 'finance.fund-types.item.post'                     |
      | 'finance.group-fund-fiscal-years.collection.get'   |
      | 'finance.groups.item.post'                         |
      | 'finance.ledger-rollovers-budgets.collection.get'  |
      | 'finance.ledger-rollovers-budgets.item.get'        |
      | 'finance.ledger-rollovers-errors.collection.get'   |
      | 'finance.ledger-rollovers.item.post'               |
      | 'finance.ledger-rollovers-logs.item.get'           |
      | 'finance.ledger-rollovers-progress.collection.get' |
      | 'finance.ledger-rollovers-progress.item.put'       |
      | 'finance.ledgers.item.post'                        |
      | 'finance.release-encumbrance.item.post'            |
      | 'finance.transactions.batch.execute'               |
      | 'finance.transactions.collection.get'              |
      | 'finance.transactions.item.get'                    |
      | 'invoice.invoice-lines.collection.get'             |
      | 'invoice.invoice-lines.item.delete'                |
      | 'invoice.invoice-lines.item.get'                   |
      | 'invoice.invoice-lines.item.post'                  |
      | 'invoice.invoice-lines.item.put'                   |
      | 'invoice.invoices.item.delete'                     |
      | 'invoice.invoices.item.get'                        |
      | 'invoice.invoices.item.post'                       |
      | 'invoice.invoices.item.put'                        |
      | 'invoice.item.approve.execute'                     |
      | 'invoice.item.cancel.execute'                      |
      | 'invoice.item.pay.execute'                         |
      | 'invoices.acquisitions-units-assignments.assign'   |
      | 'invoices.acquisitions-units-assignments.manage'   |
      | 'invoices.fiscal-year.update.execute'              |
      | 'orders.acquisitions-units-assignments.assign'     |
      | 'orders.acquisitions-units-assignments.manage'     |
      | 'orders.check-in.collection.post'                  |
      | 'orders.collection.get'                            |
      | 'orders.item.approve'                              |
      | 'orders.item.get'                                  |
      | 'orders.item.post'                                 |
      | 'orders.item.put'                                  |
      | 'orders.item.reopen'                               |
      | 'orders.item.unopen'                               |
      | 'orders.pieces.collection.get'                     |
      | 'orders.pieces.item.delete'                        |
      | 'orders.po-lines.collection.get'                   |
      | 'orders.po-lines.item.delete'                      |
      | 'orders.po-lines.item.get'                         |
      | 'orders.po-lines.item.post'                        |
      | 'orders.po-lines.item.put'                         |
      | 'orders.re-encumber.item.post'                     |
      | 'organizations.organizations.item.get'             |
      | 'organizations.organizations.item.post'            |
      | 'organizations.organizations.item.put'             |
      | 'voucher.vouchers.collection.get'                  |

    # Admin permissions: all the other permissions needed
    * table adminPermissions
      | name                                                          |
      | 'acquisition.invoice.events.get'                              |
      | 'acquisition.invoice-line.events.get'                         |
      | 'acquisition.organization.events.get'                         |
      | 'acquisitions-units.memberships.collection.get'               |
      | 'acquisitions-units.memberships.item.delete'                  |
      | 'acquisitions-units.memberships.item.post'                    |
      | 'acquisitions-units.units.item.post'                          |
      | 'configuration.entries.collection.get'                        |
      | 'configuration.entries.item.post'                             |
      | 'configuration.entries.item.put'                              |
      | 'finance-storage.budgets.item.get'                            |
      | 'finance-storage.budgets.item.put'                            |
      | 'finance-storage.ledger-rollovers.item.delete'                |
      | 'finance-storage.ledger-rollovers-errors.item.post'           |
      | 'inventory.instances.item.post'                               |
      | 'inventory-storage.contributor-name-types.item.post'          |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.holdings-sources.item.post'                |
      | 'inventory-storage.identifier-types.item.post'                |
      | 'inventory-storage.instance-statuses.item.post'               |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.loan-types.item.post'                      |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.service-points.item.post'                  |
      | 'invoice-storage.invoices.item.get'                           |
      | 'invoice-storage.invoices.item.put'                           |
      | 'orders-storage.order-invoice-relationships.collection.get'   |
      | 'orders-storage.po-lines.item.get'                            |
      | 'orders-storage.po-lines.item.post'                           |
      | 'orders-storage.po-lines.item.put'                            |
      | 'orders-storage.purchase-orders.item.post'                    |
      | 'users.collection.get'                                        |


  Scenario: Create tenant and test user
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)', userPermissions: '#(adminPermissions)' }

  Scenario: Init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * call login testUser
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
