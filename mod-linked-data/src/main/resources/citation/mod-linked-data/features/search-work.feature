Feature: Search work resources

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

    # Create Work
    * def workRequest = read('samples/work-request.json')
    * call postResource { resourceRequest: '#(workRequest)' }
    * call searchWork { query: 'title == "The main title"', validateInstance: false }

    # Create Instance
    * def instanceRequest = read('samples/instance-request.json')
    * call postResource { resourceRequest: '#(instanceRequest)' }

  Scenario Outline: Search work resources: <scenario>
    * def query = '<query>'
    * def searchCall = call searchWork { validateInstance: true }
    * match searchCall.response.totalRecords == 1

    * def work = searchCall.response.content[0]
    * match work contains { id: '782957442715541691' }
    * match work.titles[*] contains { value: 'The main title', type: 'Main' }
    * match work.languages[*] contains { value: 'English' }
    * match work.classifications[*] contains { number: 'Lib-Congress-number', source: 'lc' }
    * match work.classifications[*] contains { number: 'Dewey-number', source: 'ddc' }

    * def instance = work.instances[0]
    * match instance contains { id: '6243691715627694450' }
    * match instance.identifiers[*] contains { value: '2023-26', type: 'LCCN' }
    * match instance.identifiers[*] contains { value: '0987654321', type: 'ISBN' }
    * match instance.titles[*] contains { value: 'Instance Main title', type: 'Main' }
    * match instance.titles[*] contains { value: 'Instance Sub title', type: 'Sub' }
    * match instance.publications[*] contains { name: 'Publiser name' }
    * match instance.editionStatements[*] contains { value: 'Second edition' }

    Examples:
      | query                                    | scenario                               |
      | title all "main the title"               | Search by work title                   |
      | title == "the main title"                | Search by work title - Exact phrase    |
      | title all "Instance Main title"          | Search by instance title               |
      | title == "Variant title of the instance" | Search by instance variant title       |
      | title == "Parallel sub title"            | Search by instance parallel sub title  |
      | isbn all "0987654321"                    | Search by ISBN                         |
      | lccn all "2023000026"                    | Search by LCCN                         |