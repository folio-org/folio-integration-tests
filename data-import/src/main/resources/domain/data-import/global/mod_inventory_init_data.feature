Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def prepareHolding = function(holding, instanceId) {return holding.replaceAll("replace_instanceId", instanceId);}
    * def prepareItem = function(item, holdingId) {return item.replaceAll("replace_holdingId", holdingId);}

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

  Scenario: create holdings type
    * def holdingsType =
    """
       {
	     "source": "folio",
	     "name": "Electronic",
	     "id": "996f93e2-5b5e-4cf2-9168-33ced1f95eed"
       }

    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostHoldingsType') {holdingsType: #(holdingsType)}

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
    * json campuses = read('classpath:domain/data-import/samples/location/campus.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[1])}
    * json libraries = read('classpath:domain/data-import/samples/location/library.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[1])}
    * json locations = read('classpath:domain/data-import/samples/location/locations.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[1])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[2])}
    #setup call number type
    * json callNumberTypes = read('classpath:domain/data-import/samples/call_number/call_number_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType') {callNumberType: #(callNumberTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType') {callNumberType: #(callNumberTypes[1])}
    #setup item loan types
    * json itemLoanTypes = read('classpath:domain/data-import/samples/item_loan_type/item_loan_types.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemLoanType') {itemLoanType: #(itemLoanTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemLoanType') {itemLoanType: #(itemLoanTypes[1])}
    #setup item material type
    * json itemMaterialTypes = read('classpath:domain/data-import/samples/material_type/item_material_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemMaterialType') {materialType: #(itemMaterialTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemMaterialType') {materialType: #(itemMaterialTypes[1])}
    #setup statistical code type
    * json statisticalCodeTypes = read('classpath:domain/data-import/samples/statistical_code/statistical_code_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCodeType') {statisticalCodeType: #(statisticalCodeTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCodeType') {statisticalCodeType: #(statisticalCodeTypes[1])}
    #setup statistical code
    * json statisticalCodes = read('classpath:domain/data-import/samples/statistical_code/statistical_code.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCode') {statisticalCode: #(statisticalCodes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCode') {statisticalCode: #(statisticalCodes[1])}
    #setup URL relationships
    * json relationships = read('classpath:domain/data-import/samples/url_relationship/url_relationship.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostUrlRelationship') {urlRelationship: #(relationships[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostUrlRelationship') {urlRelationship: #(relationships[1])}
    #setup instance status types
    * json instanceStatusTypes = read('classpath:domain/data-import/samples/instance_status_type/instance_status_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceStatusType') {instanceStatusType: #(instanceStatusTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceStatusType') {instanceStatusType: #(instanceStatusTypes[1])}
     #setup item note types
    * json itemNoteTypes = read('classpath:domain/data-import/samples/item_note_type/item_note_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemNoteType') {itemNoteType: #(itemNoteTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemNoteType') {itemNoteType: #(itemNoteTypes[1])}
    #setup ill policy
    * json illPolicies = read('classpath:domain/data-import/samples/ill_policy.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIllPolicy') {illPolicy: #(illPolicies[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIllPolicy') {illPolicy: #(illPolicies[1])}

  Scenario: create instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:domain/data-import/samples/instance.json')
    * def instanceId = 'c1d3be12-ecec-4fab-9237-baf728575185'
    * set instance.id = instanceId
    * set instance.hrid = 'inst' + random(100000)
    And request instance
    When method POST
    Then status 201

  Scenario: create holding
    * string holdingTemplate = read('classpath:domain/data-import/samples/holding.json')
    * def holdingId = uuid()
    * json holding = prepareHolding(holdingTemplate, instanceId);
    * set holding.id = holdingId;
    Given path 'holdings-storage/holdings'
    And request holding
    When method POST
    Then status 201

  Scenario: create item
    * string itemTemplate = read('classpath:domain/data-import/samples/item.json')
    * json item = prepareItem(itemTemplate, holdingId);
    * set item.barcode = '123456';
    Given path 'item-storage/items'
    And request item
    When method POST
    Then status 201