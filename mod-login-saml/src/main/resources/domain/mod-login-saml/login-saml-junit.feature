Feature: mod-login-saml integration tests

  Background:
    * callonce login admin
    * url baseUrl
    * table modules
      | name                                |
      | 'okapi'                             |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-login'                         |
      | 'mod-users'                         |
      # This can't be added here. See note above. The reason is that mod-login-saml has mod-authtoken as a dependency
      # and once mod-authtoken is enabled (which it will be after registering mod-login-saml) we can no longer create
      # users without a token. common/setup-users.feature uses the supertenant to create the test user accounts without
      # using an x-okapi-token.
      # | 'mod-login-saml'                    |

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |
      # This also fails with the same message as below for the non admin-user
      # | 'login-saml.all'                    |

    * table userPermissions
      | name                                |
      # saml/configuration and saml/regnerate require these permissions. But I can't add these to my test user here.
      # This may be because the module hasn't been registered yet (we have to wait to do it below). The message I get from mod-permissions:
      # attempting to add non-existent permissions <the permission> to permission user with id <a permissions user id>.
      # | 'login-saml.configuration.put'      |
      # | 'login-saml.regenerate'             |

    # This is a data source for adding these after registering the module below. See below for its use.
    * table samlUserPermissions
      | name                                |
      | 'login-saml.configuration.put'      |
      | 'login-saml.regenerate'             |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # This is where to register mod-login-saml. See the NOTE above for why this is the way to do it.
  Scenario: get and install configured modules
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-login-saml'}], tenant: '#(testTenant)'}

  # Attempt to configure an identity provider by 1) adding login-saml permissions to the admin user, and 2)
  # posting to
  Scenario: Add login-saml permissions to admin user and configure an IdP
    # Login the admin test user.
    * call login testAdmin
    # Get the current perms. The first one is the permissions record for the admin user.
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * print response.permissionUsers[0].id
    # Get the permissions user id (needed for the PUT below).
    * def adminPermissionsUserId = response.permissionUsers[0].id
    * print adminPermissionsUserId
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = $samlUserPermissions[*].name
    # Combine the current permissions for the admin user (setup by setup-users.feature) with the new desired permissions
    # for login-saml.
    * def permissions = karate.append(currentPerms, newPerms)
    * def userId = response.permissionUsers[0].userId
    # Put the new permissions into the user who will be registering IdP. This should give the user the permissions needed.
    Given path 'perms/users/', adminPermissionsUserId
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "userId": #(userId),
      "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
    # Take a look at the result to make sure the new permissions have been added (they have).
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    # Take a look at the user (the admin test user). It doesn't tell us much.
    Given path 'users'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    And param query = "id==" + userId
    When method GET
    Then status 200
    # Try to configure the IdP using the same credentials we've been using so far. This admin user should have the permissions
    # based on what we have done in previous steps.
    Given path 'saml/configuration'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    And request
    """
    {
      idpUrl: "https://someidp.com",
      samlBinding: "REDIRECT",
      samlAttribute: "UserID",
      userProperty: "externalSystemId",
      okapiUrl: "http://localhost:9130"
    }
    """
    When method PUT
    # This is currently 403 - Access requires permission login-saml.configuration.put, which should already be added.
    Then status 200

  # TODO Is an okapi token always available? Could it be passed into all requests? If so we might get around this overall problem.
  # The token is available but for unknown reasons, when it is added to setup-users we get 'requires permission: users.item.post' when creating the users.
