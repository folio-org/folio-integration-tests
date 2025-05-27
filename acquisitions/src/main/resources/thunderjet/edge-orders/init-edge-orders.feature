@parallel=false
Feature: Initialize edge-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-ebsconet'              |
      | 'mod-gobi'                  |

    # Some of these permissions are needed by edge-orders, see edge-orders' README.
    * table userPermissions
      | name                                                          |
      | 'acquisitions-units.units.collection.get'                     |
      | 'configuration.entries.collection.get'                        |
      | 'ebsconet.order-lines.item.get'                               |
      | 'ebsconet.order-lines.item.put'                               |
      | 'ebsconet.orders.validate.get'                                |
      | 'finance.expense-classes.collection.get'                      |
      | 'finance.funds.collection.get'                                |
      | 'gobi.orders.item.post'                                       |
      | 'gobi.validate.item.get'                                      |
      | 'gobi.validate.item.post'                                     |
      | 'orders.acquisition-methods.collection.get'                   |
      | 'orders.item.get'                                             |
      | 'orders.item.post'                                            |
      | 'orders.order-templates.collection.get'                       |
      | 'orders.po-lines.collection.get'                              |
      | 'orders.po-lines.item.get'                                    |
      | 'orders.po-lines.item.put'                                    |
      | 'organizations.organizations.collection.get'                  |
      | 'organizations.organizations.item.delete'                     |
      | 'organizations.organizations.item.post'                       |

    # testAdmin is only used to initialize global data
    * table adminPermissions
      | name                                                          |
      | 'configuration.entries.item.post'                             |
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
