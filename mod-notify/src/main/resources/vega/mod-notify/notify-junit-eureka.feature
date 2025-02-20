Feature: mod-notify integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                   |
      | 'notify.collection.get'                |
      | 'notify.item.post'                     |
      | 'notify.item.get'                      |
      | 'users.item.post'                      |
      | 'notify.users.item.post'               |
      | 'usergroups.item.post'                 |
      | 'templates.item.post'                  |
      | 'event.config.item.post'               |
      | 'email.message.collection.get'         |
      | 'patron-notice.post'                   |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
