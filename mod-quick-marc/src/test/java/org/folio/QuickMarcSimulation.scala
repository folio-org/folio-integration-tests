package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class QuickMarcSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/records-editor/records/{externalId}" -> Nil,
    "/records-editor/records" -> Nil
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val testBasePath = "classpath:spitfire/mod-quick-marc/"

  val setupInfrastructure = scenario("setupInfrastructure")
    .exec(karateFeature(testBasePath + "quick-marc-junit.feature"))
  val setupData = scenario("setupData")
    .exec(karateFeature(testBasePath + "features/setup/setup.feature@SetupTypes"))
    .exec(karateFeature(testBasePath + "features/setup/setup.feature@CreateSnapshot"))
  val updateMarcBibs = scenario("update")
    .repeat(10) {
      exec(karateFeature(testBasePath + "features/marc-bib-update.feature"))
    }
  val destroy = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    setupInfrastructure.inject(atOnceUsers(1))
      .andThen(setupData.inject(atOnceUsers(1)))
      .andThen(updateMarcBibs.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(destroy.inject(nothingFor(3 seconds), atOnceUsers(1)))
  ).protocols(protocol)

}