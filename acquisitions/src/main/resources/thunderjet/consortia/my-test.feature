Feature:

  Background:
    * def requiredModules = ['mod-permissions', 'mod-configuration', 'mod-login-keycloak', 'mod-users', 'mod-pubsub', 'mod-audit', 'mod-orders-storage', 'mod-orders', 'mod-invoice-storage', 'mod-invoice', 'mod-finance-storage', 'mod-finance', 'mod-organizations-storage', 'mod-organizations', 'mod-inventory-storage', 'mod-inventory', 'mod-circulation-storage', 'mod-circulation', 'mod-feesfines']
    * def requiredModulesForConsortia = ['mod-tags', 'mod-users-bl', 'mod-password-validator', 'folio_users']
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}
    * def admin = karate.get('admin')
    * def test_admin = karate.get('test_admin')
    * def test_user = karate.get('test_user')
    # define custom login
    * configure readTimeout = 600000

#    * call login {tenant: '#(admin.tenant)', username: '#(admin.name)', password: '#(admin.password)'}

  Scenario:
#    * print 'SetUpAdmin (#(tenant))'
#    * def uuidStr = callonce uuid
#    * call read('classpath:common-consortia/initData.feature@Login') {tenant: '#(admin.tenant)', username: '#(admin.name)', password: '#(admin.password)'}
#    * call read("classpath:common-consortia/initData.feature@SetUpAdmin")  {tenant: 'consortium', token: '#(token)', username: 'consortium_admin_test', uuid: '#(uuidStr)'}



#    * call read('classpath:common/module.feature') {modules: '#(requiredModulesForConsortia)'}
#  * call read('classpath:common-consortia/initData.feature@PostTenant') { id: '#(uuid())', name: 'tenant_name_central', description: '#(description)'}
#  * call read('classpath:common-consortia/initData.feature@PostUser') {user: '#(test_user)', tenantName: 'tenant_name_central', okapitoken: '#(okapiToken)'}
#  * def testUser = {userId: '6a827c8e-8457-4317-9b09-4ec6689084d9', username: 'qwerty'}
#  * call read('classpath:common-consortia/initData.feature@PutRoles') {user: '#(testUser)', tenantName: 'consortium', okapitoken: '#(okapitoken)', desiredCapabilities: ['consortia.all']}

#    * def master_client = karate.get('masterClient')
#    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(master_client)'}
#    * def tenant = {id: '49858ace-a68e-4325-ae59-0816637ee50c', name: 'tenant_name_central'}
#    * call read('classpath:common-consortia/consortium.feature@SetupConsortia') {token: '#(result.token)', tenant: '#(tenant)', confortium: '#(confortium)'}

  # creating user with creds and perms
#  * def central_client = karate.get('testCentralClient')
#  * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(central_client)'}
#  * def testTenant = {id: '20196e07-f641-4800-bd9c-ac0bcb7a7e3c', name: 'tenant_name_central1'}
##  * call read('classpath:common-consortia/initData.feature@SetUpAdmin') {user: '#(test_admin)', tenant: '#(testTenant)', token: '#(result.token)'}
#  * call read('classpath:common-consortia/initData.feature@PostUser') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)'}
#  * call read('classpath:common-consortia/initData.feature@PutCaps') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)', capNames: ['orders.all']}
#  * call read('classpath:common-consortia/initData.feature@PutCaps') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)', capNames: ['consortia.all', 'inventory.instances.item.get', 'data-export.all', 'inventory-storage.all']}

    # consortia feature
    * def central_client = karate.get('testCentralClient')
    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(central_client)'}
    * def testTenant = {id: '20196e07-f641-4800-bd9c-ac0bcb7a7e3c', name: 'tenant_name_central1'}
    * def confortium = {id: '5f58e6a1-12d5-4aaf-8bf0-924c86ef6734' }
#    * call read('classpath:common-consortia/consortium.feature@SetupConsortia') {token: '#(result.token)', tenant: '#(testTenant)', confortium: '#(confortium)'}
    * call read('classpath:common-consortia/consortium.feature@SetupTenantForConsortia') { tenant: '#(testTenant)', isCentral: true, code: 'ABC', token: '#(result.token)', confortium: '#(confortium)' }