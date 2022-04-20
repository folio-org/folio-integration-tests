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
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.locations.item.post'                                      |
      | 'inn-reach.locations.collection.get'                                 |
      | 'inn-reach.locations.item.get'                                       |
      | 'inn-reach.locations.item.put'                                       |
      | 'inn-reach.locations.item.delete'                                    |

    * table userPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.locations.item.post'                                      |
      | 'inn-reach.locations.collection.get'                                 |
      | 'inn-reach.locations.item.get'                                       |
      | 'inn-reach.locations.item.put'                                       |
      | 'inn-reach.locations.item.delete'                                    |
      | 'users.item.get'                                                     |
      | 'inn-reach.authentication.item.post'                                 |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')
