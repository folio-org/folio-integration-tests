Feature: mod-feesfines integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-feesfines'                          |

    * table adminAdditionalPermissions
      | name                                     |

    * table userPermissions
      | name                                     |
      | 'owners.item.get'                        |
      | 'owners.item.post'                       |
      | 'owners.item.put'                        |
      | 'owners.item.delete'                     |
      | 'owners.collection.get'                  |
      | 'accounts.item.get'                      |
      | 'accounts.item.post'                     |
      | 'accounts.item.put'                      |
      | 'accounts.item.delete'                   |
      | 'accounts.collection.get'                |
      | 'accounts.pay.post'                      |
      | 'accounts.waive.post'                    |
      | 'accounts.cancel.post'                   |
      | 'accounts.refund.post'                   |
      | 'accounts.transfer.post'                 |
      | 'accounts.check-pay.post'                |
      | 'accounts.check-waive.post'              |
      | 'accounts.check-transfer.post'           |
      | 'accounts.check-refund.post'             |
      | 'feefines.item.get'                      |
      | 'feefines.item.post'                     |
      | 'feefines.item.put'                      |
      | 'feefines.item.delete'                   |
      | 'feefines.collection.get'                |
      | 'feefineactions.item.get'                |
      | 'feefineactions.item.post'               |
      | 'feefineactions.item.put'                |
      | 'feefineactions.item.delete'             |
      | 'feefineactions.collection.get'          |
      | 'feefine-reports.refund.post'            |
      | 'lost-item-fees-policies.item.get'       |
      | 'lost-item-fees-policies.item.post'      |
      | 'lost-item-fees-policies.item.put'       |
      | 'lost-item-fees-policies.item.delete'    |
      | 'lost-item-fees-policies.collection.get' |
      | 'payments.item.post'                     |
      | 'waives.item.post'                       |
      | 'users.item.post'                        |
      | 'transfers.item.post'                    |
      | 'manualblocks.item.get'                  |
      | 'manualblocks.item.post'                 |
      | 'manualblocks.item.put'                  |
      | 'manualblocks.item.delete'               |
      | 'manualblocks.collection.get'            |
      | 'manual-block-templates.item.get'        |
      | 'manual-block-templates.item.post'       |
      | 'manual-block-templates.item.put'        |
      | 'manual-block-templates.item.delete'     |
      | 'manual-block-templates.collection.get'  |
      | 'overdue-fines-policies.item.get'        |
      | 'overdue-fines-policies.item.post'       |
      | 'overdue-fines-policies.item.put'        |
      | 'overdue-fines-policies.item.delete'     |
      | 'overdue-fines-policies.collection.get'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
