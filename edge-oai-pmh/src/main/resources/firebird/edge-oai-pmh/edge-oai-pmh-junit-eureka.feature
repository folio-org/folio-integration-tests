Feature: mod-audit integration tests

  Background:
    * url baseUrl

    * table adminAdditionalPermissions
      | name                                     |


    * table userPermissions
      | name                                                                          |
      | 'oai-pmh.clean-up-error-logs.post'                                            |
      | 'oai-pmh.clean-up-instances.post'                                             |
      | 'oai-pmh.filtering-conditions.get'                                            |
      | 'oai-pmh.records.collection.get'                                              |
      | 'oai-pmh.request-metadata.collection.get'                                     |
      | 'oai-pmh.request-metadata.failed-instances.collection.get'                    |
      | 'oai-pmh.request-metadata.failed-to-save-instances.collection.get'            |
      | 'oai-pmh.request-metadata.logs.item.get'                                      |
      | 'oai-pmh.request-metadata.skipped-instances.collection.get'                   |
      | 'oai-pmh.request-metadata.suppressed-from-discovery-instances.collection.get' |
      | 'oai-pmh.sets.item.collection.get'                                            |
      | 'oai-pmh.sets.item.post'                                                      |
      | 'oai-pmh.sets.item.delete'                                                    |
      | 'oai-pmh.sets.item.put'                                                       |
      | 'oai-pmh.sets.item.get'                                                       |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
