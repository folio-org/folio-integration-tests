Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |
      | 'mod-inventory-storage'           |

    * table userPermissions
      | name                                                          |
      | 'oai-pmh.all'                                                 |
      | 'configuration.all'                                           |
      | 'inventory-storage.all'                                       |
      | 'source-storage.all'                                          |
      | 'oai-pmh.records.collection.get'                              |
      | 'source-storage.records.item.get'                             |
      | 'source-storage.snapshots.post'                               |
      | 'configuration.entries.collection.get'                        |
      | 'configuration.entries.item.put'                              |
      | 'configuration.entries.item.get'                              |
      | 'configuration.entries.item.post'                             |
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
    |'source-storage.records.post'|



    * url pmhUrl
    * def checkDateByRegEx = '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'
    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal', 'app-oai-pmh']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')