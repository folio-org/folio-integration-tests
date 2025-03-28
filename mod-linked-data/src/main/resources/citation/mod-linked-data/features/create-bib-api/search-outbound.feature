Feature: Integration with mod-search for new Work and Instance: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario Outline: Should Index Work in mod-search. <scenario>
    * def query = '<query>'
    * def searchCall = call searchLinkedDataWork
    * match searchCall.response.totalRecords == 1

    * def work = searchCall.response.content[0]
    * match work contains { id: '#(workId)' }
    * match work.titles[*] contains { value: 'The main title', type: 'Main' }
    * match work.languages[*] contains [ 'eng' ]
    * match work.classifications[*] contains { type: 'lc', number: 'Lib-Congress-number', additionalNumber: 'Lib-Congress-number-item'}
    * match work.classifications[*] contains { type: 'ddc', number: 'Dewey-number', additionalNumber: 'Dewey-number-item' }

    * def instance = work.instances[0]
    * match instance contains { id: '#(instanceId)' }
    * match instance.identifiers[*] contains { value: '  1234567890', type: 'LCCN' }
    * match instance.identifiers[*] contains { value: '0987654321', type: 'ISBN' }
    * match instance.titles[*] contains { value: 'create-bib-title', type: 'Main' }
    * match instance.titles[*] contains { value: 'Instance Sub title', type: 'Sub' }
    * match instance.publications[*] contains { name: 'Publisher name' }
    * match instance.editionStatements[*] contains [ 'Second edition' ]

    Examples:
      | query                                                           | scenario                                      |
      | title all "main the title"                                      | Search by work title                          |
      | title == "the main title"                                       | Search by work title - Exact phrase           |
      | title all "create-bib-title"                                    | Search by instance title                      |
      | title == "Variant title of the instance"                        | Search by instance variant title              |
      | title == "Parallel sub title"                                   | Search by instance parallel sub title         |
      | isbn all "0987654321"                                           | Search by ISBN                                |
      | lccn all "1234567890"                                           | Search by LCCN                                |
      | classificationType == "lc"                                      | Search by classification type                 |
      | classificationNumber == "Dewey-number"                          | Search by classification number               |
      | classificationAdditionalNumber == "Lib-Congress-number-item"    | Search by classification additional number    |