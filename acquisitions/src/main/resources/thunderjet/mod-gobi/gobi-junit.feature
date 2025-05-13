@parallel=false
Feature: mod-gobi integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-gobi'                  |
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
      | 'mod-search'                |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-tags'                  |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |

    * table userPermissions
      | name                                                          |
      | 'configuration.entries.collection.get'                        |
      | 'configuration.entries.item.delete'                           |
      | 'configuration.entries.item.post'                             |
      | 'configuration.entries.item.put'                              |
      | 'finance.budgets.item.post'                                   |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.fund-types.item.post'                                |
      | 'finance.funds.collection.get'                                |
      | 'finance.funds.item.post'                                     |
      | 'finance.groups.item.post'                                    |
      | 'finance.ledger-rollovers.item.post'                          |
      | 'finance.ledgers.item.post'                                   |
      | 'finance.release-encumbrance.item.post'                       |
      | 'finance.transactions.batch.execute'                          |
      | 'gobi.custom-mappings.collection.get'                         |
      | 'gobi.custom-mappings.item.delete'                            |
      | 'gobi.custom-mappings.item.get'                               |
      | 'gobi.custom-mappings.item.post'                              |
      | 'gobi.custom-mappings.item.put'                               |
      | 'gobi.orders.item.post'                                       |
      | 'gobi.validate.item.get'                                      |
      | 'gobi.validate.item.post'                                     |
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
      | 'organizations.organizations.item.post'                       |
      | 'orders.collection.get'                                       |
      | 'orders.po-lines.collection.get'                              |


    # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'testmodgobi' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
    # Create tenant and users for testing:
    * def testUser = testAdmin
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Init global data
    * call login testAdmin
    * callonce variables

    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: GOBI api tests
    Given call read('features/gobi-api-tests.feature')

  Scenario: Find holdings by location and instance
    Given call read('features/find-holdings-by-location-and-instance.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')
