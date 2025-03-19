Feature: mod-di-converter-storage integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                                           |
#      | 'converter-storage.jobprofile.item.get'                         |
      | 'converter-storage.jobprofile.collection.get'                   |
      | 'converter-storage.jobprofile.put'                              |
      | 'converter-storage.jobprofile.post'                             |
      | 'converter-storage.jobprofile.delete'                           |
      | 'converter-storage.actionprofile.post'                          |
      | 'converter-storage.actionprofile.delete'                        |
      | 'converter-storage.mappingprofile.post'                         |
      | 'converter-storage.mappingprofile.delete'                       |
      | 'converter-storage.matchprofile.post'                           |
      | 'converter-storage.jobprofilesnapshots.post'                    |
      | 'converter-storage.jobprofilesnapshots.get'                     |
      | 'converter-storage.field-protection-settings.post'              |
      | 'converter-storage.field-protection-settings.item.get'          |
      | 'converter-storage.field-protection-settings.collection.get'    |
      | 'converter-storage.field-protection-settings.put'               |
      | 'converter-storage.field-protection-settings.delete'            |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
