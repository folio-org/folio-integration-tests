@parallel=false
Feature: Initialize edge-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * table modules
      | name                        |
      | "mod-permissions"           |
      | "mod-configuration"         |
      | "mod-login"                 |
      | "mod-users"                 |
      | "mod-audit"                 |
      | "mod-orders-storage"        |
      | "mod-orders"                |
      | "mod-finance-storage"       |
      | "mod-finance"               |
      | "mod-inventory-storage"     |
      | "mod-inventory"             |
      | "mod-organizations-storage" |
      | "mod-organizations"         |
      | "mod-okapi-facade"          |
      | "mod-ebsconet"              |
      | "mod-gobi"                  |
      | "mod-mosaic"                |

    * table userPermissions
      | name                                                      |
      | "ebsconet.order-lines.item.get"                           |
      | "ebsconet.order-lines.item.put"                           |
      | "ebsconet.orders.validate.get"                            |
      | "gobi.orders.item.post"                                   |
      | "gobi.validate.item.get"                                  |
      | "gobi.validate.item.post"                                 |
      | "orders.item.get"                                         |
      | "orders.item.post"                                        |
      | "orders.po-lines.collection.get"                          |
      | "orders.po-lines.item.get"                                |
      | "orders.po-lines.item.put"                                |
      | "organizations.organizations.item.delete"                 |
      | "organizations.organizations.item.post"                   |
      | "mosaic.validate.get"                                     |
      | "mosaic.orders.item.post"                                 |
      | "orders.order-templates.collection.get"                   |
      | "orders-storage.custom-fields.collection.get"             |
      | "okapi.proxy.tenants.modules.list"                        |
      | "finance.funds.collection.get"                            |
      | "finance.expense-classes.collection.get"                  |
      | "finance.fund-codes-expense-classes.collection.get"       |
      | "acquisitions-units.units.collection.get"                 |
      | "orders.acquisitions-units-assignments.manage"            |
      | "orders.acquisition-methods.collection.get"               |
      | "organizations.organizations.collection.get"              |
      | "configuration.entries.collection.get"                    |
      | "inventory-storage.locations.collection.get"              |
      | "inventory-storage.material-types.collection.get"         |
      | "inventory-storage.identifier-types.collection.get"       |
      | "inventory-storage.contributor-name-types.collection.get" |
      | "users.collection.get"                                    |

    * table adminPermissions
      | name                                                          |
      | "mosaic.configuration.item.get"                               |
      | "mosaic.configuration.item.post"                              |
      | "mosaic.configuration.item.put"                               |
      | "mosaic.configuration.item.delete"                            |
      | "acquisitions-units.memberships.item.post"                    |
      | "acquisitions-units.units.item.post"                          |
      | "configuration.entries.item.post"                             |
      | "inventory.instances.item.post"                               |
      | "inventory-storage.contributor-name-types.item.post"          |
      | "inventory-storage.electronic-access-relationships.item.post" |
      | "inventory-storage.holdings.item.post"                        |
      | "inventory-storage.holdings-sources.item.post"                |
      | "inventory-storage.identifier-types.item.post"                |
      | "inventory-storage.instance-statuses.item.post"               |
      | "inventory-storage.instance-types.item.post"                  |
      | "inventory-storage.loan-types.item.post"                      |
      | "inventory-storage.locations.item.post"                       |
      | "inventory-storage.location-units.campuses.item.post"         |
      | "inventory-storage.location-units.institutions.item.post"     |
      | "inventory-storage.location-units.libraries.item.post"        |
      | "inventory-storage.material-types.item.post"                  |
      | "inventory-storage.service-points.item.post"                  |
      | "orders.collection.get"                                       |
      | "orders.po-lines.collection.get"                              |
      | "orders.order-templates.item.post"                            |
      | "orders.order-templates.item.get"                             |
      | "finance.budgets.collection.get"                              |
      | "finance.budgets.item.get"                                    |
      | "finance.budgets.item.post"                                   |
      | "finance.expense-classes.item.post"                           |
      | "finance.fiscal-years.item.get"                               |
      | "finance.fiscal-years.item.post"                              |
      | "finance.funds.item.get"                                      |
      | "finance.funds.item.post"                                     |
      | "finance.fund-types.item.post"                                |
      | "finance.ledgers.item.post"                                   |
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
