@parallel=false
Feature: Initialize mod-data-export-spring integration tests

  Background:
    * print karate.info.scenarioName
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
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-data-export-spring'    |
      | 'mod-data-export-worker'    |

    * table userPermissions
      | name                                                          |
      | 'configuration.entries.item.post'                             |
      | 'orders-storage.settings.item.post'                           |
      | 'finance.budgets.item.post'                                   |
      | 'finance.funds.item.post'                                     |
      | 'data-export.config.collection.get'                           |
      | 'data-export.config.item.delete'                              |
      | 'data-export.config.item.get'                                 |
      | 'data-export.config.item.post'                                |
      | 'data-export.config.item.put'                                 |
      | 'data-export.job.collection.get'                              |
      | 'data-export.job.item.download'                               |
      | 'data-export.job.item.get'                                    |
      | 'data-export.job.item.resend'                                 |
      | 'orders.collection.get'                                       |
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.item.put'                                             |
      | 'orders.pieces.collection.get'                                |
      | 'orders.pieces.collection.put'                                |
      | 'orders.pieces.item.post'                                     |
      | 'orders.po-lines.collection.get'                              |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.post'                                   |
      | 'orders.po-lines.item.put'                                    |
      | 'orders.titles.collection.get'                                |
      | 'orders.titles.item.post'                                     |
      | 'organizations.organizations.item.get'                        |
      | 'organizations.organizations.item.post'                       |
      | 'organizations.organizations.item.put'                        |
      | 'pieces.send-claims.collection.post'                          |

    # testAdmin is only used to initialize global data
    * table adminPermissions
      | name                                                          |
      | 'configuration.entries.item.post'                             |
      | 'orders-storage.settings.item.post'                           |
      | 'finance.budgets.item.post'                                   |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.funds.item.post'                                     |
      | 'finance.ledgers.item.post'                                   |
      | 'inventory.instances.item.post'                               |
      | 'inventory-storage.contributor-name-types.item.post'          |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.holdings.retrieve.collection.post'         |
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
      | 'organizations.organizations.item.post'                       |

    * callonce variables

    * def nextZonedTimeAsLocaleSettings = read('features/util/get-next-time-function.js')
    * def currentDayOfWeek = read('features/util/get-day-of-week-function.js')
    * def waitIfNecessary = read('features/util/determine-if-wait-necessary-function.js')


  Scenario: Create tenant and test user
    * call read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)',  userPermissions: '#(adminPermissions)' }

  Scenario: Init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
