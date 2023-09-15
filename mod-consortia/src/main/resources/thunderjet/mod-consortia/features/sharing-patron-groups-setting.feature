Feature: Consortia Sharing Patron Groups settings api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * configure retry = { count: 10, interval: 1000 }
    * def settingId = '55eeb826-44bd-4615-8751-464cc38fbb4d'
    * def group = 'Staff'
    * def desc = 'Staff patron group'
    * def expirationOffsetInDays = 10
    * def sourceConsortium = 'consortium'
    * def updatedDesc = 'Staff patron group updated'
    * def updatedDays = 20

  @Positive
  Scenario: Attempt to POST a sharingSetting with invalid request body or non-existing path id
    # 1. Create sharing setting ( to be shared for all tenants)
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/groups',
      payload: {
        id: '#(settingId)',
        group: '#(group)',
        desc: '#(desc)',
        expirationOffsetInDays: '#(expirationOffsetInDays)'
      }
    }
    """
    When method POST
    Then status 201
    And match response.createSettingsPCId == '#uuid'

    * def createSettingsPCId = response.createSettingsPCId

    # 2. Check details from publication request by createSettingsPCId
    Given path 'consortia', consortiumId, 'publications', createSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == createSettingsPCId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).group == group
    And match JSON.parse(response.request).desc == desc
    And match JSON.parse(response.request).expirationOffsetInDays == expirationOffsetInDays

    # 3.1 Check from /groups endpoint that setting has been created in 'centralTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(desc)'
    And match response.expirationOffsetInDays == '#(expirationOffsetInDays)'

    # 3.2 Check from /groups endpoint that setting has been created in 'universityTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(desc)'
    And match response.expirationOffsetInDays == '#(expirationOffsetInDays)'

    # 3.3 Check from /groups endpoint that setting has been created in 'collegeTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(desc)'
    And match response.expirationOffsetInDays == '#(expirationOffsetInDays)'

  @Positive
  Scenario: POST request to UPDATE existing sharing setting and check request details
    # 1. Update sharing setting for all tenants
    Given path 'consortia', consortiumId, 'sharing/settings'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/groups',
      payload: {
        id: '#(settingId)',
        group: '#(group)',
        desc: '#(updatedDesc)',
        expirationOffsetInDays: '#(updatedDays)'
      }
    }
    """
    When method POST
    Then status 201
    And match response.updateSettingsPCId == '#uuid'

    * def updateSettingsPCId = response.updateSettingsPCId

    # 2. Check details from publication request by using response updateSettingsPCId
    Given path 'consortia', consortiumId, 'publications', updateSettingsPCId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == updateSettingsPCId
    And match response.dateTime == '#notnull'
    And match JSON.parse(response.request).id == settingId
    And match JSON.parse(response.request).group == group
    And match JSON.parse(response.request).desc == updatedDesc
    And match JSON.parse(response.request).expirationOffsetInDays == updatedDays

    # 3.1 Check from /groups endpoint that setting has been created in 'centralTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(updatedDesc)'
    And match response.expirationOffsetInDays == '#(updatedDays)'

    # 3.2 Check from /groups endpoint that setting has been created in 'universityTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(updatedDesc)'
    And match response.expirationOffsetInDays == '#(updatedDays)'

    # 3.3 Check from /groups endpoint that setting has been created in 'collegeTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == '#(settingId)'
    And match response.group == '#(group)'
    And match response.desc == '#(updatedDesc)'
    And match response.expirationOffsetInDays == '#(updatedDays)'

  @Positive
  Scenario: DELETE request to delete existing shared settings and check request details
    # 1. Delete sharing setting for all tenants
    Given path 'consortia', consortiumId, 'sharing/settings', settingId
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      settingId: '#(settingId)',
      url: '/groups',
    }
    """
    When method DELETE
    Then status 200
    And match response.pcId == '#uuid'

    * def pcId = response.pcId

    # 2. Check details from publication request by using response pcId ('IN_PROGRESS' status should be 'COMPLETE')
    Given path 'consortia', consortiumId, 'publications', pcId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200
    And match response.id == pcId
    And match response.dateTime == '#notnull'
    And match response.request == 'null'

    # 3.1 Check from /groups endpoint that setting has been deleted in 'centralTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 3.2 Check from /groups endpoint that setting has been deleted in 'universityTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 3.3 Check from /groups endpoint that setting has been deleted in 'collegeTenant'
    Given path 'groups', settingId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404