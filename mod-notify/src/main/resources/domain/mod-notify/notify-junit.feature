Feature: mod-notify integration tests

  Background:
    * url baseUrl

    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-notify'                        |
      | 'mod-sender'                        |
      | 'mod-email'                         |
      | 'mod-template-engine'               |
      | 'mod-configuration'                 |
      | 'mod-users'                         |
      | 'mod-event-config'                  |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                   |
      | 'notify.collection.get'                |
      | 'notify.item.post'                     |
      | 'notify.item.get'                      |
      | 'users.item.post'                      |
      | 'usergroups.item.post'                 |
      | 'templates.item.post'                  |
      | 'event.config.item.post'               |
      | 'email.message.collection.get'         |
      | 'patron-notice.post'                   |
      | 'configuration.entries.collection.get' |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
