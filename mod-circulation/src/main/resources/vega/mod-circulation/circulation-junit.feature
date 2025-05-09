Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-users-bl'            |
      | 'mod-configuration'       |
      | 'mod-settings'            |
      | 'okapi'                   |
      | 'mod-pubsub'              |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'mod-circulation-storage' |
      | 'mod-circulation'         |
      | 'mod-feesfines'           |
      | 'mod-patron-blocks'       |
      | 'mod-calendar'            |

    * table userPermissions
      | name                                                           |
      | 'accounts.collection.get'                                      |
      | 'accounts.item.put'                                            |
      | 'accounts.check-pay.post'                                      |
      | 'accounts.pay.post'                                            |
      | 'patron-blocks.automated-patron-blocks.collection.get'         |
      | 'check-in-storage.check-ins.collection.get'                    |
      | 'check-in-storage.check-ins.item.get'                          |
      | 'circulation-storage.cancellation-reasons.item.post'           |
      | 'circulation-storage.cancellation-reasons.item.delete'         |
      | 'circulation-storage.circulation-rules.put'                    |
      | 'circulation-storage.loan-policies.item.post'                  |
      | 'circulation-storage.loans.item.get'                           |
      | 'circulation.renew-by-barcode.post'                            |
      | 'circulation-storage.patron-notice-policies.item.post'         |
      | 'circulation-storage.request-policies.item.post'               |
      | 'circulation-storage.request-batch.item.post'                  |
      | 'circulation-storage.requests.collection.get'                  |
      | 'circulation.check-in-by-barcode.post'                         |
      | 'circulation.check-out-by-barcode.post'                        |
      | 'circulation.loans.claim-item-returned.post'                   |
      | 'circulation.loans.collection.get'                             |
      | 'circulation.loans.declare-item-lost.post'                     |
      | 'circulation.loans.item.get'                                   |
      | 'circulation.requests.collection.get'                          |
      | 'circulation.requests.hold-shelf-clearance-report.get'         |
      | 'circulation.requests.item.get'                                |
      | 'circulation.requests.item.post'                               |
      | 'circulation.requests.queue.reorder.collection.post'           |
      | 'circulation.requests.item.delete'                             |
      | 'configuration.entries.collection.get'                         |
      | 'configuration.entries.item.post'                              |
      | 'configuration.entries.item.delete'                            |
      | 'circulation.pick-slips.get'                                   |
      | 'circulation.requests.item.put'                                |
      | 'circulation.requests.item.move.post'                          |
      | 'feefineactions.item.post'                                     |
      | 'feefineactions.collection.get'                                |
      | 'feefines.item.post'                                           |
      | 'inventory-storage.contributor-name-types.item.post'           |
      | 'inventory-storage.holdings.item.post'                         |
      | 'inventory-storage.holdings-sources.item.post'                 |
      | 'inventory-storage.instance-relationships.collection.get'      |
      | 'inventory-storage.instance-relationships.item.delete'         |
      | 'inventory-storage.instance-relationships.item.post'           |
      | 'inventory-storage.instance-relationships.item.put'            |
      | 'inventory-storage.instance-types.item.post'                   |
      | 'inventory-storage.instances.item.get'                         |
      | 'inventory-storage.instances.item.post'                        |
      | 'inventory-storage.items.item.get'                             |
      | 'inventory-storage.loan-types.item.post'                       |
      | 'inventory-storage.location-units.campuses.item.post'          |
      | 'inventory-storage.location-units.institutions.item.post'      |
      | 'inventory-storage.location-units.libraries.item.post'         |
      | 'inventory-storage.locations.item.post'                        |
      | 'inventory-storage.material-types.item.post'                   |
      | 'inventory-storage.preceding-succeeding-titles.collection.get' |
      | 'inventory-storage.preceding-succeeding-titles.item.delete'    |
      | 'inventory-storage.preceding-succeeding-titles.item.post'      |
      | 'inventory-storage.preceding-succeeding-titles.item.put'       |
      | 'inventory-storage.service-points.item.post'                   |
      | 'inventory-storage.service-points.item.put'                    |
      | 'inventory-storage.service-points.item.delete'                 |
      | 'inventory.instances.item.post'                                |
      | 'inventory.items.item.mark-in-process-non-requestable.post'    |
      | 'inventory.items.item.mark-restricted.post'                    |
      | 'inventory.items.item.get'                                     |
      | 'inventory.items.item.post'                                    |
      | 'lost-item-fees-policies.item.post'                            |
      | 'lost-item-fees-policies.item.get'                             |
      | 'manualblocks.collection.get'                                  |
      | 'overdue-fines-policies.item.post'                             |
      | 'overdue-fines-policies.item.get'                              |
      | 'owners.item.post'                                             |
      | 'payments.item.post'                                           |
      | 'patron-block-conditions.collection.get'                       |
      | 'patron-block-conditions.item.put'                             |
      | 'patron-block-limits.item.post'                                |
      | 'patron-block-limits.item.delete'                              |
      | 'patron-blocks.synchronization.job.post'                       |
      | 'pubsub.publishers.get'                                        |
      | 'pubsub.publishers.delete'                                     |
      | 'pubsub.publishers.post'                                       |
      | 'usergroups.item.post'                                         |
      | 'usergroups.collection.get'                                    |
      | 'users.item.post'                                              |
      | 'users.item.get'                                               |
      | 'user-summary.item.get'                                        |
      | 'circulation.requests.queue.collection.get'                    |
      | 'okapi.proxy.self.timers.patch'                                |
      | 'circulation.rules.loan-policy.get'                            |
      | 'circulation.rules.overdue-fine-policy.get'                    |
      | 'circulation.rules.lost-item-policy.get'                       |
      | 'circulation.rules.notice-policy.get'                          |
      | 'circulation.rules.request-policy.get'                         |
      | 'circulation.rules.get'                                        |
      | 'circulation.rules.put'                                        |
      | 'calendar.view'                                                |
      | 'calendar.create'                                              |
      | 'calendar.delete'                                              |
      | 'circulation-storage.fixed-due-date-schedules.item.post'       |
      | 'circulation-storage.loan-policies.item.get'                   |
      | 'mod-settings.global.write.mod-circulation'                    |
      | 'mod-settings.entries.item.post'                               |
      | 'circulation.settings.item.post'                               |
      | 'circulation.settings.item.delete'                             |
      | 'circulation.settings.collection.get'                          |
      | 'circulation-storage.circulation-settings.item.put'            |
      | 'circulation.print-events-entry.item.post'                     |
      | 'login.item.post'                                              |
      | 'perms.permissions.get'                                        |
      | 'perms.users.item.post'                                        |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
