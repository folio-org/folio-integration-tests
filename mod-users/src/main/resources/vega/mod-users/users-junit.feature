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
      | 'users.profile-picture.item.post'                              |
      | 'users.profile-picture.item.put'                               |
      | 'users.profile-picture.item.delete'                            |
      | 'users.collection.delete'                                      |
      | 'users.settings.all'                                           |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
