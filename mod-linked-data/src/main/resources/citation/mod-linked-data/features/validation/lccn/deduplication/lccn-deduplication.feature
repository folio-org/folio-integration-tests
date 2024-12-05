Feature: LCCN validation for duplicates.

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create a new resource in Linked Data, enable LCCN deduplication and try to create a resource with same LCCN.
    # Step 1: Enable LCCN deduplication
    * def settingRequest = read('samples/setting-request.json')
    * def settingsResponse = call postSetting
    * def setting = call getSetting { id: '#(settingRequest.id)'}
    * karate.log('##setting##', setting)
    * def settingsResponse = call getSettings { query: '(scope==ui-quick-marc.lccn-duplicate-check.manage and key==lccn-duplicate-check)'}
    * karate.log('##settings##', settingsResponse)

    # Step 2: Create work and instance
    * def workRequest = read('samples/work-request.json')
    * def workResponse = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = workResponse.response.resource['http://bibfra.me/vocab/lite/Work'].id

    * def instanceRequest = read('samples/instance-request.json')
    * def instanceResponse = call postResource { resourceRequest: '#(instanceRequest)' }

    # Step 3: Update the instance with same LCCN (here we check linked-data -> mod-search interaction and id exclusion)
    * def instanceId = instanceResponse.response.resource['http://bibfra.me/vocab/lite/Instance'].id
    * call putResource { id: '#(instanceId)' , resourceRequest: '#(instanceRequest)' }

    # Step 4: Create new instance with existing LCCN, verify bad request
    * def invalidInstanceRequest = read('samples/invalid-instance-request.json')
    * call validationErrorWithCodeOnResourceCreation { resource: '#(invalidInstanceRequest)', code: 'lccn_not_unique'}

    # Step 5: Disable LCCN deduplication setting
    * eval settingRequest.value.duplicateLccnCheckingEnabled = false
    * call putSetting { id : '#(settingRequest.id)', settingRequest : '#(settingRequest)'}

    # Step 6: Create new instance with existing LCCN, verify success
    * call postResource { resourceRequest: '#(invalidInstanceRequest)' }