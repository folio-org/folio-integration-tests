Feature: Integration with mod-search: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario Outline: Should Index Work in mod-search. <scenario>
    * def query = '<query>'
    * def searchCall = call searchLinkedDataWork { validateInstance: true }
    * match searchCall.response.totalRecords == 1

    * def work = searchCall.response.content[0]
    * match work contains { id: '-8976587967946275310' }
    * match work.titles[*] contains { value: 'The main title', type: 'Main' }
    * match work.languages[*] contains { value: 'eng' }
    * match work.classifications[*] contains { number: 'Lib-Congress-number', source: 'lc' }
    * match work.classifications[*] contains { number: 'Dewey-number', source: 'ddc' }

    * def instance = work.instances[0]
    * match instance contains { id: '6243691715627694450' }
    * match instance.identifiers[*] contains { value: '2023-26', type: 'LCCN' }
    * match instance.identifiers[*] contains { value: '0987654321', type: 'ISBN' }
    * match instance.titles[*] contains { value: 'Instance Main title', type: 'Main' }
    * match instance.titles[*] contains { value: 'Instance Sub title', type: 'Sub' }
    * match instance.publications[*] contains { name: 'Publisher name' }
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