Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |
      | 'mod-notes'         |

    * table userPermissions
      | name                                   |
      | 'notes.all'                            |
      | 'configuration.entries.collection.get' |
      | 'configuration.entries.item.post'      |
      | 'configuration.entries.item.delete'    |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')