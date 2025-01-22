Feature: mod-lists integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |
      | 'mod-entities-links'                |
    # wait, where's lists? it's installed in the next scenario, keep reading...

    * table userPermissions
      | name                                                        |
      | 'addresstypes.collection.get'                               |
      | 'addresstypes.item.post'                                    |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation.loans.collection.get'                          |
      | 'departments.collection.get'                                |
      | 'fqm.query.all'                                             |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'perms.permissions.collection.get'                          |
      | 'perms.users.assign.immutable'                              |
      | 'perms.users.assign.mutable'                                |
      | 'perms.users.assign.okapi'                                  |
      | 'perms.users.get'                                           |
      | 'perms.users.item.id.delete'                                |
      | 'perms.users.item.post'                                     |
      | 'perms.users.item.put'                                      |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |

    * table listPermissions
      | name                                                        |
      | 'lists.collection.get'                                      |
      | 'lists.collection.post'                                     |
      | 'lists.configuration.get'                                   |
      | 'lists.item.contents.get'                                   |
      | 'lists.item.delete'                                         |
      | 'lists.item.export.cancel'                                  |
      | 'lists.item.export.download.get'                            |
      | 'lists.item.export.get'                                     |
      | 'lists.item.export.post'                                    |
      | 'lists.item.get'                                            |
      | 'lists.item.post'                                           |
      | 'lists.item.refresh.cancel'                                 |
      | 'lists.item.update'                                         |
      | 'lists.item.versions.collection.get'                        |
      | 'lists.item.versions.item.get'                              |

  Scenario: create tenant and users for testing; install module dependencies
    Given call read('classpath:common/setup-users.feature')

  # Whoa, what's going on here? Why don't we install this like the other modules?
  #
  # mod-lists creates **and uses** a system user at install time. To do this, it interacts with
  # mod-users, mod-permissions, mod-login, and critically mod-authtoken. However, in the normal
  # Karate tenant setup, mod-authtoken is specifically kept disabled until all setup tasks are
  # completed. This is necessary as creating the initial users/assigning initial permissions can't
  # happen if mod-authtoken is already enabled and enforcing token requirements.
  #
  # So, once all the normal stuff is done, we'll install mod-lists (common/setup-users above
  # already enables mod-authtoken at the end of its scenarios). Strangely, this requirement does
  # not show itself as we'd expect (mod-lists depending on mod-login would seemingly imply
  # mod-authtoken), however, mod-login does not actually require mod-authtoken (for reasons
  # unbeknownst to us), making this a very difficult problem to debug.
  #
  # We will also re-assign the permissions to both testAdmin/testUser, to ensure that they are able
  # to use mod-lists.
  Scenario: Install mod-lists, for real this time
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-lists'}], tenant: '#(testTenant)'}

  Scenario: Re-assign admin permissions
    # login as testUser, since we're interfering with testAdmin's permissions
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

    # testAdmin gets ALL permissions; this is the same logic from common/setup-users
    Given path '/perms/permissions'
    And header x-okapi-tenant = testTenant
    And param length = 1000
    And param query = 'childOf == []'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName

    # Deleting and re-adding permissions is a bit simpler than updating
    Given path 'perms/users/00000000-1111-5555-9999-999999999991'
    And param indexField = 'userId'
    When method DELETE
    Then status 204

    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999991",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  # rinse and repeat for regular user
  Scenario: Re-assign user permissions
    * callonce login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testAdminHeaders

    * def userPermissionsNames = $userPermissions[*].name
    * def listPermissionsNames = $listPermissions[*].name
    * def permissions = karate.append(userPermissionsNames, listPermissionsNames)

    Given path 'perms/users/00000000-1111-5555-9999-999999999992'
    And param indexField = 'userId'
    When method DELETE
    Then status 204

    # add permissions to admin user
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999992",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  # Caching can sometimes cause the permissions added above to not take effect for up to a minute
  # after assignment, so we will poke mod-lists till we get a non-403 response.
  Scenario: Wait for test user permissions to take effect
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

    Given path 'lists'
    And retry until responseStatus == 200
    When method GET
    Then status 200    

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-lists/features/util/add-list-data.feature')
