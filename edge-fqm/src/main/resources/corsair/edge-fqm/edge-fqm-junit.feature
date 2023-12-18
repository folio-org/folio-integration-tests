Feature: edge-fqm integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-inventory-storage'             |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |
      | 'edge-fqm'                          |

    * table userPermissions
      | name                                                      |
      | 'fqm.query.all'                                           |
      | 'fqm.entityTypes.item.columnValues.get'                   |

  Scenario: create tenant and data for testing
    * callonce login admin