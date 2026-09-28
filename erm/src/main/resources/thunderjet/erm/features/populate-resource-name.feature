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

    # Returns The Newest Ended Sync Job Whose Id Differs From The Previously Consumed One, Else Null
    * def latestEndedSyncJob =
      """
      function(resp, prevId) {
        var matches = karate.jsonPath(resp, "$[?(@.name =~ /.*entitlementeholdings.*/i)]");
        if (!matches || matches.length == 0) return null;
        // pick the newest job by dateCreated ourselves, without relying on server-side sort
        var latest = matches[0];
        for (var i = 1; i < matches.length; i++) {
          if (('' + matches[i].dateCreated) > ('' + latest.dateCreated)) {
            latest = matches[i];
          }
        }
        if (latest.status && latest.status.label == 'Ended' && ('' + latest.id) != ('' + prevId)) {
          return latest;
        }
        return null;
      }
      """

  @C1348606
  @Positive
  Scenario: Manual Sync Job Populates ResourceName And Reports Partial And Clean Success

    # 1. Create Kept EKB Package (Agreement Line #1)
    * configure headers = vndHeaders
    * def keptPackageName = 'Karate Kept Package ' + random_string()
    Given path '/eholdings/packages'
    And def packageName = keptPackageName
    And request read(setupSamples + 'package.json')
    When method POST
    Then status 200
    * def keptPackageId = response.data.id
    * setSystemProperty('keptPackageId', keptPackageId)

    # 2. Create Title And Resource In The Kept Package (Agreement Line #2)
    Given path '/eholdings/titles'
    And def titleName = 'Karate Title ' + random_string()
    And def packageId = keptPackageId
    And request read(setupSamples + 'title.json')
    When method POST
    Then status 200
    * def titleId = response.data.id
    * def resourceId = keptPackageId + '-' + titleId

    # 3. Create EKB Package To Be Deleted (Agreement Line #3)
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

    # 8. Verify Info Log Lists The Three Updated Entitlements
    Given path 'erm/jobs', jobId1, 'infoLog'
    When method GET
    Then status 200
    And match $ == '#[3]'
    And match each $[*].message == '#regex .*ResourceName for.*updated to.*'

    # 9. Verify Error Log Reports The One Failed Line
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

    # 11. Delete Line #3 And Re-Trigger - No Updates Are Performed
    # NOTE (env-confirm): asserts a job IS created and ends with Success / empty info log.
    # If the deployed build records NO job when there is nothing to do, relax this block.
    Given path 'erm/entitlements', line3Id
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 200

    * def run2 = call read('populate-resource-name.feature@TriggerAndWait') { previousJobId: '#(jobId1)' }
    * def jobId2 = run2.job.id
    * match run2.job.result.label == 'Success'

    Given path 'erm/jobs', jobId2, 'infoLog'
    When method GET
    Then status 200
    And match $ == '#[0]'

    # 12. Reset ResourceName To Null On Lines #1-2
    * call read('populate-resource-name.feature@SetResourceNameNull') { entitlementId: '#(line1Id)' }
    * call read('populate-resource-name.feature@SetResourceNameNull') { entitlementId: '#(line2Id)' }

    # 13. Trigger Again And Verify A Clean Success With Two Updates And No Errors
    * def run3 = call read('populate-resource-name.feature@TriggerAndWait') { previousJobId: '#(jobId2)' }
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
