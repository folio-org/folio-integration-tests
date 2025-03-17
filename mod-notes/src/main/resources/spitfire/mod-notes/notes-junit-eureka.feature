Feature: mod-notes integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                   |
      | 'configuration.entries.collection.get' |
      | 'configuration.entries.item.delete'    |
      | 'configuration.entries.item.post'      |
      | 'note.links.collection.get'            |
      | 'note.links.collection.put'            |
      | 'note.types.collection.get'            |
      | 'note.types.item.delete'               |
      | 'note.types.item.get'                  |
      | 'note.types.item.post'                 |
      | 'note.types.item.put'                  |
      | 'notes.collection.get'                 |
      | 'notes.item.get'                       |
      | 'notes.item.post'                      |
      | 'notes.item.put'                       |

    * def requiredApplications = ['app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')