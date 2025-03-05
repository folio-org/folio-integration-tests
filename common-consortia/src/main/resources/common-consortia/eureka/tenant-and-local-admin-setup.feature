Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 40000 }

  # Parameters:
  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def description = 'tenant_description'

    # create tenant
    * print 'PostTenant (#(tenant.name))'
    * call read('classpath:common-consortia/eureka/initData.feature@PostTenant') { tenant: '#(tenant)', description: '#(description)', token: '#(token)'}

    # install required modules
    * print 'InstallModules (#(tenant.name))'
    * call read('classpath:common-consortia/eureka/initData.feature@InstallModules') { tenant: '#(tenant)', token: '#(token)'}

    * karate.pause(15000)

#     set up 'admin-user' with all existing permissions of enabled modules
#    * print 'SetUpAdmin (#(tenant))'
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {tenant: '#(tenant)', client: '#(masterClient)'}
#    * def testClient = {secret: '#(result.sidecarSecret)', realm: '#(tenant.name)', id: 'sidecar-module-access-client'}
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(testClient)'}
#    * call read('classpath:common-consortia/eureka/initData.feature@SetUpAdmin') {tenant: '#(tenant)', user: '#(admin)', token: '#(result.token)'}
