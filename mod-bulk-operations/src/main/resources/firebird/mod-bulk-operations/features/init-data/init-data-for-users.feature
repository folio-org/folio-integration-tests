Feature: post users

  Background:
    * url baseUrl
    * callonce login testAdmin

    Scenario: Create user
      * def groups = karate.read('classpath:samples/patron-groups.json')
      * def fun = function(i) { return { group: groups[i]}; }
      * def data = karate.repeat(2, fun)
      * call read('init-data/mod-users-util.feature@PostPatronGroup') data

      * def user = karate.read('classpath:samples/user.json')
      * call read('init-data/mod-users-util.feature@PostUser') user





