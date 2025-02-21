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

  # creating user with creds and perms
#  * def central_client = karate.get('testCentralClient')
#  * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(central_client)'}
#  * def testTenant = {id: '20196e07-f641-4800-bd9c-ac0bcb7a7e3c', name: 'tenant_name_central1'}
#  * call read('classpath:common-consortia/eureka/initData.feature@SetUpAdmin') {user: '#(test_admin)', tenant: '#(testTenant)', token: '#(result.token)'}
#  * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)'}
#  * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)', capNames: ['orders.all']}
#  * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {user: '#(test_user)', tenant: '#(testTenant)', token: '#(result.token)', capNames: ['consortia.all', 'inventory.instances.item.get', 'data-export.all', 'inventory-storage.all']}

    # consortia feature
#    * def central_client = karate.get('testCentralClient')
#    * def master_client = karate.get('masterClient')
#    * def testTenant = {id: '7597a724-0ed1-4d59-af0c-f4a94e9439c8', name: 'central12345'}
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {client: '#(master_client)', tenant: '#(testTenant)'}
#    * central_client.secret = result.sidecarSecret
#    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(central_client)'}
#    * def confortium = {id: '5f58e6a1-12d5-4aaf-8bf0-924c86ef6734' }
#    * call read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia') {token: '#(result.token)', tenant: '#(testTenant)', confortium: '#(confortium)'}
#    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(testTenant)', isCentral: true, code: 'ABC', token: '#(result.token)', confortium: '#(confortium)' }

    # get new tenant token
#      * def master_client = karate.get('masterClient')
#      * def testTenant = {id: '20196e07-f641-4800-bd9c-ac0bcb7a7e3c', name: 'tenant_name_central1'}
#      * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {client: '#(master_client)', tenant: '#(testTenant)'}
#      * def central_client = karate.get('testCentralClient')
#      * central_client.secret = result.sidecarSecret
#      * print central_client.secret

  # create users
  *
