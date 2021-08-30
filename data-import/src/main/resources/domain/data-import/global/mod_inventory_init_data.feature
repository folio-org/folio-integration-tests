Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: create instance type
    * def instanceType =
    """
      {
        "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "name": "txt",
        "code": "txt",
        "source": "rdacontent"
      }
    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceType') {instanceType: #(instanceType)}

  Scenario: create identifier type
    * def identifierType =
    """
      {
        "id": "8261054f-be78-422d-bd51-4ed9f33c3422",
        "name": "ISBN",
        "source": "folio"
      }
    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIdentifierType') {identifierType: #(identifierType)}

  Scenario: setup common data
    #setup locations
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstitution')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary')
    * json locations = read('classpath:domain/data-import/samples/location/locations.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[1])}
    #setup call number type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType')
    #setup ill policy type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIllPolicy')
    #setup loan types
    * json loans = read('classpath:domain/data-import/samples/loan/item_loan_types.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLoanType') {loanType: #(loans[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLoanType') {loanType: #(loans[1])}
    #setup material type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostMaterialType')
    #setup note types
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostHoldingNoteType')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemNoteType')
    #setup statistical code
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemStatisticalCodeType')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemStatisticalCode')









