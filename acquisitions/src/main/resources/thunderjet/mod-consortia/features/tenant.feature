Feature: Consortium object in mod-consortia api tests

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

#@RestController
#@RequestMapping("/consortia/{consortiumId}")
#@RequiredArgsConstructor
#public class TenantController implements TenantsApi {
#  @Autowired
#  private final TenantService service;
#
#  @Override
#  public ResponseEntity<TenantCollection> getTenants(UUID consortiumId, Integer offset, Integer limit) {
#    return ResponseEntity.ok(service.get(consortiumId, offset, limit));
#  }
#
#  @Override
#  public ResponseEntity<Tenant> saveTenant(UUID consortiumId, Tenant tenant) {
#    return ResponseEntity.ok(service.save(consortiumId, tenant));
#  }
#
#  @Override
#  public ResponseEntity<Tenant> updateTenant(UUID consortiumId, String tenantId, Tenant tenant) {
#    return ResponseEntity.ok(service.update(consortiumId, tenantId, tenant));
#  }
#}
#
#@Table(name = "tenant")
#public class TenantEntity {
#  @Id
#  private String id;
#  private String name;
#  private UUID consortiumId;
#
#  @Override
#  public boolean equals(Object o) {
#    if (this == o) return true;
#    if (o == null || getClass() != o.getClass()) return false;
#    TenantEntity that = (TenantEntity) o;
#    return Objects.equals(id, that.id) && Objects.equals(name, that.name) && Objects.equals(consortiumId, that.consortiumId);
#  }
#
#  @Override
#  public int hashCode() {
#    return Objects.hash(id, name, consortiumId);
#  }
#}
#write test for above entity based on controller

# write random uuid

  Scenario: Create, Read, Update a tenant

    # Create a consortium
    Given path '/consortia'
    And request
    """
    {
      id: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      name: 'Test'
    }
    """
    When method POST
    Then status 200
    Then print '\n' , response

    # Create a tenant
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'tenants'
    And request { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c33" }
    When method POST
    Then status 200
    And match response == { "id": "1234", "name": "test" }

#    # Get tenant tenants
#    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'tenants', '1234'
#    When method GET
#    Then status 200
#    And match response == { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c33" }
#
#    # Update a tenant
#    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'tenants', '1234'
#    And request { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c33" }
#    When method PUT
#    Then status 200
#    And match response == { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c33" }