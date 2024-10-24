Feature: mod-linked-data integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                      |
      | 'mod-login'                               |
      | 'mod-permissions'                         |
      | 'mod-users'                               |
      | 'mod-search'                              |
      | 'mod-entities-links'                      |
      | 'mod-inventory'                           |
      | 'mod-inventory-storage'                   |
      | 'mod-source-record-storage'               |
      | 'mod-quick-marc'                          |
      | 'mod-linked-data'                         |

    * table userPermissions
      | name                                                           |
      | 'linked-data.resources.bib.get'                                |
      | 'linked-data.resources.bib.post'                               |
      | 'linked-data.resources.bib.put'                                |
      | 'linked-data.resources.bib.delete'                             |
      | 'linked-data.resources.bib.marc.get'                           |
      | 'linked-data.resources.reindex.post'                           |
      | 'linked-data.resources.graph.get'                              |
      | 'linked-data.profiles.get'                                     |
      | 'search.linked-data.work.collection.get'                       |
      | 'search.linked-data.hub.collection.get'                        |
      | 'search.instances.collection.get'                              |
      | 'mapping-metadata.get'                                         |
      | 'inventory-storage.instances.item.post'                        |
      | 'inventory-storage.instances.item.get'                         |
      | 'inventory-storage.instances.item.put'                         |
      | 'inventory-storage.instance-types.item.post'                   |
      | 'inventory-storage.instances.item.delete'                      |
      | 'inventory-storage.preceding-succeeding-titles.collection.get' |
      | 'inventory-storage.preceding-succeeding-titles.item.get'       |
      | 'inventory.instances.item.get'                                 |
      | 'source-storage.snapshots.post'                                |
      | 'source-storage.records.post'                                  |
      | 'source-storage.records.put'                                   |
      | 'marc-records-editor.item.post'                                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
