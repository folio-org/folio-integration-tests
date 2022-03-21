Feature: mod-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-inn-reach'     |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |
      | 'mod-users'         |

    * table adminAdditionalPermissions
      | name                                                                 |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inn-reach.central-servers.item.get'                                 |
      | 'inn-reach.central-servers.item.post'                                |
      | 'users.item.get'                                                     |

    * table userPermissions
      | name                                                                 |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inn-reach.central-servers.item.get'                                 |
      | 'inn-reach.central-servers.item.post'                                |
      | 'users.item.get'                                                     |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')
