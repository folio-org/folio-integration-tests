Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * def requiredModulesForConsortia = ['mod-tags', 'mod-users-bl', 'mod-password-validator', 'folio_users']

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def tenant = karate.get('tenant')
    * def admin = karate.get('admin')
    * def test_admin = karate.get('test_admin')
    * def test_user = karate.get('test_user')
    * def description = 'tenant_description'

    # create tenant
    * print 'PostTenant (#(tenant.name))'
    * call read('classpath:common-consortia/initData.feature@PostTenant') { tenant: '#(tenant)', description: '#(description)', token: '#(token)'}

##     install required modules
#    * print 'InstallModules (#(tenant.name))'
#    * call read('classpath:common-consortia/initData.feature@InstallModules') { tenant: '#(tenant)', modules: '#(modules)', token: '#(token)'}
#
#    # set up 'admin-user' with all existing permissions of enabled modules
#    * print 'SetUpAdmin (#(tenant))'
#    * call read('classpath:common-consortia/initData.feature@SetUpAdmin') {tenant: '#(tenant)', user: '#(test_admin)', token: '#(token)'}
#
##     enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-password-validator')
#    * print 'InstallModules (#(tenant))'
#    * call read('classpath:common-consortia/initData.feature@InstallModules') { tenant: '#(tenant)', modules: '#(requiredModulesForConsortia)', token: '#(token)'}
#
###    # enable 'mod-consortia-keycloak' app-consortia-1.0.0-SNAPSHOT.1358
#    * call read('classpath:common-consortia/initData.feature@InstallApplications') { applicationIds: ['app-consortia-1.0.0-SNAPSHOT.1358'], tenant: '#(tenant)', token: '#(token)'}
