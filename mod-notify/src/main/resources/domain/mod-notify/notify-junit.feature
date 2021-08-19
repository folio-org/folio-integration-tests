Feature: mod-notify integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-notify'                        |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'notify.collection.get'             |
      | 'notify.item.post'                  |
      | 'notify.item.get'                   |
      | 'users.item.post'                   |
      | 'usergroups.item.post'              |
      | 'templates.item.post'               |
      | 'event.config.item.post'            |
      | 'email.message.collection.get'      |
      | 'patron-notice.post'                |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
