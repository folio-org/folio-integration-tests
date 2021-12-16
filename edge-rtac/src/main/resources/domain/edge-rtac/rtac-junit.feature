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
    # for edge-modules we can not use system-managed tenant as of now ,the problem is that the secret store on the hosting side needs to be aware of the information in them.
    #In the hosted reference environments a diku user (for the diku tenant) has been created, with appropriate permissions, and added to the secret store.
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
