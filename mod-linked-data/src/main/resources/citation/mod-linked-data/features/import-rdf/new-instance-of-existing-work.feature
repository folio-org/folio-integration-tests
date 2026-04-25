Feature: Create new instance under existing work using RDF import
  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Create new instance under existing work using RDF import
    * configure headers = testUserHeaders
    * def workTitle = 'existing-bib-title'

    # Step 1 - create a new work using API
    * def workRequest =
      """
      {
        "resource":{
          "http://bibfra.me/vocab/lite/Work":{
            "http://bibfra.me/vocab/library/title":[
              {
                "http://bibfra.me/vocab/library/Title":{
                  "http://bibfra.me/vocab/library/mainTitle":[ "#(workTitle)" ]
                }
              }
            ],
            "profileId":"2"
          }
        }
      }
      """

    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workResourceId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id

    # Step 2 -Import an instance by importing an RDf file. This new instance should get connected to the existig work
    * def fileName = 'new-instance-of-existing-work-rdf.json'
    * def rdfTemplate = karate.readAsString('classpath:citation/mod-linked-data/features/import-rdf/samples/new-instance-of-existing-work-rdf.json')
    * def renderedRdf = rdfTemplate.replace('#(workTitle)', workTitle)
    * def renderedRdfFilePath = karate.write(renderedRdf, fileName)
    * def uploadRdfPath = 'file:' + renderedRdfFilePath
    * configure headers = { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path '/linked-data/import/file'
    And multipart file fileName = { read: '#(uploadRdfPath)', filename: '#(fileName)', contentType: 'application/ld+json'  }
    And param filterType = 'http://bibfra.me/vocab/lite/Instance'
    When method POST
    Then status 200
    * def insanceResourceId = response.resources[0]

    # Step 3 - Search for the work in linked-data graph. Assert that the newly created instance is connected to the existing work.
    * configure headers = testUserHeaders
    * def query = 'title all "' + workTitle + '"'
    * def searchCall = call searchLinkedDataWork
    * def instances = searchCall.response.content[0].instances
    * match instances[*].id contains insanceResourceId

    # Step 4 - Fetch existing work resource & assert that it now contains a "link" property
    * def workGraphCall = call getResourceGraph { resourceId: '#(workResourceId)' }
    * def workGraphResponse = workGraphCall.response
    * match workGraphResponse.doc contains { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/resources/works/existing-work'] }
