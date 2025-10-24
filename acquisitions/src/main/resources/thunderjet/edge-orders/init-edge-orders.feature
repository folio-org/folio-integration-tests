@parallel=false
Feature: Initialize edge-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | "mod-audit"                 |
      | "mod-configuration"         |
      | "mod-ebsconet"              |
      | "mod-finance"               |
      | "mod-finance-storage"       |
      | "mod-gobi"                  |
      | "mod-inventory"             |
      | "mod-inventory-storage"     |
      | "mod-login"                 |
      | "mod-mosaic"                |
      | "mod-okapi-facade"          |
      | "mod-orders"                |
      | "mod-orders-storage"        |
      | "mod-organizations"         |
      | "mod-organizations-storage" |
      | "mod-permissions"           |
      | "mod-users"                 |

    * table userPermissions
      | name                                                      |
      | "acquisitions-units.units.collection.get"                 |
      | "configuration.entries.collection.get"                    |
      | "ebsconet.order-lines.item.get"                           |
      | "ebsconet.order-lines.item.put"                           |
      | "ebsconet.orders.validate.get"                            |
      | "finance.expense-classes.collection.get"                  |
      | "finance.fund-codes-expense-classes.collection.get"       |
      | "finance.funds.collection.get"                            |
      | "gobi.orders.item.post"                                   |
      | "gobi.validate.item.get"                                  |
      | "gobi.validate.item.post"                                 |
      | "inventory-storage.contributor-name-types.collection.get" |
      | "inventory-storage.identifier-types.collection.get"       |
      | "inventory-storage.locations.collection.get"              |
      | "inventory-storage.material-types.collection.get"         |
      | "mosaic.orders.item.post"                                 |
      | "mosaic.validate.get"                                     |
      | "okapi.proxy.tenants.modules.list"                        |
      | "orders.acquisitions-units-assignments.manage"            |
      | "orders.acquisition-methods.collection.get"               |
      | "orders.item.get"                                         |
      | "orders.item.post"                                        |
      | "orders.order-templates.collection.get"                   |
      | "orders.po-lines.collection.get"                          |
      | "orders.po-lines.item.get"                                |
      | "orders.po-lines.item.put"                                |
      | "organizations.organizations.collection.get"              |
      | "organizations.organizations.item.delete"                 |
      | "organizations.organizations.item.post"                   |
      | "orders-storage.custom-fields.collection.get"             |
      | "users.collection.get"                                    |

    * table adminPermissions
      | name                                                          |
      | "acquisitions-units.memberships.item.post"                    |
      | "acquisitions-units.units.item.post"                          |
      | "configuration.entries.item.post"                             |
      | 'orders-storage.settings.item.post'                           |
      | "finance.budgets.collection.get"                              |
      | "finance.budgets.item.get"                                    |
      | "finance.budgets.item.post"                                   |
      | "finance.expense-classes.item.post"                           |
      | "finance.fiscal-years.item.get"                               |
      | "finance.fiscal-years.item.post"                              |
      | "finance.fund-types.item.post"                                |
      | "finance.funds.item.get"                                      |
      | "finance.funds.item.post"                                     |
      | "finance.ledgers.item.post"                                   |
      | "inventory-storage.contributor-name-types.item.post"          |
      | "inventory-storage.electronic-access-relationships.item.post" |
      | "inventory-storage.holdings-sources.item.post"                |
      | "inventory-storage.holdings.item.post"                        |
      | "inventory-storage.identifier-types.item.post"                |
      | "inventory-storage.instance-statuses.item.post"               |
      | "inventory-storage.instance-types.item.post"                  |
      | "inventory-storage.loan-types.item.post"                      |
      | "inventory-storage.location-units.campuses.item.post"         |
      | "inventory-storage.location-units.institutions.item.post"     |
      | "inventory-storage.location-units.libraries.item.post"        |
      | "inventory-storage.locations.item.post"                       |
      | "inventory-storage.material-types.item.post"                  |
      | "inventory-storage.service-points.item.post"                  |
      | "inventory.instances.item.post"                               |
      | "mosaic.configuration.item.get"                               |
      | "mosaic.configuration.item.put"                               |
      | "orders.collection.get"                                       |
      | "orders.order-templates.item.get"                             |
      | "orders.order-templates.item.post"                            |
      | "orders.po-lines.collection.get"                              |
      | "organizations.organizations.item.post"                       |
      | "users.collection.get"                                        |

  Scenario: Create tenant and test user
    * call read("classpath:common/eureka/setup-users.feature")
    * call read("classpath:common/eureka/keycloak.feature@configureAccessTokenTime") { "AccessTokenLifespance" : 3600 }

  Scenario: Create admin user
    * def v = call createAdditionalUser { testUser: "#(testAdmin)",  userPermissions: "#(adminPermissions)" }

  Scenario: Init global data
    * call login testAdmin
    * callonce read("classpath:global/inventory.feature")
    * callonce read("classpath:global/configuration.feature")
    * callonce read("classpath:global/finances.feature")
    * callonce read("classpath:global/organizations.feature")
    * call login testUser
