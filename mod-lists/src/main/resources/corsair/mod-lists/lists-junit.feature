Feature: mod-lists integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-inventory'                     |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |
      | 'mod-lists'                         |

    * table userPermissions
      | name                                          |
      | 'addresstypes.item.post'                      |
      | 'addresstypes.item.delete'                    |
      | 'users.item.post'                             |
      | 'users.item.delete'                           |
      | 'fqm.query.all'                               |
      | 'lists.collection.get'                        |
      | 'lists.collection.post'                       |
      | 'lists.item.get'                              |
      | 'lists.item.contents.get'                     |
      | 'lists.item.refresh'                          |
      | 'lists.item.refresh.cancel'                   |
      | 'lists.item.export.post'                      |
      | 'lists.item.export.get'                       |
      | 'lists.item.export.download.get'              |
      | 'lists.item.export.cancel'                    |
      | 'lists.item.delete'                           |
      | 'lists.item.update'                           |
      | 'lists.configuration.get'                     |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
