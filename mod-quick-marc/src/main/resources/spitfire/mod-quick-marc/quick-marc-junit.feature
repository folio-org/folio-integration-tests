Feature: mod-quick-marc integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-quick-marc'                    |
      | 'mod-source-record-manager'         |
      | 'mod-source-record-storage'         |
      | 'mod-inventory'                     |
      | 'mod-inventory-storage'             |
      | 'mod-entities-links'                |

    * table userPermissions
      | name                                                |
      | 'configuration.all'                                 |
      | 'inventory-storage.all'                             |
      | 'source-storage.all'                                |
      | 'marc-records-editor.all'                           |
      | 'metadata-provider.logs.get'                        |
      | 'change-manager.jobexecutions.get'                  |
      | 'converter-storage.field-protection-settings.get'   |
      | 'instance-authority-links.instances.collection.put' |
      | 'instance-authority-links.instances.collection.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
