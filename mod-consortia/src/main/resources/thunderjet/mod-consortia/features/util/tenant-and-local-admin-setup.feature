Feature: setup tenant

  Background:
    * configure readTimeout = 600000

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def tenant = karate.get('tenant')
    * def admin = karate.get('admin')
    * def name = tenant + ' name'
    * def description = tenant + ' description'

    # create tenant
    * call read('features/util/initData.feature@PostTenant') { id: '#(tenant)', name: '#(name)', description: '#(description)'}

    # install required modules
    * call read('features/util/initData.feature@InstallModules') { modules: '#(requiredModules)', tenant: '#(tenant)'}

    # set up 'admin-user' with all existing permissions of enabled modules
    * call read('features/util/initData.feature@SetUpAdmin') admin

    # enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-authtoken', 'mod-password-validator')
    * call read('features/util/initData.feature@InstallModules') { modules: [{name: 'folio_users'}], tenant: '#(tenant)'}

    # enable 'mod-consortia'
    * call read('features/util/initData.feature@InstallModules') { modules: [{name: 'mod-consortia'}], tenant: '#(tenant)'}
