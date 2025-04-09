Feature: edge-fqm integration tests

  Background:
    * def testTenant = 'tttttestfqmtenant'
    * def testTenantId = '6f95e8d8-cc5f-4ecd-ab1f-0db0130bafd9'
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-inventory-storage'   |
      | 'mod-circulation-storage' |
      | 'mod-fqm-manager'         |
      | 'edge-fqm'                |

    * table userPermissions
      | name                                                        |
      | 'fqm.entityTypes.collection.get'                            |
      | 'fqm.entityTypes.item.get'                                  |
      | 'fqm.entityTypes.item.columnValues.get'                     |
      | 'fqm.query.async.post'                                      |
      | 'fqm.query.async.results.query.get'                         |
      | 'fqm.query.sync.get'                                        |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'finance.budgets.collection.get'                            |
      | 'inventory-storage.instance-types.collection.get'           |
      | 'inventory-storage.instance-statuses.collection.get'        |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'circulation.loans.collection.get'                          |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.loan-types.collection.get'               |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'inventory-storage.service-points.collection.get'           |
      | 'finance.exchange-rate.item.get'                            |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'orders.po-lines.item.get'                                  |
      | 'orders.item.get'                                           |
      | 'finance.transactions.collection.get'                       |
      | 'usergroups.collection.get'                                 |
      | 'users.item.get'                                            |
      | 'acquisitions-units.units.collection.get'                   |
      | 'finance.funds.collection.get'                              |
      | 'finance.fund-types.collection.get'                         |
      | 'finance.ledgers.collection.get'                            |
      | 'invoice.invoice-lines.collection.get'                      |
      | 'users.collection.get'                                      |
      | 'configuration.entries.collection.get'                      |
      | 'invoice.invoices.collection.get'                           |
      | 'voucher.voucher-lines.collection.get'                      |
      | 'finance.fiscal-years.collection.get'                       |
      | 'organizations.organizations.collection.get'                |
      | 'batch-groups.collection.get'                               |
      | 'organizations-storage.organization-types.collection.get'   |
      | 'voucher.vouchers.collection.get'                           |
      | 'organizations-storage.categories.collection.get'           |
      | 'inventory-storage.locations.item.post'                     |
      |'inventory-storage.location-units.libraries.item.post'|
      |'inventory-storage.location-units.campuses.item.post'|
      |'inventory-storage.location-units.institutions.item.post'|

  Scenario: create tenant and data for testing
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/edge-fqm/eureka-features/utils/add-query-data.feature')