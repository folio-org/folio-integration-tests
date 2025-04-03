Feature: mod-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-inn-reach'             |
      | 'mod-inventory-storage'     |
      | 'mod-source-record-storage' |
      | 'mod-circulation-storage'   |
      | 'mod-feesfines'             |

    * table userPermissions
      | name                                                     |
      | 'inn-reach.all'                                          |
      | 'inventory-storage.instances.item.post'                  |
      | 'source-storage.records.post'                            |
      | 'source-storage.snapshots.post'                          |
      | 'inn-reach.marc-record-transformation.item.get'          |
      | 'inventory-storage.all'                                  |
      | 'inventory.all'                                          |
      | 'configuration.entries.collection.get'                   |
      | 'configuration.entries.item.post'                        |
      | 'configuration.entries.item.delete'                      |
      | 'usergroups.item.post'                                   |
      | 'perms.permissions.item.post'                            |
      | 'perms.users.item.put'                                   |
      | 'perms.users.item.post'                                  |
      | 'users.collection.get'                                   |
      | 'users.item.get'                                         |
      | 'users.item.post'                                        |
      | 'circulation-storage.request-preferences.collection.get' |
      | 'circulation-storage.request-preferences.item.post'      |
      | 'manualblocks.collection.get'                            |
      | 'overdue-fines-policies.item.get'                        |
      | 'lost-item-fees-policies.item.get'                       |
      | 'circulation-storage.loans.item.get'                     |
      | 'circulation.requests.item.get'                          |
      | 'circulation.requests.item.delete'                       |
      | 'circulation.requests.item.put'                          |
      | 'patron-blocks.automated-patron-blocks.collection.get'   |
      | 'inn-reach.agency-mappings.item.put'                     |
      | 'inn-reach.agency-mappings.item.get'                     |
      | 'inn-reach.central-servers.item.post'                    |
      | 'inn-reach.central-servers.collection.get'               |
      | 'inn-reach.central-servers.item.get'                     |
      | 'inn-reach.locations.item.post'                          |
      | 'inn-reach.locations.item.get'                           |
      | 'inn-reach.locations.item.put'                           |
      | 'inn-reach.locations.item.delete'                        |
      | 'inn-reach.locations.collection.get'                     |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/eureka/setup-users.feature')
