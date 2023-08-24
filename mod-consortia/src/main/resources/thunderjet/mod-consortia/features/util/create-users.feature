Feature: Create users

  @CreateUsers
  Scenario: Create specified number of users for all tenants
    # generate specified number of users for all tenants
    * def generatedForCentral = []
    * def generatedForUniversity = []
    * def generatedForCollage = []
    * def createParameterArrays =
    """
    function() {
      for (let i = 3; i < 204; i++) {
        const userId1 = uuid();
        const username1 = 'central_user'+i;
        const password1 = username1 +'_password';
        generatedForCentral.push({'id': userId1, 'username': username1, 'password': password1, 'tenant': centralTenant});
        const userId2 = uuid();
        const username2 = 'university_user'+i;
        const password2 = username2 +'_password';
        generatedForUniversity.push({'id': userId2, 'username': username2, 'password': password2, 'tenant': universityTenant});
        const userId3 = uuid();
        const username3 = 'college_user'+i;
        const password3 = username3 +'_password';
        generatedForCollage.push({'id': userId3, 'username': username3, 'password': password3, 'tenant': collegeTenant});
      }
    }
    """
    * eval createParameterArrays()

    # create generated users
    * call read(login) consortiaAdmin
    * def v = call read('features/util/initData.feature@PostUser') generatedForCentral

    * call read(login) universityUser1
    * def v = call read('features/util/initData.feature@PostUser') generatedForUniversity

    * call read(login) collegeUser1
    * def v = call read('features/util/initData.feature@PostUser') generatedForCollage