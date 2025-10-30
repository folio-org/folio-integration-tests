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
      | 'mod-record-specifications'               |
      | 'mod-settings'                            |
      | 'folio_quick-marc'                        |

    * table userPermissions
      | name                                                           |
      | 'linked-data.resources.bib.get'                                |
      | 'linked-data.resources.bib.post'                               |
      | 'linked-data.resources.bib.put'                                |
      | 'linked-data.resources.bib.delete'                             |
      | 'linked-data.resources.bib.marc.get'                           |
      | 'linked-data.resources.reindex.post'                           |
      | 'linked-data.resources.graph.get'                              |
      | 'linked-data.resources.rdf.get'                                |
      | 'linked-data.resources.bib.id.get'                             |
      | 'linked-data.resources.support-check.get'                      |
      | 'linked-data.resources.preview.get'                            |
      | 'linked-data.resources.import.post'                            |
      | 'linked-data.import.file.post'                                 |
      | 'search.linked-data.work.collection.get'                       |
      | 'search.linked-data.hub.collection.get'                        |
      | 'search.instances.collection.get'                              |
      | 'inventory-storage.instances.item.post'                        |
      | 'inventory-storage.instances.item.get'                         |
      | 'inventory-storage.instances.item.put'                         |
      | 'inventory-storage.instances.item.delete'                      |
      | 'inventory-storage.preceding-succeeding-titles.collection.get' |
      | 'inventory-storage.preceding-succeeding-titles.item.get'       |
      | 'inventory.instances.item.get'                                 |
      | 'inventory.instances.item.put'                                 |
      | 'source-storage.snapshots.post'                                |
      | 'source-storage.records.post'                                  |
      | 'source-storage.records.generation.item.put'                   |
      | 'source-storage.records.formatted.item.get'                    |
      | 'marc-records-editor.item.post'                                |
      | 'marc-records-editor.item.put'                                 |
      | 'browse.authorities.collection.get'                            |
      | 'specification-storage.specifications.collection.get'          |
      | 'specification-storage.specification.rules.collection.get'     |
      | 'specification-storage.specification.rules.item.patch'         |
      | 'ui-quick-marc.settings.lccn-duplicate-check.edit'             |
      | 'mod-settings.entries.collection.get'                          |
      | 'mod-settings.entries.item.get'                                |
      | 'mod-settings.entries.item.put'                                |
      | 'mod-settings.entries.item.post'                               |
      | 'mod-settings.global.write.ui-quick-marc.lccn-duplicate-check.manage' |
      | 'mod-settings.global.read.ui-quick-marc.lccn-duplicate-check.manage' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
