Feature: mod-copycat integration tests

  Background:
    * url baseUrl
    * table modules
      | name                    |
      | 'okapi'                 |
      | 'mod-login'             |
      | 'mod-permissions'       |
      | 'mod-copycat'         |

    * table userPermissions
      | name                                                      |
      | 'copycat.profiles.collection.get'                         |
      | 'copycat.profiles.item.post'                              |
      | 'copycat.profiles.item.get'                               |
      | 'copycat.profiles.item.put'                               |
      | 'copycat.profiles.item.delete'                            |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')