Feature: mod-batch-print integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-batch-print'                   |

    * table userPermissions
      | name                                    |
      | 'batch-print.entries.item.post'         |
      | 'batch-print.entries.collection.get'    |
      | 'batch-print.entries.item.get'          |
      | 'batch-print.entries.item.put'          |
      | 'batch-print.entries.item.delete'       |
      | 'batch-print.entries.mail.post'         |
      | 'batch-print.entries.collection.delete' |
      | 'batch-print.print.read'                |
      | 'batch-print.print.write'               |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
