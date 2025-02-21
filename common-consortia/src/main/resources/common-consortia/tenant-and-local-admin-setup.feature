Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * table requiredModulesForConsortia
      | name                     |
      | 'mod-tags'               |
      | 'mod-users-bl'           |
      | 'mod-password-validator' |
      | 'folio_users'            |

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def tenant = karate.get('tenant')
    * def admin = karate.get('admin')
    * def name = tenant + ' name'
    * def description = tenant + ' description'

    # create tenant
    * print 'PostTenant (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@PostTenant') { id: '#(tenant)', name: '#(name)', description: '#(description)'}

    # install mod-authtoken module
    * print 'InstallModules mod-authtoken (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(tenant)'}

    # install required modules
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: '#(requiredModules)', tenant: '#(tenant)'}

    # disable mod-authtoken module
    * print 'DisableModules mod-authtoken (#(tenant))'
    * def disabledResponse = call read('classpath:common-consortia/initData.feature@DisableModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(tenant)'}

    # set up 'admin-user' with all existing permissions of enabled modules
    * print 'SetUpAdmin (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@SetUpAdmin') admin

    # install mod-authtoken module
    * print 'Install mod-authtoken (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@Install') { disabledResponse: '#(disabledResponse)', tenant: '#(tenant)'}

    # enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-authtoken', 'mod-password-validator')
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: '#(requiredModulesForConsortia)', tenant: '#(tenant)'}

    # enable 'mod-consortia'
    * call login admin
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: [{name: 'mod-consortia'}], tenant: '#(tenant)'}