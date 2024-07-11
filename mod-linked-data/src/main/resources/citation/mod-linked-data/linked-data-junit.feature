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
      | 'mod-linked-data'                         |

    * table userPermissions
      | name                                          |
      | 'linked-data.resources.bib.get'               |
      | 'linked-data.resources.bib.post'              |
      | 'linked-data.resources.bib.put'               |
      | 'linked-data.resources.bib.delete'            |
      | 'linked-data.resources.bib.marc.get'          |
      | 'linked-data.resources.reindex.post'          |
      | 'linked-data.resources.graph.get'             |
      | 'linked-data.profiles.get'                    |
      | 'search.linked-data.work.collection.get'      |
      | 'search.linked-data.authority.collection.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
