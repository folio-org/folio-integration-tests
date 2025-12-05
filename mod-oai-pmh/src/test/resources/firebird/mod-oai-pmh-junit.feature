Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * def checkDateByRegEx = '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-oai-pmh'               |
      | 'mod-login'                 |
      | 'mod-source-record-storage' |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                                          |
      | 'oai-pmh.records.collection.get'                              |
      | 'source-storage.records.item.get'                             |
      | 'source-storage.snapshots.post'                               |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.loan-types.item.post'                      |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.call-number-types.item.post'               |
      | 'inventory-storage.holdings-sources.item.post'                |
      | 'inventory-storage.instances.item.post'                       |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.items.item.post'                           |
      | 'inventory-storage.items.item.put'                            |
      | 'source-storage.records.post'                                 |
      | 'source-storage.records.collection.get'                       |
      | 'source-storage.records.put'                                  |
      | 'source-storage.records.delete'                               |
      | 'configuration.entries.item.delete'                           |
      | 'inventory-storage.holdings.item.put'                         |
      | 'inventory-storage.instances.collection.get'                  |
      | 'inventory-storage.instances.item.get'                        |
      | 'inventory-storage.instances.item.put'                        |
      | 'inventory-storage.items.collection.delete'                   |
      | 'inventory-storage.holdings.collection.delete'                |
      | 'inventory-storage.holdings.item.delete'                      |
      | 'inventory-storage.instances.collection.delete'               |
      | 'inventory-storage.instances.item.delete'                     |
      | 'oai-pmh.filtering-conditions.get'                            |
      | 'inventory-storage.service-points.item.post'                  |
      | 'inventory-storage.instance-formats.item.post'                |
      | 'inventory-storage.ill-policies.item.post'                    |
      | 'okapi.proxy.tenants.modules.post'                            |
      | 'okapi.proxy.tenants.modules.enabled.delete'                  |
      | 'inventory-storage.items.item.delete'                         |
      | 'okapi.proxy.tenants.modules.enabled.get'                     |
      | 'okapi.proxy.tenants.modules.enabled.post'                    |
      | 'okapi.proxy.tenants.modules.list'                            |
      | 'oai-pmh.configuration-settings.collection.get'               |
      | 'oai-pmh.configuration-settings.item.get'                     |
      | 'oai-pmh.configuration-settings.item.post'                    |
      | 'oai-pmh.configuration-settings.item.put'                     |
      | 'oai-pmh.configuration-settings.item.delete'                  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
    Given call read('classpath:global/setup-data.feature')