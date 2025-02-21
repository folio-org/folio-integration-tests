Feature: setup tenant

  Background:
    * configure readTimeout = 600000
    * table requiredModulesForConsortia
      | name                     |
      | 'mod-tags'               |
      | 'mod-users-bl'           |
      | 'mod-authtoken'          |
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

    # install required modules
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: '#(requiredModules)', tenant: '#(tenant)'}

    # set up 'admin-user' with all existing permissions of enabled modules
    * print 'SetUpAdmin (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@SetUpAdmin') admin

    # enable 'folio_users' (requires 'mod-tags', 'mod-users-bl', 'mod-authtoken', 'mod-password-validator')
    * print 'InstallModules (#(tenant))'
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: '#(requiredModulesForConsortia)', tenant: '#(tenant)'}

    # enable 'mod-consortia'
    * call login admin
    * call read('classpath:common-consortia/initData.feature@InstallModules') { modules: [{name: 'mod-consortia'}], tenant: '#(tenant)'}
