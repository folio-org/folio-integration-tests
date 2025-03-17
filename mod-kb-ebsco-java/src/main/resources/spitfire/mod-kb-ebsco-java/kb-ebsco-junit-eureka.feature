Feature: mod-kb-ebsco-java integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000

    * table userPermissions
      | name                                                   |
      | 'data-export.job.item.download'                        |
      | 'data-export.job.item.get'                             |
      | 'data-export.job.item.post'                            |
      | 'erm.agreements.item.delete'                           |
      | 'erm.agreements.item.post'                             |
      | 'erm.agreements.item.put'                              |
      | 'erm.entitlements.collection.get'                      |
      | 'kb-ebsco.access-types.collection.get'                 |
      | 'kb-ebsco.access-types.item.get'                       |
      | 'kb-ebsco.kb-credentials.access-types.collection.get'  |
      | 'kb-ebsco.kb-credentials.access-types.collection.post' |
      | 'kb-ebsco.kb-credentials.access-types.item.delete'     |
      | 'kb-ebsco.kb-credentials.access-types.item.get'        |
      | 'kb-ebsco.kb-credentials.access-types.item.put'        |
      | 'kb-ebsco.kb-credentials.collection.get'               |
      | 'kb-ebsco.kb-credentials.collection.post'              |
      | 'kb-ebsco.kb-credentials.item.delete'                  |
      | 'kb-ebsco.kb-credentials.item.get'                     |
      | 'kb-ebsco.kb-credentials.item.put'                     |
      | 'kb-ebsco.kb-credentials.key.item.get'                 |
      | 'kb-ebsco.kb-credentials.proxy-types.collection.get'   |
      | 'kb-ebsco.kb-credentials.root-proxy.get'               |
      | 'kb-ebsco.kb-credentials.root-proxy.put'               |
      | 'kb-ebsco.kb-credentials.uc.collection.post'           |
      | 'kb-ebsco.kb-credentials.uc.item.get'                  |
      | 'kb-ebsco.kb-credentials.uc.item.patch'                |
      | 'kb-ebsco.kb-credentials.uc.key.item.get'              |
      | 'kb-ebsco.kb-credentials.users.collection.get'         |
      | 'kb-ebsco.kb-credentials.users.collection.post'        |
      | 'kb-ebsco.kb-credentials.users.item.delete'            |
      | 'kb-ebsco.package-resources.collection.get'            |
      | 'kb-ebsco.package-tags.put'                            |
      | 'kb-ebsco.packages-bulk.collection.get'                |
      | 'kb-ebsco.packages.collection.get'                     |
      | 'kb-ebsco.packages.collection.post'                    |
      | 'kb-ebsco.packages.item.delete'                        |
      | 'kb-ebsco.packages.item.get'                           |
      | 'kb-ebsco.packages.item.put'                           |
      | 'kb-ebsco.provider-packages.collection.get'            |
      | 'kb-ebsco.provider-tags.put'                           |
      | 'kb-ebsco.providers.collection.get'                    |
      | 'kb-ebsco.providers.item.get'                          |
      | 'kb-ebsco.providers.item.put'                          |
      | 'kb-ebsco.proxy-types.collection.get'                  |
      | 'kb-ebsco.resource-tags.put'                           |
      | 'kb-ebsco.resources-bulk.collection.get'               |
      | 'kb-ebsco.resources.collection.post'                   |
      | 'kb-ebsco.resources.item.delete'                       |
      | 'kb-ebsco.resources.item.get'                          |
      | 'kb-ebsco.resources.item.put'                          |
      | 'kb-ebsco.root-proxy.get'                              |
      | 'kb-ebsco.tags.collection.get'                         |
      | 'kb-ebsco.titles.collection.get'                       |
      | 'kb-ebsco.titles.collection.post'                      |
      | 'kb-ebsco.titles.item.get'                             |
      | 'kb-ebsco.titles.item.put'                             |
      | 'kb-ebsco.uc-credentials.item.get'                     |
      | 'kb-ebsco.uc-credentials.item.put'                     |
      | 'kb-ebsco.uc.item.get'                                 |
      | 'kb-ebsco.unique.tags.collection.get'                  |
      | 'note.types.item.delete'                               |
      | 'note.types.item.post'                                 |
      | 'notes.item.post'                                      |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    * callonce read('classpath:common/eureka/setup-users.feature')
    * eval java.lang.System.setProperty('mod-kb-ebsco-java-testUserId', karate.get('userId'))


  Scenario: Create second user for feature "User Assignment"
    * callonce read('classpath:spitfire/mod-kb-ebsco-java/eureka-features/setup/setup-dummy-user.feature')
    * eval java.lang.System.setProperty('mod-kb-ebsco-java-dummyUserId', karate.get('dummyUserId'))