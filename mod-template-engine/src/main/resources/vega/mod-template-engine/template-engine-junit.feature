Feature: mod-template-engine integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-template-engine'               |

    * table userPermissions
      | name                                |
      | 'templates.collection.get'          |
      | 'templates.item.post'               |
      | 'templates.item.get'                |
      | 'templates.item.put'                |
      | 'templates.item.delete'             |
      | 'template-request.post'             |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
