Feature: Populate ResourceName For External eHoldings Agreement Lines

  # For FAT-28851, https://foliotest.testrail.io/index.php?/cases/view/1348606

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * def jsonHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = jsonHeaders
    * configure retry = { count: 15, interval: 500 }
    * def samples = 'classpath:thunderjet/erm/features/samples/'
    * def setupSamples = 'classpath:thunderjet/erm/features/setup/samples/'

    # Returns The Newest Ended EHoldingsEntitlementSyncJob Whose Id Differs From The Previously Consumed One, Else Null
    * def latestEndedSyncJob =
      """
      function(resp, prevId) {
        if (!resp) return null;
        // the sync job is org.olf.general.jobs.EHoldingsEntitlementSyncJob (match on class or name)
        var latest = null;
        for (var i = 0; i < resp.length; i++) {
          var j = resp[i];
          var cls = '' + (j['class'] || '');
          var nm = '' + (j.name || '');
          if (cls.indexOf('EHoldingsEntitlementSyncJob') < 0 && nm.indexOf('EHoldingsEntitlementSyncJob') < 0) continue;
          if (latest == null || j.dateCreated > latest.dateCreated) latest = j;
        }
        if (latest && latest.status && latest.status.label == 'Ended' && ('' + latest.id) != ('' + prevId)) {
          return latest;
        }
        return null;
      }
      """

  @C1348606
  @Positive
  Scenario: Manual Sync Job Populates ResourceName And Reports Partial And Clean Success

    # 1. Find A Managed EKB Package (Agreement Line #1) - Managed Resources Resolve Via Bulk Fetch
    * configure headers = vndHeaders

    # (diagnostic) Single-credentials fallback needs exactly 1 credentials and 0 assigned users - dump the tenant state
    Given path '/eholdings/kb-credentials'
    When method GET
    Then status 200
    * print 'kb-credentials total:', response.meta.totalResults, karate.jsonPath(response, '$.data[*].id')

    * def credentialId = java.lang.System.getProperty('credentialId')
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    When method GET
    Then status 200
    * print 'assigned users:', response.meta.totalResults, karate.jsonPath(response, '$.data[*].id')

    Given path '/eholdings/user-kb-credential'
    When method GET
    * print 'user-kb-credential status:', responseStatus

    # Freshly created KB credentials may not be visible to mod-kb-ebsco reads right away, so retry until they are
    * configure retry = { count: 30, interval: 2000 }
    Given path '/eholdings/packages'
    And params { q: 'a', 'filter[type]': 'all', count: 25, page: 1 }
    And retry until responseStatus == 200
    When method GET
    Then status 200
    * def managedPackages = karate.jsonPath(response, "$.data[?(@.attributes.isCustom == false)]")
    * assert managedPackages.length > 0
    * def keptPackageId = managedPackages[0].id

    # 2. Take A Managed Resource (Title) From That Package (Agreement Line #2)
    Given path '/eholdings/packages', keptPackageId, 'resources'
    And param page = 1
    And param count = 25
    When method GET
    Then status 200
    * assert response.data.length > 0
    * def resourceId = response.data[0].id

    # (diagnostic) Check eHoldings Bulk Fetch Works In This Tenant For The Test User
    Given path '/eholdings/packages/bulk/fetch'
    And request { packages: ['#(keptPackageId)'] }
    When method POST
    Then status 200

    Given path '/eholdings/resources/bulk/fetch'
    And request { resources: ['#(resourceId)'] }
    When method POST
    Then status 200

    # 3. Create Custom EKB Package To Be Deleted (Agreement Line #3)
    * def deletedPackageName = 'Karate Deleted Package ' + random_string()
    Given path '/eholdings/packages'
    And def packageName = deletedPackageName
    And request read(setupSamples + 'package.json')
    When method POST
    Then status 200
    * def deletedPackageId = response.data.id

    * eval sleep(15000)

    # 4. Create Agreement With Three External Lines Having Null ResourceName
    * configure headers = jsonHeaders
    * def agreementName = 'Karate ResourceName Agreement ' + now()
    Given path 'erm/sas'
    And param fetchExternalResources = false
    And request read(samples + 'agreement-external-lines.json')
    When method POST
    Then status 201
    * def agreementId = response.id
    * setSystemProperty('agreementId', agreementId)

    # 5. Resolve The Three Agreement Line Ids By Their eHoldings Reference
    Given path 'erm/entitlements'
    And param query = 'owner==' + agreementId
    When method GET
    Then status 200
    And match $ == '#[3]'
    And match each $[*].resourceName == null
    * def line1Id = karate.jsonPath(response, "$[?(@.reference=='" + keptPackageId + "')].id")[0]
    * def line2Id = karate.jsonPath(response, "$[?(@.reference=='" + resourceId + "')].id")[0]
    * def line3Id = karate.jsonPath(response, "$[?(@.reference=='" + deletedPackageId + "')].id")[0]

    # 6. Delete The eHoldings Package Behind Line #3 So Its Lookup Fails During The Sync
    * configure headers = vndHeaders
    Given path '/eholdings/packages', deletedPackageId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 200
    * configure headers = jsonHeaders
    * eval sleep(10000)

    # 7. Trigger The Sync Job And Wait For Partial Success
    * def run1 = call read('populate-resource-name.feature@TriggerAndWait') { previousJobId: 'none' }
    * def jobId1 = run1.job.id
    * match run1.job.result.label == 'Partial success'

    # (diagnostic) Dump error log so its messages are captured before strict assertions
    Given path 'erm/jobs', jobId1, 'errorLog'
    When method GET
    Then status 200

    # 8. Verify Info Log Lists The Two Updated (Managed) Entitlements
    Given path 'erm/jobs', jobId1, 'infoLog'
    When method GET
    Then status 200
    And match $ == '#[2]'
    And match each $[*].message == '#regex .*ResourceName for.*updated to.*'

    # 9. Verify Error Log Reports The One Failed (Deleted) Line
    Given path 'erm/jobs', jobId1, 'errorLog'
    When method GET
    Then status 200
    And match $ == '#[1]'
    And match $[0].message contains 'Update failed'

    # 10. Verify ResourceName Is Populated For Lines #1-2 And Still Null For Line #3
    Given path 'erm/entitlements', line1Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

    Given path 'erm/entitlements', line2Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

    Given path 'erm/entitlements', line3Id
    When method GET
    Then status 200
    And match $.resourceName == null

    # 11. Delete Line #3, Then Re-Trigger - No Null Lines Remain, So The Job Performs No Actions
    # Per the case: with no external line having a null resourceName, no log/actions are produced,
    # so we do NOT wait for a new job here - only assert the trigger is accepted and #1-2 are unchanged.
    Given path 'erm/entitlements', line3Id
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 200

    Given path 'erm/admin/triggerEntitlementEholdings'
    And param force = true
    When method GET
    Then status 200
    And match $.status == 'OK'

    Given path 'erm/entitlements', line1Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

    Given path 'erm/entitlements', line2Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

    # 12. Reset ResourceName To Null On Lines #1-2
    * call read('populate-resource-name.feature@SetResourceNameNull') { entitlementId: '#(line1Id)' }
    * call read('populate-resource-name.feature@SetResourceNameNull') { entitlementId: '#(line2Id)' }

    # 13. Trigger Again And Verify A Clean Success With Two Updates And No Errors
    # Capture the current latest sync job id first, so TriggerAndWait waits for a strictly newer one
    Given path 'erm/jobs'
    And param sort = 'dateCreated;desc'
    And param perPage = 100
    When method GET
    Then status 200
    * def prevSync = latestEndedSyncJob(response, 'none')
    * def prevJobId3 = prevSync == null ? 'none' : prevSync.id
    * def run3 = call read('populate-resource-name.feature@TriggerAndWait') { previousJobId: '#(prevJobId3)' }
    * def jobId3 = run3.job.id
    * match run3.job.result.label == 'Success'

    Given path 'erm/jobs', jobId3, 'errorLog'
    When method GET
    Then status 200
    And match $ == '#[0]'

    Given path 'erm/jobs', jobId3, 'infoLog'
    When method GET
    Then status 200
    And match $ == '#[2]'
    And match each $[*].message == '#regex .*ResourceName for.*updated to.*'

    Given path 'erm/entitlements', line1Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

    Given path 'erm/entitlements', line2Id
    When method GET
    Then status 200
    And match $.resourceName == '#string'

  @Ignore
  @TriggerAndWait
  Scenario: Trigger The Sync Job And Wait For A New Ended Sync Job
    # Input: previousJobId ; Returns: job (The Ended Sync Job)
    Given path 'erm/admin/triggerEntitlementEholdings'
    And param force = true
    When method GET
    Then status 200
    And match $.status == 'OK'

    * configure retry = { count: 30, interval: 10000 }
    Given path 'erm/jobs'
    And param sort = 'dateCreated;desc'
    And param perPage = 100
    And retry until latestEndedSyncJob(response, previousJobId) != null
    When method GET
    Then status 200
    * def job = latestEndedSyncJob(response, previousJobId)

  @Ignore
  @SetResourceNameNull
  Scenario: Set ResourceName To Null On An Entitlement
    # Input: entitlementId
    Given path 'erm/entitlements', entitlementId
    When method GET
    Then status 200
    * def body = response
    * set body.resourceName = null

    Given path 'erm/entitlements', entitlementId
    And request body
    When method PUT
    Then status 200
