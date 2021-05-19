Feature: mod-feesfines integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-feesfines'                     |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'owners.item.get'                   |
      | 'owners.item.post'                  |
      | 'owners.item.put'                   |
      | 'owners.item.delete'                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
