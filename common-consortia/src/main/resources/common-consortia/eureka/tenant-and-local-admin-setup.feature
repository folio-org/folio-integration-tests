Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 40000 }
    * table requiredModulesForConsortia
      | name                     |
      | 'mod-tags'               |
      | 'mod-users-bl'           |
      | 'mod-password-validator' |
      | 'folio_users'            |
      | 'mod-consortia-keycloak' |

    * table requiredCapabilitiesForConsortia
      | name                                                  |
      | 'consortia.consortia-configuration.item.post'         |
      | 'consortia.consortia-configuration.item.delete'       |
      | 'consortia.consortium.item.post'                      |
      | 'consortia.consortium.item.put'                       |
      | 'consortia.consortium.item.get'                       |
      | 'consortia.create-primary-affiliations.item.post'     |
      | 'consortia.custom-login.item.post'                    |
      | 'consortia.identity-provider.item.post'               |
      | 'consortia.identity-provider.item.delete'             |
      | 'consortia.inventory.local.sharing-instances.execute' |
      | 'consortia.inventory.update-ownership.item.post'      |
      | 'consortia.publications.item.post'                    |
      | 'consortia.publications.item.delete'                  |
      | 'consortia.publications.item.get'                     |
      | 'consortia.publications-results.item.get'             |
      | 'consortia.sharing-instances.collection.get'          |
      | 'consortia.sharing-instances.item.post'               |
      | 'consortia.sharing-instances.item.get'                |
      | 'consortia.sharing-policies.item.post'                |
      | 'consortia.sharing-policies.item.delete'              |
      | 'consortia.sharing-roles-all.item.post'               |
      | 'consortia.sharing-roles-all.item.delete'             |
      | 'consortia.sharing-roles-capabilities.item.post'      |
      | 'consortia.sharing-roles-capabilities.item.delete'    |
      | 'consortia.sharing-roles-capability-sets.item.post'   |
      | 'consortia.sharing-roles-capability-sets.item.delete' |
      | 'consortia.sharing-roles.item.post'                   |
      | 'consortia.sharing-roles.item.delete'                 |
      | 'consortia.sharing-settings.item.post'                |
      | 'consortia.sharing-settings.item.delete'              |
      | 'consortia.sync-primary-affiliations.item.post'       |
      | 'consortia.tenants.item.post'                         |
      | 'consortia.tenants.item.delete'                       |
      | 'consortia.tenants.item.put'                          |
      | 'consortia.tenants.item.get'                          |
      | 'consortia.user-tenants.collection.get'               |
      | 'consortia.user-tenants.item.post'                    |
      | 'consortia.user-tenants.item.delete'                  |
      | 'consortia.user-tenants.item.get'                     |
      | 'tags.collection.get'                                 |
      | 'tags.item.post'                                      |
      | 'tags.item.delete'                                    |
      | 'tags.item.put'                                       |
      | 'tags.item.get'                                       |

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def description = 'tenant_description'
    * def modules = modules.concat(requiredModulesForConsortia)
    * def oldPermissions = (typeof userPermissions !== 'undefined') ? userPermissions : []
    * def userPermissions = requiredCapabilitiesForConsortia.concat(oldPermissions)

    # create tenant
    * print 'PostTenant ' + tenant
    * call read('classpath:common-consortia/eureka/initData.feature@PostTenant') { tenantId: '#(tenantId)', tenant: '#(tenant)', description: '#(description)'}

    # install required applications
    * print 'Install applications ' + tenant
    * call read('classpath:common-consortia/eureka/initData.feature@InstallApplications') { tenantId: '#(tenantId)'}

    # set up 'admin-user' with all existing permissions of enabled modules
    * print 'SetUpUser ' + tenant
    * call read('classpath:common-consortia/eureka/initData.feature@PostAdmin') {tenant: '#(tenant)', user: '#(user)'}
    # Delete after async capabilities will be fixed
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {tenant: '#(tenant)', user: '#(user)', userPermissions: '#(userPermissions)'}

    * def userPermissions = oldPermissions