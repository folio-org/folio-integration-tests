Feature: edge-rtac integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'edge-rtac'               |

    * table adminAdditionalPermissions
      | name                      |

    * table userPermissions
      | name                      |

  Scenario: create tenant and users for testing
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
