package org.folio;

import java.util.List;
import java.util.stream.Stream;
import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

@FolioTest(team = "corsair", module = "mod-fqm-manager")
@Deprecated(forRemoval = true)
@Disabled
public class ModFqmManagerTest extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:corsair/mod-fqm-manager/features/";

  public ModFqmManagerTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:corsair/mod-fqm-manager/fqm-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  static List<Arguments> features() {
    return Stream
      .of(
        "entity-types",
        "migration",
        "query/basic-usage",
        "query/operators-basic",
        "query/operators-array",
        "query/per-entity-type",
        "query/special-field-tests",
        "query/validation"
      )
      .map(Arguments::of)
      .toList();
  }

  @ParameterizedTest
  @MethodSource("features")
  void featureTest(String feature) {
    runFeatureTest(feature);
  }
}
