Feature: post users

  Background:
    * url baseUrl
    * call variables
    * call login testAdmin

  Scenario: Create user
    * def groups = karate.read('classpath:samples/users/patron-groups.json')
    * def fun = function(i) { return { group: groups[i]}; }
    * def data = karate.repeat(2, fun)
    * call read('mod-users-util.feature@PostPatronGroup') data

    * def user = karate.read('classpath:samples/users/user.json')
    * call read('mod-users-util.feature@PostUser') user