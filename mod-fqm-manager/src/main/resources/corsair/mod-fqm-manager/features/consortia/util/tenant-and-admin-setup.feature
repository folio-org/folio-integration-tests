Feature: setup tenant

  @SetupTenant
  Scenario: Post tenant, enable all required modules, and setup admin
    * def tenant = karate.get('tenant')
    * def admin = karate.get('admin')
    * def name = tenant + ' name'
    * def description = tenant + ' description'

    # create tenant
    * call read('util/initData.feature@PostTenant') { id: '#(tenant)', name: '#(name)', description: '#(description)'}

    # install mod-authtoken module
    * call read('util/initData.feature@InstallModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(tenant)'}

    # install required modules
    * call read('util/initData.feature@InstallModules') { modules: '#(requiredModules)', tenant: '#(tenant)'}

    # disable mod-authtoken module
    * def disabledResponse = call read('util/initData.feature@DisableModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(tenant)'}

    # set up 'admin-user' with all existing permissions of enabled modules
    * call read('util/initData.feature@SetUpAdmin') admin

    # # install mod-authtoken module
    * call read('util/initData.feature@Install') { disabledResponse: '#(disabledResponse)', tenant: '#(tenant)'}

    # enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-authtoken', 'mod-password-validator')
    * call read('util/initData.feature@InstallModules') { modules: [{name: 'folio_users'}], tenant: '#(tenant)'}

    # enable 'mod-consortia'
    * call read('util/initData.feature@InstallModules') { modules: [{name: 'mod-consortia'}], tenant: '#(tenant)'}

    * call read('util/initData.feature@InstallModules') { modules: [{name: 'mod-fqm-manager'}], tenant: '#(tenant)'}