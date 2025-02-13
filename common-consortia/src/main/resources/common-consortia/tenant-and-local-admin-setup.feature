Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * def requiredModulesForConsortia = ['mod-tags', 'mod-users-bl', 'mod-password-validator', 'folio_users']

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def tenant = karate.get('tenant')
    * def admin = karate.get('admin')
    * def name = 'name_tenant'
    * def description = 'tenant_description'

    # create tenant
    * print 'PostTenant (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@PostTenant') { id: '#(tenant)', name: '#(name)', description: '#(description)'}

#     install required modules
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { tenant: '#(tenant)', modules: '#(modules)'}

#    # set up 'admin-user' with all existing permissions of enabled modules
    * print 'SetUpAdmin (#(tenant))'
    * def uuidStr = callonce uuid
    * call read('classpath:common-consortia/initData.feature@SetUpAdmin') {tenant: 'consortium', token: '#(token)', username: 'consortium_admin_test', uuid: '#(uuidStr)'}

#     enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-password-validator')
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: '#(requiredModulesForConsortia)', tenant: '#(tenant)'}

#    # enable 'mod-consortia'
    * call login admin
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: ['mod-consortia'], tenant: '#(tenant)'}
