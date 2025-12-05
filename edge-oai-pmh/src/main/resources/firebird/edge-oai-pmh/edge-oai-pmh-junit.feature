Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 420000
    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-users'                              |
      | 'mod-oai-pmh'                            |
      | 'mod-quick-marc'                         |

    * table userPermissions
      | name                                     |
      | 'oai-pmh.clean-up-error-logs.post'                                            |
      | 'oai-pmh.clean-up-instances.post'                                             |
      | 'oai-pmh.filtering-conditions.get'                                            |
      | 'oai-pmh.sets.item.collection.get'                                            |
      | 'oai-pmh.sets.item.post'                                                      |
      | 'oai-pmh.sets.item.delete'                                                    |
      | 'oai-pmh.sets.item.put'                                                       |
      | 'oai-pmh.sets.item.get'                                                       |
      | 'oai-pmh.records.collection.get'                                              |
      | 'oai-pmh.request-metadata.collection.get'                                     |
      | 'oai-pmh.request-metadata.failed-instances.collection.get'                    |
      | 'oai-pmh.request-metadata.failed-to-save-instances.collection.get'            |
      | 'oai-pmh.request-metadata.logs.item.get'                                      |
      | 'oai-pmh.request-metadata.skipped-instances.collection.get'                   |
      | 'oai-pmh.request-metadata.suppressed-from-discovery-instances.collection.get' |
      | 'inventory-storage.electronic-access-relationships.item.post'                 |
      | 'inventory-storage.holdings.item.post'                                        |
      | 'inventory-storage.instances.item.post'                                       |
      | 'inventory-storage.items.item.post'                                           |
      | 'source-storage.snapshots.post'                                               |
      | 'source-storage.records.post'                                                 |
      | 'inventory-storage.holdings-sources.item.post'                                |
      | 'inventory-storage.instance-types.item.post'                                  |
      | 'inventory-storage.location-units.institutions.item.post'                     |
      | 'inventory-storage.location-units.campuses.item.post'                         |
      | 'inventory-storage.location-units.libraries.item.post'                        |
      | 'inventory-storage.locations.item.post'                                       |
      | 'inventory-storage.call-number-types.item.post'                               |
      | 'inventory-storage.loan-types.item.post'                                      |
      | 'inventory-storage.material-types.item.post'                                  |
      | 'configuration.entries.item.post'                                             |
      | 'configuration.entries.collection.get'                                        |
      | 'configuration.entries.item.get'                                              |
      | 'configuration.entries.item.put'                                              |
      | 'inventory-storage.holdings.item.get'                                         |
      | 'inventory-storage.items.collection.get'                                      |
      | 'inventory-storage.items.item.get'                                            |
      | 'inventory-storage.items.item.put'                                            |
      | 'inventory-storage.holdings.item.put'                                         |
      | 'inventory-storage.instances.collection.get'                                  |
      | 'inventory-storage.instances.item.get'                                        |
      | 'marc-records-editor.item.get'                                                |
      | 'marc-records-editor.item.put'                                                |
      | 'oai-pmh.configuration-settings.collection.get'                               |
      | 'oai-pmh.configuration-settings.item.get'                                     |
      | 'oai-pmh.configuration-settings.item.post'                                    |
      | 'oai-pmh.configuration-settings.item.put'                                     |
      | 'oai-pmh.configuration-settings.item.delete'                                  |

    * def testTenant = 'testoaipmh'
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }


  Scenario: create tenant and users for testing
    * pause(5000)
    Given call read('classpath:common/eureka/setup-users.feature')