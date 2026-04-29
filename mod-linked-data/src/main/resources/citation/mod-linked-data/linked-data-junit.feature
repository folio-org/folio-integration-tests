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
      | 'mod-source-record-manager'               |
      | 'mod-source-record-storage'               |
      | 'mod-quick-marc'                          |
      | 'mod-linked-data'                         |
      | 'mod-linked-data-import'                  |
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
      | 'linked-data.hub.preview.get'                                  |
      | 'linked-data.hub.import.post'                                  |
      | 'linked-data.profiles.item.get'                                |
      | 'linked-data.profiles.metadata.get'                            |
      | 'linked-data.profiles.preferred.get'                           |
      | 'linked-data.profiles.preferred.post'                          |
      | 'linked-data.profiles.preferred.delete'                        |
      | 'linked-data.profiles.settings.get'                            |
      | 'linked-data.profiles.settings.post'                           |
      | 'search.linked-data.work.collection.get'                       |
      | 'search.linked-data.hub.collection.get'                        |
      | 'search.instances.collection.get'                              |
      | 'inventory.instances.item.get'                                 |

    * table adminPermissions
      | name                                                                  |
      | 'marc-records-editor.item.post'                                       |
      | 'marc-records-editor.item.put'                                        |
      | 'search.authorities.collection.get'                                   |
      | 'specification-storage.specifications.collection.get'                 |
      | 'specification-storage.specification.rules.collection.get'            |
      | 'specification-storage.specification.rules.item.patch'                |
      | 'ui-quick-marc.settings.lccn-duplicate-check.edit'                    |
      | 'mod-settings.entries.collection.get'                                 |
      | 'mod-settings.entries.item.get'                                       |
      | 'mod-settings.entries.item.put'                                       |
      | 'mod-settings.entries.item.post'                                      |
      | 'mod-settings.global.write.ui-quick-marc.lccn-duplicate-check.manage' |
      | 'mod-settings.global.read.ui-quick-marc.lccn-duplicate-check.manage'  |
      | 'inventory.instances.item.put'                                        |
      | 'browse.authorities.collection.get'                                   |
      | 'source-storage.records.formatted.item.get'                           |
      | 'linked-data.admin.caches.delete'                                     |
      | 'base-url.item.put'                                                   |

    * table linkedDataBulkImportPermissions
      | name                                                       |
      | 'linked-data-import.files.collection.post'                 |
      | 'linked-data-import.start.post'                            |
      | 'linked-data-import.jobs.item.get'                         |
      | 'linked-data-import.jobs.failed-lines.collection.get'      |
      | 'linked-data-import.jobs.item.stop.put'                  |

  Scenario: create a tenant and linked-data-cataloger user
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: Create admin user
    * call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(testAdmin)', userPermissions: '#(adminPermissions)' }

  Scenario: Create linked-data-bulk-import user
    * call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(linkedDataBulkImportUser)', userPermissions: '#(linkedDataBulkImportPermissions)' }

  Scenario: set FOLIO UI base-url for the tenant
    * call read('classpath:citation/mod-linked-data/features/util/base-url.feature@putBaseUrl')
