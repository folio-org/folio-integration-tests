Feature: LCCN validation for duplicates.

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create a new resource in Linked Data, enable LCCN deduplication and try to create a resource with same LCCN.
    # Step 1: Enable LCCN deduplication
    * def settingsResponse = call getSettings { query: '(scope==ui-quick-marc.lccn-duplicate-check.manage and key==lccn-duplicate-check)'}
    * def setting = postInstanceCall.response.items[0]
    * karate.log('##setting##', setting)
    * eval setting.value.duplicateLccnCheckingEnabled = true
    * call putSetting { id : '#(setting.id)', settingRequest : '#(setting)'}

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
    * eval workRequest.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] = ['new_title']
    * def newWorkResponse = call postResource { resourceRequest: '#(workRequest)' }
    * eval workId = newWorkResponse.response.resource['http://bibfra.me/vocab/lite/Work'].id
    * def newInstanceRequest = read('samples/instance-request.json')
    * eval newInstanceRequest.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] = ['new_title']
    * call validationErrorWithCodeOnResourceCreation { resource: '#(newInstanceRequest)', code: 'lccn_not_unique'}

    # Step 5: Disable LCCN deduplication setting
    * eval setting.value.duplicateLccnCheckingEnabled = false
    * call putSetting { id : '#(setting.id)', settingRequest : '#(setting)'}

    # Step 6: Create new instance with existing LCCN, verify success
    * call postResource { resourceRequest: '#(newInstanceRequest)' }