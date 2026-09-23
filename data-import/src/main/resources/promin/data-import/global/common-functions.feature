Feature: Common Functions

  Scenario: Declare common functions
    * def utilFeature = 'classpath:promin/data-import/global/import-record.feature'
    * def importHoldingFeature = 'classpath:promin/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem'
    * def commonImportFeature = 'classpath:promin/data-import/global/common-data-import.feature'
    * def getCompletedJobFeature = 'classpath:promin/data-import/global/get-completed-job-execution.feature'
    * def completeExecutionFeature = 'classpath:promin/data-import/global/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def exportRecordFeature = 'classpath:promin/data-import/global/export-record.feature'
    * def createExportMappingProfile = karate.read('classpath:promin/data-import/global/data-export-profiles.feature@createMappingProfile')
    * def createExportJobProfile = karate.read('classpath:promin/data-import/global/data-export-profiles.feature@createJobProfile')
    * def samplePath = 'classpath:promin/data-import/samples/'
    * def updateHoldings = 'classpath:promin/data-import/features/data-import-integration.feature@UpdateHoldings'
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'
    * def defaultCreateAuthorityJobProfileId = '6eefa4c6-bbf7-4845-ad82-de7fc5abd0e3'
    * def defaultDeleteAuthorityJobProfileId = '1a338fcd-3efc-4a03-b007-394eeb0d5fb9'
    * def defaultDeleteAuthorityActionProfileId = 'fabd9a3e-33c3-49b7-864d-c5af830d9990'
    * def javaWriteData = Java.type('test.java.WriteData')

