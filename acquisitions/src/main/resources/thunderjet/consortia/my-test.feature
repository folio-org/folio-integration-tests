Feature:

  Background:
    * def requiredModules = ['mod-permissions', 'mod-configuration', 'mod-login-keycloak', 'mod-users', 'mod-pubsub', 'mod-audit', 'mod-orders-storage', 'mod-orders', 'mod-invoice-storage', 'mod-invoice', 'mod-finance-storage', 'mod-finance', 'mod-organizations-storage', 'mod-organizations', 'mod-inventory-storage', 'mod-inventory', 'mod-circulation-storage', 'mod-circulation', 'mod-feesfines']
    * def requiredModulesForConsortia = ['mod-tags', 'mod-users-bl', 'mod-password-validator', 'folio_users']
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}
    # define custom login
    * def login = read('classpath:common-consortia/initData.feature@Login')

    * call login {tenant: '#(admin.tenant)', username: '#(admin.name)', password: '#(admin.password)'}

  Scenario:
#    * print 'SetUpAdmin (#(tenant))'
#    * def uuidStr = callonce uuid
#    * call read('classpath:common-consortia/initData.feature@Login') {tenant: '#(admin.tenant)', username: '#(admin.name)', password: '#(admin.password)'}
#    * call read("classpath:common-consortia/initData.feature@SetUpAdmin")  {tenant: 'consortium', token: '#(token)', username: 'consortium_admin_test', uuid: '#(uuidStr)'}



    * call read('classpath:common/module.feature') {modules: '#(requiredModulesForConsortia)'}