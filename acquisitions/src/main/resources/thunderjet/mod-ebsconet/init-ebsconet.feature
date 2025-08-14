@parallel=false
Feature: Initialize mod-ebsconet integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-configuration'         |
      | 'mod-settings'              |
      | 'mod-ebsconet'              |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |

    * table userPermissions
      | name                                                          |
      | 'ebsconet.order-lines.item.get'                               |
      | 'ebsconet.order-lines.item.put'                               |
      | 'finance.budgets.item.post'                                   |
      | 'finance.funds.item.post'                                     |
      | 'orders.item.delete'                                          |
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.item.put'                                             |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.post'                                   |

    # testAdmin is only used to initialize global data
    * table adminPermissions
      | name                                                          |
      | 'configuration.entries.item.post'                             |
      | 'orders-storage.settings.item.post'                           |
      | 'finance.budgets.item.post'                                   |
      | 'finance.expense-classes.item.post'                           |
      | 'finance.fiscal-years.item.post'                              |
      | 'finance.fund-types.item.post'                                |
      | 'finance.funds.item.post'                                     |
      | 'finance.ledgers.item.post'                                   |
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

  Scenario: Create tenant and test user
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: '#(testAdmin)',  userPermissions: '#(adminPermissions)' }

  Scenario: Init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
