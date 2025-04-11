Feature: mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-inventory-storage'     |
      | 'mod-circulation'           |
      | 'mod-circulation-storage'   |
      | 'mod-fqm-manager'           |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
      | 'mod-orders'                |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |
      | 'mod-entities-links'        |
      | 'mod-pubsub'                |

    * table userPermissions
      | name                                                        |
      | 'acquisitions-units.units.collection.get'                   |
      | 'addresstypes.item.post'                                    |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loans.item.post'                       |
      | 'circulation.loans.collection.get'                          |
      | 'configuration.entries.collection.get'                      |
      | 'finance.exchange-rate.item.get'                            |
      | 'fqm.entityTypes.collection.get'                            |
      | 'fqm.entityTypes.item.get'                                  |
      | 'fqm.entityTypes.item.columnValues.get'                     |
      | 'fqm.materializedViews.post'                                |
      | 'fqm.migrate.post'                                          |
      | 'fqm.query.sync.get'                                        |
      | 'fqm.query.purge.post'                                      |
      | 'fqm.query.async.results.query.get'                         |
      | 'fqm.query.async.post'                                      |
      | 'fqm.query.async.delete'                                    |
      | 'fqm.query.async.results.get'                               |
      | 'fqm.version.get'                                           |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-statuses.collection.get'        |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instance-types.collection.get'           |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.instances.item.post'                     |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.loan-types.collection.get'               |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'orders-storage.po-lines.item.post'                         |
      | 'orders-storage.purchase-orders.item.post'                  |
      | 'orders.item.get'                                           |
      | 'orders.po-lines.item.get'                                  |
      | 'organizations-storage.categories.collection.get'           |
      | 'organizations-storage.organization-types.collection.get'   |
      | 'organizations-storage.organizations.item.post'             |
      | 'organizations.organizations.collection.get'                |
      | 'search.instances.collection.get'                           |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-fqm-manager/eureka-features/util/add-query-data.feature')
