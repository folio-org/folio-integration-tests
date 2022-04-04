Feature: roll back users to the original state

  Background:
    * url baseUrl
#    * callonce login testAdmin
#    * def okapitokenAdmin = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

    @RollBackUsersData
    Scenario: roll-back users
      * def originalUsers = usersDataOriginal.normalUsers
      * def fun = function(i) {return { user: originalUsers[i], userId: originalUsers[i].id }; }
      * def usersData = karate.repeat(3, fun)
      * call read('classpath:global/util/mod-users-util.feature.feature@PutUser') usersData