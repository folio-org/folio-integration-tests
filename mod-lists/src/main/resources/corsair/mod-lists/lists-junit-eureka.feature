Feature: mod-lists integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-circulation-storage' |
      | 'mod-fqm-manager'         |
      | 'mod-lists'               |
      | 'mod-entities-links'      |

    * table userPermissions
      | name                                                        |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation.loans.collection.get'                          |
      | 'departments.collection.get'                                |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'inventory-storage.loan-types.collection.get'               |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'lists.collection.get'                                      |
      | 'lists.collection.post'                                     |
      | 'lists.item.contents.get'                                   |
      | 'lists.item.delete'                                         |
      | 'lists.item.export.download.get'                            |
      | 'lists.item.export.get'                                     |
      | 'lists.item.export.post'                                    |
      | 'lists.item.get'                                            |
      | 'lists.item.post'                                           |
      | 'lists.item.refresh.cancel'                                 |
      | 'lists.item.update'                                         |
      | 'lists.item.versions.collection.get'                        |
      | 'lists.item.versions.item.get'                              |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-lists/eureka-features/util/add-list-data.feature')

  Scenario: create second user for testing
    * def testUserName = testUser.name
    * def testUser = {tenant: "#(testTenant)", name: '#(testUser2.name)', password: 'test'}
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')
    Given call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
    * def testUser = {tenant: "#(testTenant)", name: '#(testUserName)', password: 'test'}