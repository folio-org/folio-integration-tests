Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: setup test data
    #setup address types
    * def addressTypes = karate.read('classpath:samples/user/addressTypes.json')
    * def fun = function(i) { return { addressType: addressTypes[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature@PostAddressType') data

    #setup departments
    * def departments = karate.read('classpath:samples/user/departments.json')
    * def fun = function(i) { return { department: departments[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature@PostDepartment') data

    #setup patron groups
    * def groups = karate.read('classpath:samples/user/patronGroups.json')
    * def fun = function(i) { return { group: groups[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature@PostPatronGroup') data

    #setup proxies for
    * def proxiesForJson = karate.read('classpath:samples/user/proxiesFor.json')
    * print 'proxies for after read'
    * print proxiesForJson
    * def proxiesFor = karate.append(proxiesForJson.original, proxiesForJson.changed)
    * print 'proxies for after append'
    * print proxiesFor
    * def fun = function(i) { return { proxyFor: proxiesFor[i]}; }
    * def data = karate.repeat(6, fun)
    * call read('classpath:global/util/mod-users-util.feature@PostProxiesFor') data

    #setup test users
    * def users = karate.append(usersDataOriginal.normalUsers, usersDataOriginal.proxyUsers)
    * print 'appeneded users kek'
    * print users
    * def fun = function(i) { return { user: users[i]}; }
    * def data = karate.repeat(5, fun)
    * call read('classpath:global/util/mod-users-util.feature@PostUser') data