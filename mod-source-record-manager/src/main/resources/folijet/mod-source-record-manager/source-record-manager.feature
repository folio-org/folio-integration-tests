Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-entities-links'        |
      | 'mod-source-record-manager' |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                  |
      | 'mapping-rules.get'                   |
      | 'mapping-rules.update'                |
      | 'mapping-rules.restore'               |
      | 'change-manager.jobexecutions.post'   |
      | 'change-manager.jobexecutions.get'    |
      | 'change-manager.jobexecutions.put'    |
      | 'change-manager.records.post'         |
      | 'metadata-provider.logs.get'          |
      | 'metadata-provider.jobexecutions.get' |
      | 'mapping-metadata.get'                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')