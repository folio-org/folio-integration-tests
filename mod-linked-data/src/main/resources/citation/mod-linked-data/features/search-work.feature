Feature: Search work resources

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    # Create Work
    * def workRequest = read('samples/work-request.json')
    * call postResource { resourceRequest: '#(workRequest)' }
    * call pause 10000
    # Create Instance
    * def instanceRequest = read('samples/instance-request.json')
    * call postResource { resourceRequest: '#(instanceRequest)' }
    * def expectedInstanceId = '6243691715627694450'
    * def expectedWorkId = '782957442715541691'

  Scenario: Search using work title - Search tearm in different order
    * def query = 'title all "main the title"'
    * def searchCall = call searchWorkAndValidate
    * def response = searchCall.response

    Then match response.content[0].titles[*] contains { value: 'The main title', type: 'Main' }
    Then match response.content[0].classifications[*] contains { number: 'Lib-Congress-number', source: 'lc' }
    Then match response.content[0].classifications[*] contains { number: 'Dewey-number', source: 'ddc' }
    Then match response.content[0].languages[*] contains { value: 'English' }

  Scenario: Search using work title - Exact phrase
    * def query = 'title == "the main title"'
    * call searchWorkAndValidate

  Scenario: Search using instance title
    * def query = 'title all "Instance Main title"'
    * call searchWorkAndValidate

  Scenario: Search using instance variant title - Exact phrase
    * def query = 'title == "Variant title of the instance"'
    * call searchWorkAndValidate

  Scenario: Search using instance parallel sub title - Exact phrase
    * def query = 'title == "Parallel sub title"'
    * call searchWorkAndValidate

  Scenario: Search using ISBN
    * def query = 'isbn all "0987654321"'
    * call searchWorkAndValidate

  Scenario: Search using LCCN
    * def query = 'lccn all "2023000026"'
    * call searchWorkAndValidate