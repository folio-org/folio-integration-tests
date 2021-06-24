Feature: Configure SAML

  Background:
    * url baseUrl
    # Things like setting up IdP are handled by the test admin user.
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    # This is a data source for adding these after registering the module below. See below for its use.
    * table samlUserPermissions
      | name                                |
      | 'login-saml.configuration.put'      |
      | 'login-saml.regenerate'             |

  Scenario: Check endpoint returns active is false when IdP is not configured
    Given path 'saml/check'
    When method GET
    Then status 200
    And match response == { active: false }

  # Configure an identity provider by 1) adding login-saml permissions to the admin user, and 2)
  # posting to the saml/configuration endpoint.
  Scenario: Add login-saml permissions to admin user and configure an IdP
    # Get the current perms. The first one is the permissions record for the admin user.
    Given path 'perms/users'
    When method GET
    Then status 200
    # Get the permissions user id (needed for the PUT below).
    * def adminPermissionsUserId = response.permissionUsers[0].id
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = $samlUserPermissions[*].name
    # Combine the current permissions for the admin user (setup by setup-users.feature) with the new desired permissions
    # for login-saml.
    * def permissions = karate.append(currentPerms, newPerms)
    * def userId = response.permissionUsers[0].userId
    # Put the new permissions into the user who will be registering IdP. This should give the user the permissions needed.
    Given path 'perms/users/', adminPermissionsUserId
    And request
    """
    {
      "userId": #(userId),
      "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
    # Configure the IdP using the same credentials we've been using so far. This admin user should have the permissions
    # based on what we have done in previous steps.
    Given path 'saml/configuration'
    # Disable the mod-authtoken's cache. Without this we would need to sleep for > 60 seconds for mod-authtoken
    # to be aware of the new permissions.
    And header Authtoken-Refresh-Cache = "true"
    # Here we need the idpUrl to actually be reachable and return XML samltest.id/saml/idp does that for now.
    And request
    """
    {
      idpUrl: "https://samltest.id/saml/idp",
      samlBinding: "REDIRECT",
      samlAttribute: "UserID",
      userProperty: "externalSystemId",
      okapiUrl: "http://localhost:9130"
    }
    """
    When method PUT
    Then status 200
    And match response ==
    """
    {
      idpUrl: "https://samltest.id/saml/idp",
      samlBinding: "REDIRECT",
      samlAttribute: "UserID",
      userProperty: "externalSystemId",
      okapiUrl: "http://localhost:9130",
      metadataInvalidated: true
    }
    """

  Scenario: Check endpoint returns active is true when IdP is configured
    Given path 'saml/check'
    When method GET
    Then status 200
    And match response == { active: true }

  Scenario: Get the SAML IdP metadata for the tenant
    Given path 'saml/regenerate'
    When method GET
    Then status 200
    And match response == { fileContent: #string }
    * def decoded = base64Decode(response.fileContent)
    * print decoded
    # TODO This is returning base64 encoded xml saml metadata. We could pattern match on this.

