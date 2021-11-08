Feature: mod-users integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-circulation-storage' |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                                           |
      | 'users.item.post'                                              |
      | 'usergroups.item.post'                                         |
      | 'perms.permissions.item.post'                                  |
      | 'perms.users.item.put'                                         |
      | 'perms.users.item.post'                                        |
      | 'circulation-storage.request-preferences.item.post'            |
      | 'users.collection.get'                                         |
      | 'users.item.get'                                               |
      | 'proxiesfor.item.post'                                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
