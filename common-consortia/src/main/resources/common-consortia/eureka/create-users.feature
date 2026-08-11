Feature: Create users

  @CreateUsers
  Scenario: Create specified number of users for all tenants
    # generate specified number of users for all tenants
    * def generatedForCentral = []
    * def generatedForUniversity = []
    * def generatedForCollege = []
    * def createParameterArrays =
    """
    function() {
      for (let i = 3; i < 104; i++) {
        const userId1 = uuid();
        const username1 = 'central_user'+i;
        const password1 = generatePassword(username1);
        generatedForCentral.push({'id': userId1, 'username': username1, 'password': password1, 'tenant': centralTenant});
        const userId2 = uuid();
        const username2 = 'university_user'+i;
        const password2 = generatePassword(username2);
        generatedForUniversity.push({'id': userId2, 'username': username2, 'password': password2, 'tenant': universityTenant});
        const userId3 = uuid();
        const username3 = 'college_user'+i;
        const password3 = generatePassword(username3);
        generatedForCollege.push({'id': userId3, 'username': username3, 'password': password3, 'tenant': collegeTenant});
      }
    }
    """
    * eval createParameterArrays()

    # create generated users
    * call read('classpath:common-consortia/eureka/initData.feature@Login') {user: '#(consortiaAdmin)'}
    * def v = call read('classpath:common-consortia/initData.feature@PostUser') {tenant: '#(tenant)', user: '#(user)'}

    * call read('classpath:common-consortia/eureka/initData.feature@Login') {user: '#(consortiaAdmin)'}
    * def v = call read('classpath:common-consortia/initData.feature@PostUser') {tenant: '#(tenant)', user: '#(user)'}

    * call read('classpath:common-consortia/eureka/initData.feature@Login') {user: '#(consortiaAdmin)'}
    * def v = call read('classpath:common-consortia/initData.feature@PostUser') {tenant: '#(tenant)', user: '#(user)'}