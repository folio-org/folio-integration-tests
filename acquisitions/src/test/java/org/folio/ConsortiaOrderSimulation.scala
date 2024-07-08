package org.folio

import com.intuit.karate.gatling.KarateProtocol
import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class ConsortiaOrderSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol: KarateProtocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/orders/composite-orders" -> Nil,
    "/orders/composite-orders/{orderId}" -> Nil,
    "orders/order-lines" -> Nil,
    "inventory/instances" -> Nil,
    "holdings-storage/holdings" -> Nil,
    "inventory/items" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before: ScenarioBuilder = scenario("before")
    .exec(karateFeature("classpath:thunderjet/consortia/gatling-setup/consortia-orders-gatling-setup.feature"))
  val create: ScenarioBuilder = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/consortia/features/open-order-with-locations-from-different-tenants.feature"))
    }
  val after: ScenarioBuilder = scenario("after")
    .exec(karateFeature("classpath:thunderjet/consortia/gatling-setup/consortia-orders-gatling-clean.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}