Feature: Set for deletion

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def utilsPath = 'classpath:folijet/mod-inventory/features/utils.feature'

    Scenario: Set instance for deletion and back
      Given def instance = call read(utilsPath + '@CreateInstance') { source:'MARC', title:'InstanceForDeletion' }
      And def instanceId = instance.id

      * def instanceHrid = 'in' + ("00000000000" + Math.floor(Math.random() * 10000000000)).slice(-11)
      Given def snapshot = call read(utilsPath + '@CreateSnapshot')
      And def snapshotId = snapshot.id

      Given def record = call read(utilsPath + '@CreateRecord')
      And def recordId = record.id

      * eval instance['deleted'] = true
      * eval instance['staffSuppress'] = true
      * eval instance['discoverySuppress'] = true

      * call read(utilsPath + '@UpdateInstance')

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.staffSuppress == true
      And match response.discoverySuppress == true
      And match response.deleted == true

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "DELETED"
      And match response.deleted == true
      And match response.additionalInfo.suppressDiscovery == true
      And match response.leaderRecordStatus == "d"
      And match response.parsedRecord.content.leader.charAt(5) == "d"
      And def updatedDateValue = response.parsedRecord.content.fields[*].005

      * eval instance['deleted'] = false
      * eval instance['discoverySuppress'] = false

      * call read(utilsPath + '@UpdateInstance')

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.staffSuppress == true
      And match response.discoverySuppress == false
      And match response.deleted == false

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "ACTUAL"
      And match response.deleted == false
      And match response.additionalInfo.suppressDiscovery == false
      And match response.leaderRecordStatus == "c"
      And match response.parsedRecord.content.leader.charAt(5) == "c"

      ## Send update request wihtout changing flags values
      ## Updated date (005) must not be changed
      * call read(utilsPath + '@UpdateInstance')

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.staffSuppress == true
      And match response.discoverySuppress == false
      And match response.deleted == false

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "ACTUAL"
      And match response.deleted == false
      And match response.additionalInfo.suppressDiscovery == false
      And match response.leaderRecordStatus == "c"
      And match response.parsedRecord.content.leader.charAt(5) == "c"
      And match response.parsedRecord.content.fields[*].005 == updatedDateValue
