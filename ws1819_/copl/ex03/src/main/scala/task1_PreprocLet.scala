import definitions.FAEBase._
import definitions.FLAEBase._

// --------------------------------------------
// --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
// --------------------------------------------

object PreprocLet {
  def preprocLet(expr: FLAE): FAE = expr match {
    case LNum(n) => Num(n)
    case LAdd(lhs, rhs) => Add(preprocLet(lhs), preprocLet(rhs))
    case LId(name) => Id(name)
    case LSub(lhs, rhs) =>  Sub(preprocLet(lhs), preprocLet(rhs))
    case LApp(lhs, rhs) =>  App(preprocLet(lhs), preprocLet(rhs))
    case LFun(param, body) => Fun(param, preprocLet(body))
    case LLet(name, namedExpr, body) => App(Fun(name, preprocLet(body)), preprocLet(namedExpr))
  }
}
