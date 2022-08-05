Feature: init acquisitions data

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: create organization
  Given path 'organizations-storage/organizations'
  And request
  """
  {
    id: 'c6dace5d-4574-411e-8ba1-036102fcdc9b',
    name: 'GOBI Library Solutions"',
    code: 'GOBI',
    isVendor: true,
    status: 'Active'
  }
  """
  When method POST
  Then status 201