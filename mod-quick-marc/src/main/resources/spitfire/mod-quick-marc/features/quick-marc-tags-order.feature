Feature: Test MARC records tags order
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

  Scenario: Check marc bib tags order
    * def marcBib = call read('setup/setup.feature@CreateMarcBibRecord')
    * def record = marcBib.response
    * def marcBibId = record.externalId
    * def createdFields = record.fields
    * def payloadFields = marcBib.recordPayload.fields
    # check payload fields tag order
    And match payloadFields[0].tag == "010"
    And match payloadFields[1].tag == "035"
    And match payloadFields[2].tag == "035"
    And match payloadFields[3].tag == "040"
    And match payloadFields[4].tag == "041"
    And match payloadFields[5].tag == "045"
    And match payloadFields[6].tag == "047"
    And match payloadFields[7].tag == "050"
    And match payloadFields[8].tag == "066"
    And match payloadFields[9].tag == "100"
    And match payloadFields[10].tag == "240"
    And match payloadFields[11].tag == "245"
    And match payloadFields[12].tag == "246"
    And match payloadFields[13].tag == "249"
    And match payloadFields[14].tag == "260"
    And match payloadFields[15].tag == "004"
    And match payloadFields[16].tag == "300"
    And match payloadFields[17].tag == "505"
    And match payloadFields[18].tag == "590"
    And match payloadFields[19].tag == "650"
    And match payloadFields[20].tag == "650"
    And match payloadFields[21].tag == "650"
    And match payloadFields[22].tag == "650"
    And match payloadFields[23].tag == "880"
    And match payloadFields[24].tag == "902"
    And match payloadFields[25].tag == "006"
    And match payloadFields[26].tag == "007"
    And match payloadFields[27].tag == "008"
    # Verify that '001' and '005' tags are at 28 and 29 indexes; they will be moved to the top of the tag list
    And match payloadFields[28].tag == "001"
    And match payloadFields[29].tag == "005"
    And match payloadFields[30].tag == "905"
    And match payloadFields[31].tag == "948"
    And match payloadFields[32].tag == "948"
    And match payloadFields[33].tag == "948"
    And match payloadFields[34].tag == "948"

    # check created fields tag order. The '001' and '005' tags should be at the top of the list
    And match createdFields[0].tag == "001"
    And match createdFields[1].tag == "005"
    And match createdFields[2].tag == "010"
    And match createdFields[3].tag == "035"
    And match createdFields[4].tag == "035"
    And match createdFields[5].tag == "040"
    And match createdFields[6].tag == "041"
    And match createdFields[7].tag == "045"
    And match createdFields[8].tag == "047"
    And match createdFields[9].tag == "050"
    And match createdFields[10].tag == "066"
    And match createdFields[11].tag == "100"
    And match createdFields[12].tag == "240"
    And match createdFields[13].tag == "245"
    And match createdFields[14].tag == "246"
    And match createdFields[15].tag == "249"
    And match createdFields[16].tag == "260"
    And match createdFields[17].tag == "004"
    And match createdFields[18].tag == "300"
    And match createdFields[19].tag == "505"
    And match createdFields[20].tag == "590"
    And match createdFields[21].tag == "650"
    And match createdFields[22].tag == "650"
    And match createdFields[23].tag == "650"
    And match createdFields[24].tag == "650"
    And match createdFields[25].tag == "880"
    And match createdFields[26].tag == "902"
    And match createdFields[27].tag == "006"
    And match createdFields[28].tag == "007"
    And match createdFields[29].tag == "008"
    And match createdFields[30].tag == "905"
    And match createdFields[31].tag == "948"
    And match createdFields[32].tag == "948"
    And match createdFields[33].tag == "948"
    And match createdFields[34].tag == "948"
    And match createdFields[35].tag == "999"

    * print "Update tags order to descending order"
    # Sort the fields array in descending order based on the tag value
    * def sortedFields = createdFields.sort((a, b) => b.tag.localeCompare(a.tag))
    * set record.fields = sortedFields
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(record.parsedRecordId)', record: '#(record)' }

    # Perform matches based on the new tags order
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcBibId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "948"
    And match fields[2].tag == "948"
    And match fields[3].tag == "948"
    And match fields[4].tag == "948"
    And match fields[5].tag == "905"
    And match fields[6].tag == "902"
    And match fields[7].tag == "880"
    And match fields[8].tag == "650"
    And match fields[9].tag == "650"
    And match fields[10].tag == "650"
    And match fields[11].tag == "650"
    And match fields[12].tag == "590"
    And match fields[13].tag == "505"
    And match fields[14].tag == "300"
    And match fields[15].tag == "260"
    And match fields[16].tag == "249"
    And match fields[17].tag == "246"
    And match fields[18].tag == "245"
    And match fields[19].tag == "240"
    And match fields[20].tag == "100"
    And match fields[21].tag == "066"
    And match fields[22].tag == "050"
    And match fields[23].tag == "047"
    And match fields[24].tag == "045"
    And match fields[25].tag == "041"
    And match fields[26].tag == "040"
    And match fields[27].tag == "035"
    And match fields[28].tag == "035"
    And match fields[29].tag == "010"
    And match fields[30].tag == "008"
    And match fields[31].tag == "007"
    And match fields[32].tag == "006"
    And match fields[33].tag == "005"
    And match fields[34].tag == "004"
    And match fields[35].tag == "001"

    * print "add new '003' tag with [5] index position and remove '035' tags"
    * def field003 = { "tag": "003", "content": "DLC", "isProtected":false }
    * def firstPart = fields.slice(0, 5)
    * def secondPart = fields.slice(5)
    * firstPart.push(field003)
    * def newFields = firstPart.concat(secondPart)
    # remove '035' tags
    * def updatedFields = newFields.filter(x => x.tag != '035')
    * set quickMarcJson.fields = updatedFields
    * set quickMarcJson.relatedRecordVersion = 2
    * set quickMarcJson._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(quickMarcJson.parsedRecordId)', record: '#(quickMarcJson)' }

    * print "check tags order after adding new '003' tag and removing '035' tags"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcBibId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "948"
    And match fields[2].tag == "948"
    And match fields[3].tag == "948"
    And match fields[4].tag == "948"
    And match fields[5].tag == "003"
    And match fields[6].tag == "905"
    And match fields[7].tag == "902"
    And match fields[8].tag == "880"
    And match fields[9].tag == "650"
    And match fields[10].tag == "650"
    And match fields[11].tag == "650"
    And match fields[12].tag == "650"
    And match fields[13].tag == "590"
    And match fields[14].tag == "505"
    And match fields[15].tag == "300"
    And match fields[16].tag == "260"
    And match fields[17].tag == "249"
    And match fields[18].tag == "246"
    And match fields[19].tag == "245"
    And match fields[20].tag == "240"
    And match fields[21].tag == "100"
    And match fields[22].tag == "066"
    And match fields[23].tag == "050"
    And match fields[24].tag == "047"
    And match fields[25].tag == "045"
    And match fields[26].tag == "041"
    And match fields[27].tag == "040"
    And match fields[28].tag == "010"
    And match fields[29].tag == "008"
    And match fields[30].tag == "007"
    And match fields[31].tag == "006"
    And match fields[32].tag == "005"
    And match fields[33].tag == "004"
    And match fields[34].tag == "001"

  Scenario: Check marc holding tags order
    * def marcHolding = call read('setup/setup.feature@CreateHoldingRecord')
    * def record = marcHolding.response
    * def marcHoldingId = record.externalId
    * def createdFields = record.fields
    * def payloadFields = marcHolding.record.fields
    # check payload fields tag order
    And match payloadFields[0].tag == "014"
    And match payloadFields[1].tag == "014"
    And match payloadFields[2].tag == "035"
    And match payloadFields[3].tag == "852"
    And match payloadFields[4].tag == "004"
    And match payloadFields[5].tag == "866"
    And match payloadFields[6].tag == "868"
    # Verify that '999' tag is at 7 index, it will be moved to the end of the tag list
    And match payloadFields[7].tag == "999"
    # Verify that '001' and '005' tags are at 8 and 10 indexes, they will be moved to the top of the tag list
    And match payloadFields[8].tag == "005"
    And match payloadFields[9].tag == "008"
    And match payloadFields[10].tag == "001"

    # check created fields tag order. The '001' and '005' tags should be moved at the top of the list,'999' tag should be moved to the end of the list
    And match createdFields[0].tag == "001"
    And match createdFields[1].tag == "005"
    And match createdFields[2].tag == "014"
    And match createdFields[3].tag == "014"
    And match createdFields[4].tag == "035"
    And match createdFields[5].tag == "852"
    And match createdFields[6].tag == "004"
    And match createdFields[7].tag == "866"
    And match createdFields[8].tag == "868"
    And match createdFields[9].tag == "008"
    And match createdFields[10].tag == "999"

    * print "Update tags order to descending order"
    # Sort the fields array in descending order based on the tag value
    * def sortedFields = createdFields.sort((a, b) => b.tag.localeCompare(a.tag))
    * set record.fields = sortedFields
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(record.parsedRecordId)', record: '#(record)' }

    # Perform matches based on the new tags order
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcHoldingId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "868"
    And match fields[2].tag == "866"
    And match fields[3].tag == "852"
    And match fields[4].tag == "035"
    And match fields[5].tag == "014"
    And match fields[6].tag == "014"
    And match fields[7].tag == "008"
    And match fields[8].tag == "005"
    And match fields[9].tag == "004"
    And match fields[10].tag == "001"

    * print "add new '003' tag with [3] index position and remove '014' tags"
    * def field003 = { "tag": "003", "content": "DLC", "isProtected":false }
    * def firstPart = fields.slice(0, 3)
    * def secondPart = fields.slice(3)
    * firstPart.push(field003)
    * def newFields = firstPart.concat(secondPart)
    # remove '014' tags
    * def updatedFields = newFields.filter(x => x.tag != '014')
    * set quickMarcJson.fields = updatedFields
    * set quickMarcJson.relatedRecordVersion = 1
    * set quickMarcJson._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(quickMarcJson.parsedRecordId)', record: '#(quickMarcJson)' }

    * print "check tags order after adding new '003' tag and removing '014' tags"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcHoldingId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "868"
    And match fields[2].tag == "866"
    And match fields[3].tag == "003"
    And match fields[4].tag == "852"
    And match fields[5].tag == "035"
    And match fields[6].tag == "008"
    And match fields[7].tag == "005"
    And match fields[8].tag == "004"
    And match fields[9].tag == "001"

  Scenario: Check marc authority tags order
    * def marcAuthority = call read('setup/setup.feature@CreateMarcAuthorityRecord')
    * def record = marcAuthority.response
    * def marcAuthorityId = record.externalId
    * def createdFields = record.fields
    * def payloadFields = marcAuthority.record.fields
    # check payload fields tag order
    And match payloadFields[0].tag == "010"
    And match payloadFields[1].tag == "040"
    And match payloadFields[2].tag == "100"
    And match payloadFields[3].tag == "551"
    And match payloadFields[4].tag == "670"
    And match payloadFields[5].tag == "670"
    # Verify that '999' tag is at 6 index, it will be moved to the end of the tag list
    And match payloadFields[6].tag == "999"
    # Verify that '001' and '005' tags are at 7 and 10 indexes, they will be moved to the top of the tag list
    And match payloadFields[7].tag == "001"
    And match payloadFields[8].tag == "003"
    And match payloadFields[9].tag == "008"
    And match payloadFields[10].tag == "005"

    # check created fields tag order. The '001' and '005' tags should be moved at the top of the list,'999' tag should be moved to the end of the list
    And match createdFields[0].tag == "001"
    And match createdFields[1].tag == "005"
    And match createdFields[2].tag == "010"
    And match createdFields[3].tag == "040"
    And match createdFields[4].tag == "100"
    And match createdFields[5].tag == "551"
    And match createdFields[6].tag == "670"
    And match createdFields[7].tag == "670"
    And match createdFields[8].tag == "003"
    And match createdFields[9].tag == "008"
    And match createdFields[10].tag == "999"

    * print "Update tags order to descending order"
    # Sort the fields array in descending order based on the tag value
    * def sortedFields = createdFields.sort((a, b) => b.tag.localeCompare(a.tag))
    * set record.fields = sortedFields
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(record.parsedRecordId)', record: '#(record)' }

    # Perform matches based on the new tags order
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcAuthorityId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "670"
    And match fields[2].tag == "670"
    And match fields[3].tag == "551"
    And match fields[4].tag == "100"
    And match fields[5].tag == "040"
    And match fields[6].tag == "010"
    And match fields[7].tag == "008"
    And match fields[8].tag == "005"
    And match fields[9].tag == "003"
    And match fields[10].tag == "001"

    * print "add new '004' tag with [5] index position and remove '003' tags"
    * def field004 = { "tag": "004", "content": "DLC", "isProtected":false }
    * def firstPart = fields.slice(0, 5)
    * def secondPart = fields.slice(5)
    * firstPart.push(field004)
    * def newFields = firstPart.concat(secondPart)
    # remove '003' tags
    * def updatedFields = newFields.filter(x => x.tag != '003')
    * set quickMarcJson.fields = updatedFields
    * set quickMarcJson.relatedRecordVersion = 1
    * set quickMarcJson._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(quickMarcJson.parsedRecordId)', record: '#(quickMarcJson)' }

    * print "check tags order after adding new '004' tag and removing '003' tags"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcAuthorityId)' }
    And def quickMarcJson = record.response
    And def fields = quickMarcJson.fields
    And match fields[0].tag == "999"
    And match fields[1].tag == "670"
    And match fields[2].tag == "670"
    And match fields[3].tag == "551"
    And match fields[4].tag == "100"
    And match fields[5].tag == "004"
    And match fields[6].tag == "040"
    And match fields[7].tag == "010"
    And match fields[8].tag == "008"
    And match fields[9].tag == "005"
    And match fields[10].tag == "001"