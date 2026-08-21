Feature: Destroy folio-ecs-circulation consortia tenants

  # Runs once after all suites. Tenant IDs are resolved by name before deletion.

  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin

  Scenario: Destroy created ['consortium', 'college', 'university'] tenants
    * def deleteTenant = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')
    * def getTenantIdByName = read('classpath:vega/common/tenant-lookup.feature@getIdByName')
    * print 'destroy-consortia: deleting', centralTenant, collegeTenant, universityTenant
    * def centralLookup = call getTenantIdByName { tenantName: '#(centralTenant)' }
    * def centralIdToDelete = centralLookup.tenantId != null ? centralLookup.tenantId : centralTenantId
    * call deleteTenant { tenantName: '#(centralTenant)', tenantId: '#(centralIdToDelete)' }
    * def collegeLookup = call getTenantIdByName { tenantName: '#(collegeTenant)' }
    * def collegeIdToDelete = collegeLookup.tenantId != null ? collegeLookup.tenantId : collegeTenantId
    * call deleteTenant { tenantName: '#(collegeTenant)', tenantId: '#(collegeIdToDelete)' }
    * def universityLookup = call getTenantIdByName { tenantName: '#(universityTenant)' }
    * def universityIdToDelete = universityLookup.tenantId != null ? universityLookup.tenantId : universityTenantId
    * call deleteTenant { tenantName: '#(universityTenant)', tenantId: '#(universityIdToDelete)' }
