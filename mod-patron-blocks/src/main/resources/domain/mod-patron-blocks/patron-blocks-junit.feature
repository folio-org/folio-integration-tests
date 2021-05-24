Feature: mod-patron-blocks integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-patron-blocks'                 |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'patron-block-limits.item.get'      |
      | 'patron-block-limits.item.post'     |
      | 'patron-block-limits.item.put'      |
      | 'patron-block-limits.item.delete'   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
