Feature: mod-data-import-converter-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-data-import-converter-storage' |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'converter-storage.jobprofile.get'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
