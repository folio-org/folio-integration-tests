Feature: mod-invoice integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-permissions'           |
      | 'mod-audit'                 |
      | 'mod-configuration'         |
      | 'mod-invoice'               |
      | 'mod-invoice-storage'       |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |
      | 'mod-orders'                |
      | 'mod-orders-storage'        |

    * table userPermissions
      | name                                                        |
      | 'batch-groups.collection.get'                               |
      | 'batch-groups.item.post'                                    |
      | 'batch-voucher.batch-voucher-exports.item.get'              |
      | 'batch-voucher.batch-voucher-exports.item.post'             |
      | 'batch-voucher.batch-vouchers.item.get'                     |
      | 'batch-voucher.export-configurations.credentials.item.post' |
      | 'batch-voucher.export-configurations.item.post'             |
      | 'invoice.invoice-lines.collection.get'                      |
      | 'invoice.invoice-lines.item.delete'                         |
      | 'invoice.invoice-lines.item.get'                            |
      | 'invoice.invoice-lines.item.post'                           |
      | 'invoice.invoice-lines.item.put'                            |
      | 'invoice.invoices.collection.get'                           |
      | 'invoice.invoices.documents.item.get'                       |
      | 'invoice.invoices.documents.item.post'                      |
      | 'invoice.invoices.fiscal-years.collection.get'              |
      | 'invoice.invoices.item.delete'                              |
      | 'invoice.invoices.item.get'                                 |
      | 'invoice.invoices.item.post'                                |
      | 'invoice.invoices.item.put'                                 |
      | 'invoice.item.approve.execute'                              |
      | 'invoice.item.cancel.execute'                               |
      | 'invoice.item.pay.execute'                                  |
      | 'invoices.fiscal-year.update.execute'                       |
      | 'voucher-number.start.post'                                 |
      | 'voucher-storage.voucher-lines.item.delete'                 |
      | 'voucher-storage.vouchers.item.delete'                      |
      | 'voucher.voucher-lines.collection.get'                      |
      | 'voucher.vouchers.collection.get'                           |
      | 'voucher.vouchers.item.get'                                 |

    * table adminPermissions
      | name                                                        |
      | 'acquisition.invoice.events.get'                            |
      | 'acquisition.invoice-line.events.get'                       |
      | 'finance.budgets.item.get'                                  |
      | 'finance.budgets.item.post'                                 |
      | 'finance.budgets.item.put'                                  |
      | 'finance.expense-classes.item.post'                         |
      | 'finance.fiscal-years.item.get'                             |
      | 'finance.fiscal-years.item.post'                            |
      | 'finance.funds.budget.item.get'                             |
      | 'finance.funds.collection.get'                              |
      | 'finance.funds.item.get'                                    |
      | 'finance.funds.item.post'                                   |
      | 'finance.funds.item.put'                                    |
      | 'finance.ledgers.item.post'                                 |
      | 'finance-storage.budget-expense-classes.item.post'          |
      | 'finance.transactions.collection.get'                       |
      | 'finance.transactions.item.get'                             |
      | 'orders.item.get'                                           |
      | 'orders.item.post'                                          |
      | 'orders.item.put'                                           |
      | 'orders.po-lines.item.post'                                 |
      | 'organizations.organizations.item.post'                     |

  Scenario: Create tenant and test user
    * call read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)',  userPermissions: '#(adminPermissions)' }

  Scenario: Init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
