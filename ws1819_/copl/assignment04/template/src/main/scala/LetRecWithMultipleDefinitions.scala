object LetRecWithMultipleDefinitions {
  sealed abstract class RCFAE
  case class Num(n: Int) extends RCFAE
  case class Add(lhs: RCFAE, rhs: RCFAE) extends RCFAE
  case class Sub(lhs: RCFAE, rhs: RCFAE) extends RCFAE
  case class Mult(lhs: RCFAE, rhs: RCFAE) extends RCFAE
  case class Id(name: Symbol) extends RCFAE
  case class Fun(param: Symbol, body: RCFAE) extends RCFAE
  case class App(funExpr: RCFAE, argExpr: RCFAE) extends RCFAE
  case class If0(test: RCFAE, thenBody: RCFAE, elseBody: RCFAE) extends RCFAE
  case class LetRec(name: Symbol, namedExpr: RCFAE, body: RCFAE) extends RCFAE

  implicit def symbolToExpr(symbol: Symbol) = Id(symbol)
  implicit def intToExpr(n: Int) = Num(n)

  sealed abstract class Val
  case class NumV(n: Int) extends Val
  case class ClosureV(param: Symbol, body: RCFAE, env: Env) extends Val

  type Env = scala.collection.Map[Symbol, Val]

  def interp(expr: RCFAE, env: Env = Map.empty): Val = expr match {
    case Num(n) => NumV(n)
    case Add(lhs, rhs) =>
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 + n2)
        case _ => sys.error("can only add numbers, but got: " + (lhsV, rhsV))
      }
    case Sub(lhs, rhs) =>
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 - n2)
        case _ => sys.error("can only subtract numbers, but got: " + (lhsV, rhsV))
      }
    case Mult(lhs, rhs) =>
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 * n2)
        case _ => sys.error("can only multiply numbers, but got: " + (lhsV, rhsV))
      }
    case Id(name) => env(name)
    case Fun(param, body) => ClosureV(param, body, env)
    case App(funExpr, argExpr) =>
      val funV = interp(funExpr, env)
      funV match {
        case ClosureV(funParam, funBody, funEnv) =>
          interp(funBody, funEnv + (funParam -> interp(argExpr, env)))
        case _ => sys.error("can only apply functions, but got: " + funV)
      }
    case If0(test, thenBody, elseBody) =>
      val testV = interp(test, env)
      testV match {
        case NumV(n) => interp(if (n == 0) thenBody else elseBody, env)
        case _ => sys.error("can only test numbers, but got: " + testV)
      }
    case LetRec(name, namedExpr, body) =>
      // create a new mutable environment and add all existing bindings
      val recEnv = collection.mutable.Map() ++ env
      recEnv += name -> interp(namedExpr, recEnv)
      interp(body, recEnv)
  }
}
