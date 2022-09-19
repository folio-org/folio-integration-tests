Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                 |
      | 'mod-login'          |
      | 'mod-permissions'    |
      | 'mod-entities-links' |

    * table userPermissions
      | name                                     |
      | 'notes.all'                              |
      | 'instance-authority-links.instances.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')