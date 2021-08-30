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
      | 'converter-storage.jobprofile.post'  |
      | 'converter-storage.jobprofile.delete'  |
      | 'converter-storage.actionprofile.post'  |
      | 'converter-storage.actionprofile.delete'  |
      | 'converter-storage.mappingprofile.post'  |
      | 'converter-storage.mappingprofile.delete'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
