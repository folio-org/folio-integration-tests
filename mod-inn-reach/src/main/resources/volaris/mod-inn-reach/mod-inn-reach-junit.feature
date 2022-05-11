Feature: mod-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-inn-reach'             |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |

    * table adminAdditionalPermissions
      | name                                                                 |

    * table userPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.all'                                      |
      | 'inn-reach.locations.all'                                            |
      | 'users.item.get'                                                     |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')
