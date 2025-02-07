Feature:

  Background:
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

  Scenario:
    * call read("classpath:common-consortia/initData.feature@Login") {tenant: '#(admin.tenant)', username: '#(admin.name)', password: '#(admin.password)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}