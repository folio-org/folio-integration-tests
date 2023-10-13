Feature: initialize user permissions and data
  Background:
    * url baseUrl
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * table diPermissions
      | name                                               |
      | 'data-import.assembleStorageFile.post'             |
      | 'data-import.splitconfig.get'                      |
      | 'data-import.uploaddefinitions.post'               |
      | 'data-import.uploaddefinitions.get'                |
      | 'data-import.uploaddefinitions.put'                |
      | 'data-import.uploaddefinitions.delete'             |
      | 'data-import.upload.file.post'                     |
      | 'data-import.uploaddefinitions.files.delete'       |
      | 'data-import.uploaddefinitions.files.post'         |
      | 'data-import.fileExtensions.get'                   |
      | 'data-import.fileExtensions.post'                  |
      | 'data-import.fileExtensions.put'                   |
      | 'data-import.fileExtensions.delete'                |
      | 'data-import.fileExtensions.default'               |
      | 'data-import.datatypes.get'                        |
      | 'data-import.uploadUrl.get'                        |
      | 'data-import.downloadUrl.get'                      |
      | 'data-import.jobexecution.cancel'                  |
      | 'data-import.upload.all'                           |
      | 'configuration.all'                                |
      | 'inventory-storage.all'                            |
      | 'source-storage.all'                               |
      | 'converter-storage.jobprofile.get'                 |
      | 'converter-storage.jobprofile.post'                |
      | 'converter-storage.jobprofile.delete'              |
      | 'converter-storage.actionprofile.post'             |
      | 'converter-storage.actionprofile.delete'           |
      | 'converter-storage.mappingprofile.post'            |
      | 'converter-storage.mappingprofile.delete'          |
      | 'change-manager.jobexecutions.get'                 |
      | 'change-manager.jobexecutions.delete'              |
      | 'inventory.all'                                    |
      | 'metadata-provider.logs.get'                       |
      | 'converter-storage.matchprofile.post'              |
      | 'data-export.all'                                  |
      | 'invoice.all'                                      |
      | 'mapping-rules.get'                                |
      | 'mapping-rules.update'                             |
      | 'invoice-storage.invoice-lines.collection.get'     |
      | 'invoice-storage.invoice-lines.item.get'           |
      | 'invoice-storage.invoices.item.get'                |
      | 'organizations-storage.organizations.all'          |
      | 'orders.all'                                       |
      | 'acquisitions-units-storage.memberships.item.post' |
      | 'acquisitions-units-storage.units.item.post'       |
      | 'copycat.profiles.collection.get'                  |
      | 'copycat.imports.post'                             |
      | 'copycat.profiles.item.put'                        |
      | 'metadata-provider.jobexecutions.get'              |
      | 'organizations.organizations.collection.get'       |

      * def permissions = $diPermissions[*].name

  Scenario: grant mod-data-import permissions to test admin
    # Get the current perms for the test admin
    Given path 'perms/users'
    And param query = 'userId=="00000000-1111-5555-9999-999999999991"'
    When method GET
    Then status 200
    # Get the permissions user id.
    * def adminPermissionsAdminId = response.permissionUsers[0].id
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = $diPermissions[*].name
    # Combine the current permissions for the test admin (setup by setup-users.feature) with the new desired permissions for mod-DI
    * def permissions = karate.append(currentPerms, newPerms)

    Given path 'perms/users/', adminPermissionsAdminId
    And request
    """
    {
      "userId": "00000000-1111-5555-9999-999999999991",
      "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
    And match response.permissions contains $diPermissions[*].name

  Scenario: grant mod-data-import permissions to regular user
    # Get the current perms for the test user
    Given path 'perms/users'
    And param query = 'userId=="00000000-1111-5555-9999-999999999992"'
    When method GET
    Then status 200
    # Get the permissions user id.
    * def permissionsUserId = response.permissionUsers[0].id
    * def newPerms = $diPermissions[*].name

    Given path 'perms/users/', permissionsUserId
    And request
    """
    {
      "userId": "00000000-1111-5555-9999-999999999992",
      "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
    And match response.permissions contains $diPermissions[*].name

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:folijet/data-import/global/mod_inventory_init_data.feature')
    * callonce read('classpath:folijet/data-import/global/init-acquisition-data.feature')
