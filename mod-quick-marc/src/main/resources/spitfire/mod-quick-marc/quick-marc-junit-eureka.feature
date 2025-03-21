Feature: mod-quick-marc integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-quick-marc'            |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |
      | 'mod-entities-links'        |
      | 'mod-record-specifications' |

    * table userPermissions
      | name                                                        |
      | 'instance-authority-links.authorities.bulk.post'            |
      | 'instance-authority-links.instances.collection.get'         |
      | 'inventory-storage.authorities.item.delete'                 |
      | 'inventory-storage.authorities.item.get'                    |
      | 'inventory-storage.authorities.item.post'                   |
      | 'inventory-storage.authority-source-files.item.post'        |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings-types.item.post'                |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.instances.item.post'                     |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.item.post'                     |
      | 'marc-records-editor.item.get'                              |
      | 'marc-records-editor.item.post'                             |
      | 'marc-records-editor.item.put'                              |
      | 'marc-records-editor.status.item.get'                       |
      | 'marc-records-editor.validate.post'                         |
      | 'source-storage.records.collection.get'                     |
      | 'source-storage.records.post'                               |
      | 'source-storage.snapshots.post'                             |
      | 'source-storage.source-records.collection.get'              |
      | 'source-storage.source-records.item.get'                    |
      | 'specification-storage.field.indicators.item.post'          |
      | 'specification-storage.field.subfields.item.post'           |
      | 'specification-storage.indicator.indicator-codes.item.post' |
      | 'specification-storage.specification.fields.item.post'      |
      | 'specification-storage.specifications.item.get'             |
      | 'specification-storage.subfields.item.put'                  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
