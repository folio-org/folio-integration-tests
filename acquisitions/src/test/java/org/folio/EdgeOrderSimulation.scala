package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class EdgeOrderSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/orders" -> Nil,
    "/orders/order-lines" -> Nil,
    "/orders/validate" -> Nil,
    "organizations-storage/organizations" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:thunderjet/edge-orders/edge-orders-junit.feature"))
  val create = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/edge-orders/features/gobi.feature"))
    }
  val after = scenario("after")
    .exec(karateFeature("classpath:thunderjet/edge-orders/edge-orders-destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
