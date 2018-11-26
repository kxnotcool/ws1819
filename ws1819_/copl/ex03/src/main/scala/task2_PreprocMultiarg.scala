import definitions.FLAEBase._
import definitions.MFLAEBase._

// --------------------------------------------
// --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
// --------------------------------------------

object PreprocMultiarg {
  def preprocMultiarg(expr: MFLAE): FLAE = expr match {
    case MLAdd(lhs, rhs) => LAdd(preprocMultiarg(lhs), preprocMultiarg(rhs))
    case MLApp(funExpr, args) => funExpr match {
      case MLFun(params, body) => var i = 0
        var mybody = preprocMultiarg(body)
        for(i <- 0 until args.size){
          mybody = LApp(LFun(params(i), mybody), mybody)
        }
        mybody
      case _ =>
        sys.error("Can only handle function expressions")
    }
    case MLFun(params, body) => params.size match {
      case 0 => preprocMultiarg(body)
      case _ =>
      var i = 0
      var mybody = preprocMultiarg(body)
      for(i <- 0 until params.size){
        mybody = LFun(params(i), mybody)
      }
      mybody
    }
    case MLId(name) => LId(name)
    case MLLet(name, namedExpr, body) => namedExpr match {
      case MLFun(params, funbody) => params.size match {
        case 0 => LLet(name, preprocMultiarg(funbody), preprocMultiarg(body))
        case _ =>
        LLet(name, LFun(params(0), preprocMultiarg(funbody)), preprocMultiarg(body))}
      case _ => LLet(name, preprocMultiarg(namedExpr), preprocMultiarg(body))
    }
    case MLNum(n) => LNum(n)
    case MLSub(lhs, rhs) => LSub(preprocMultiarg(lhs), preprocMultiarg(rhs))

  }
}
