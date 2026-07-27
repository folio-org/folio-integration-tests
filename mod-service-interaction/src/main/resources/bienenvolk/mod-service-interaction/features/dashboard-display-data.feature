Feature: Dashboard display data

  # The per-dashboard layout blob. Reading needs view access, writing needs
  # edit; the record is created empty alongside the dashboard.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Laid out board' }
    * def dashboardId = created.dashboardId
    * def viewer = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(viewer)', access: 'view' }

  Scenario: A dashboard is created with an empty display data record
    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.id == '#string'
    And match response.dashId == dashboardId
    And match response.layoutData == '##null'

  Scenario: An edit holder stores and re-reads the layout
    * def layout = '{"widgets":[{"id":"one","x":0,"y":0}]}'

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    And request { layoutData: '#(layout)' }
    When method PUT
    Then status 200
    And match response.layoutData == layout
    And match response.dashId == dashboardId

    # A viewer reads the stored layout.
    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers asUser(viewer)
    When method GET
    Then status 200
    And match response.layoutData == layout

  Scenario: A view-only user cannot write the layout
    * def layout = '{"widgets":[]}'

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    And request { layoutData: '#(layout)' }
    When method PUT
    Then status 200

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers asUser(viewer)
    And request { layoutData: '{"widgets":[{"id":"hacked"}]}' }
    When method PUT
    Then status 403

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.layoutData == layout

  Scenario: A body dashId matching the path is accepted
    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    And request { dashId: '#(dashboardId)', layoutData: '{"matched":true}' }
    When method PUT
    Then status 200
    And match response.dashId == dashboardId
    And match response.layoutData == '{"matched":true}'

  Scenario: A body dashId pointing at another dashboard is rejected
    # Registered deviation D-20 (review finding F-09). Legacy authorises on the
    # PATH id and then lets a non-null body dashId re-point the stored row at
    # another dashboard — the outcome there is state-dependent (it succeeds
    # where the target has no row and trips the unique index where it has one),
    # so the legacy side is deliberately NOT pinned. The port refuses the
    # mismatch outright, before any write.
    * if (impl != 'port') karate.abort()
    * def other = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Other board' }
    * def otherId = other.dashboardId

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    And request { dashId: '#(otherId)', layoutData: '{"moved":true}' }
    When method PUT
    Then status 422
    And match response.errors[0].code == 'dashboard.id.mismatch'

    # The other dashboard still answers with its own record.
    Given path 'servint', 'dashboard', otherId, 'displayData'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.dashId == otherId
