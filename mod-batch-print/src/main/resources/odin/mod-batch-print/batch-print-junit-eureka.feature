Feature: mod-batch-print integration tests

  Background:
    * url baseUrl

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

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal', 'app-acquisitions']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
