Feature: mod-calendar integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-calendar'                      |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                     |
      | 'calendar.opening-hours.collection.get'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
