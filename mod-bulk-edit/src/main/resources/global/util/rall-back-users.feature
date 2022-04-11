Feature: roll back users to the original state

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenAdmin = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testUser.tenant)' }

    @RollBackUsersData
    Scenario: roll-back users
      * def originalUsers = usersDataOriginal.normalUsers
      * def fun = function(i) {return { user: originalUsers[i], userId: originalUsers[i].id }; }
      * def usersData = karate.repeat(3, fun)
      * call read('classpath:global/util/mod-users-util.feature@PutUser') usersData