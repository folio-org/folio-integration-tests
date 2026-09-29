Feature: ERM (mod-agreements) integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000

    * table modules
      | name                |
      | 'mod-login'         |
      | 'mod-notes'         |
      | 'mod-users'         |
      | 'mod-agreements'    |
      | 'mod-permissions'   |
      | 'mod-kb-ebsco-java' |
      | 'mod-configuration' |

    * table userPermissions
      | name                                                      |
      | 'erm.admin.action.triggerEntitlementEholdingsJob.execute' |
      | 'erm.agreements.item.get'                                 |
      | 'erm.agreements.item.post'                                |
      | 'erm.agreements.item.put'                                 |
      | 'erm.agreements.item.delete'                              |
      | 'erm.entitlements.collection.get'                         |
      | 'erm.entitlements.item.get'                               |
      | 'erm.entitlements.item.put'                               |
      | 'erm.entitlements.item.delete'                            |
      | 'erm.jobs.collection.get'                                 |
      | 'erm.jobs.infoLog.collection.get'                         |
      | 'erm.jobs.errorLog.collection.get'                        |
      | 'kb-ebsco.kb-credentials.collection.get'                  |
      | 'kb-ebsco.kb-credentials.collection.post'                 |
      | 'kb-ebsco.kb-credentials.item.delete'                     |
      | 'kb-ebsco.package-resources.collection.get'               |
      | 'kb-ebsco.packages.collection.get'                        |
      | 'kb-ebsco.packages.collection.post'                       |
      | 'kb-ebsco.packages.item.get'                              |
      | 'kb-ebsco.packages.item.delete'                           |

  Scenario: create tenant and users for testing
    * callonce read('classpath:common/eureka/setup-users.feature')
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }
