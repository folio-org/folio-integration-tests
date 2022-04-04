Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * configure retry = { interval: 3000, count: 10 }
    * def prepareUser = function(userTemplate, userData) {

  Scenario: setup address types
    * def addressTypes = karate.read('classpath:samples/user/addressTypes.json')
    * def fun = function(i) { return { addressType: addressTypes[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature.feature@PostAddressType') data

  Scenario: setup departments
    * def departments = karate.read('classpath:samples/user/departments.json')
    * def fun = function(i) { return { department: departments[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature.feature@PostDepartment') data

  Scenario: setup patron groups
    * def groups = karate.read('classpath:samples/user/patronGroups.json')
    * def fun = function(i) { return { group: groups[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-users-util.feature.feature@PostPatronGroup') data

  Scenario: setup proxies for
    * def proxiesForJson = karate.read('classpath:samples/user/proxiesFor.json')
    * def proxiesFor = karate.append(proxiesForJson.original, proxiesForJson.changed)
    * def fun = function(i) { return { proxyFor: proxiesFor[i]}; }
    * def data = karate.repeat(6, fun)
    * call read('classpath:global/util/mod-users-util.feature.feature@PostProxiesFor') data

  Scenario: setup test users
    * def users = karate.append(usersDataOriginal.normalUsers, usersDataOriginal.proxyUsers)
    * def fun = function(i) { return { user: users[i]}; }
    * def data = karate.repeat(5, fun)
    * call read('classpath:global/util/mod-users-util.feature.feature@PostUser') data




