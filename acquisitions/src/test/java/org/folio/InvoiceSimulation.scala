package org.folio

import com.intuit.karate.gatling.KarateProtocol
import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder

import java.util.concurrent.ThreadLocalRandom
import scala.concurrent.duration._
import scala.language.postfixOps

class InvoiceSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = ThreadLocalRandom.current().nextLong()
    constantString + randomLong
  }

  val protocol: KarateProtocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/invoice/invoices" -> Nil,
    "/invoice/invoices/{invoiceId}" -> Nil,
    "/invoice/invoice-lines" -> Nil,
    "/invoice/invoice-lines/{invoiceLineId}" -> Nil,
    "/finance/transactions" -> Nil,
    "/finance/budgets/{budgetId}" -> Nil,
    "/voucher/vouchers" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before: ScenarioBuilder = scenario("before")
    .exec(karateFeature("classpath:thunderjet/mod-invoice/invoice-junit.feature"))
  val create: ScenarioBuilder = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/mod-invoice/features/cancel-invoice.feature"))
    }
  val after: ScenarioBuilder = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
