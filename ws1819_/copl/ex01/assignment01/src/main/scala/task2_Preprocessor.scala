object Preprocessor {

  /** BooleanExpression represents the abstract syntax of our language,
    * i.e. the representation a parser would generate by reading the program code.
    * This will be consumed by the interpreter (the eval function) to produce a result BooleanValue. */
  sealed trait BooleanExpression
  case object True extends BooleanExpression
  case object False extends BooleanExpression
  case class Not(expr: BooleanExpression) extends BooleanExpression
  case class And(lhs: BooleanExpression, rhs: BooleanExpression) extends BooleanExpression
  case class Or(lhs: BooleanExpression, rhs: BooleanExpression) extends BooleanExpression
  case class Imp(lhs: BooleanExpression, rhs: BooleanExpression) extends BooleanExpression
  case class BiImp(lhs: BooleanExpression, rhs: BooleanExpression) extends BooleanExpression

  // --------------------------------------------
  // --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
  // --------------------------------------------

  // implement this function
  //Imp(x,y) = true,  if x==true && y == true
  //x  y  Imp(x,y) BiImp(x,y)
  //t  t  t        t
  //t  f  f        f
  //f  t  t        f
  //f  f  t        t

  def preproc(expr: BooleanExpression): BooleanExpression = expr match {
    case Imp(lhs, rhs) =>  Or(Not(preproc(lhs)), preproc(rhs))
    //Or(Not(lhs), rhs)
    case BiImp(lhs, rhs) => And(Or(Not(preproc(lhs)), preproc(rhs)), Or(Not(preproc(rhs)), preproc(lhs)))
    case Not(x) =>  Not(preproc(x))
    case And(lhs, rhs) => And(preproc(lhs), preproc(rhs))//And(preproc(lhs), preproc(rhs))

    case Or(lhs, rhs) => Or(preproc(lhs), preproc(rhs))//Or(preproc(lhs), preproc(rhs))
    case True => True
    case False => False
  }

}
