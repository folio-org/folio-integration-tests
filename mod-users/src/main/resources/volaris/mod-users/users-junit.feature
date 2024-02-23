Feature: mod-users integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |

    * table userPermissions
      | name                                                           |
      | 'users.item.post'                                              |
      | 'usergroups.item.post'                                         |
      | 'perms.permissions.item.post'                                  |
      | 'perms.users.item.put'                                         |
      | 'perms.users.item.post'                                        |
      | 'users.collection.get'                                         |
      | 'users.item.get'                                               |
      | 'proxiesfor.item.post'                                         |
      | 'users.profile-picture.item.get'                               |
      | 'users.configurations.item.get'                                |
      | 'users.configurations.item.put'                                |
      | 'users.profile-picture.item.post'                              |
      | 'users.profile-picture.item.put'                               |
      | 'users.profile-picture.item.delete'                            |
      | 'users.collection.delete'                                      |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
