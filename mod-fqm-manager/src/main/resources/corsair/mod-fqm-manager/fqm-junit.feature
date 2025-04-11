Feature: mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-inventory-storage'             |
      | 'mod-circulation'                   |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |
      | 'mod-finance'                       |
      | 'mod-finance-storage'               |
      | 'mod-orders'                        |
      | 'mod-orders-storage'                |
      | 'mod-organizations'                 |
      | 'mod-organizations-storage'         |
      # needed to explicitly resolve authority-reindex interface for mod-search
      | 'mod-entities-links'                |
      | 'mod-pubsub'                        |


    * table userPermissions
      | name                                                        |
      | 'acquisitions-units.units.collection.get'                   |
      | 'addresstypes.collection.get'                               |
      | 'addresstypes.item.post'                                    |
      | 'batch-groups.collection.get'                               |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loans.item.post'                       |
      | 'circulation.loans.collection.get'                          |
      | 'configuration.entries.collection.get'                      |
      | 'departments.collection.get'                                |
      | 'finance.exchange-rate.item.get'                            |
      | 'finance.expense-classes.collection.get'                    |
      | 'finance.fiscal-years.collection.get'                       |
      | 'finance.fund-types.collection.get'                         |
      | 'finance.funds.collection.get'                              |
      | 'finance.ledgers.collection.get'                            |
      | 'finance.transactions.collection.get'                       |
      | 'fqm.entityTypes.collection.get'                            |
      | 'fqm.entityTypes.item.columnValues.get'                     |
      | 'fqm.entityTypes.item.get'                                  |
      | 'fqm.materializedViews.post'                                |
      | 'fqm.migrate.post'                                          |
      | 'fqm.query.all'                                             |
      | 'fqm.query.async.results.get'                               |
      | 'fqm.query.async.results.post'                              |
      | 'fqm.query.async.results.query.get'                         |
      | 'fqm.query.async.results.sortedids.get'                     |
      | 'fqm.query.privileged.async.results.post'                   |
      | 'fqm.query.purge.post'                                      |
      | 'fqm.version.get'                                           |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instance-statuses.collection.get'        |
      | 'inventory-storage.instance-types.collection.get'           |
      | 'inventory-storage.instance-types.item.get'                 |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.instances.item.post'                     |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.loan-types.collection.get'               |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.modes-of-issuance.collection.get'        |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'invoice.invoice-lines.collection.get'                      |
      | 'invoice.invoices.collection.get'                           |
      | 'orders-storage.po-lines.item.post'                         |
      | 'orders-storage.purchase-orders.item.post'                  |
      | 'orders.item.get'                                           |
      | 'orders.po-lines.item.get'                                  |
      | 'organizations-storage.categories.collection.get'           |
      | 'organizations-storage.organization-types.collection.get'   |
      | 'organizations-storage.organizations.item.post'             |
      | 'organizations.organizations.collection.get'                |
      | 'organizations.organizations.item.get'                      |
      | 'search.instances.collection.get'                           |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'voucher.voucher-lines.collection.get'                      |
      | 'voucher.vouchers.collection.get'                           |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-fqm-manager/features/util/add-query-data.feature')
