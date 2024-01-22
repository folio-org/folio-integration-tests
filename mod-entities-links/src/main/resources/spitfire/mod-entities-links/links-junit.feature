Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-entities-links'        |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                                 |
      | 'instance-authority-links.instances.all'             |
      | 'inventory-storage.all'                              |
      | 'inventory-storage.authorities.all'                  |
      | 'source-storage.all'                                 |
      | 'inventory-storage.authority-source-files.item.post' |
      | 'user-tenants.collection.get'                        |
      | 'inventory-storage.authorities.collection.get'       |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')