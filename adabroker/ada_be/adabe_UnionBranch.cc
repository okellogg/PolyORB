#include <adabe.h>
#include <strstream>

static string
produce_disc_value( AST_ConcreteType* t,AST_Expression* exp);


adabe_union_branch::adabe_union_branch(AST_UnionLabel *lab, AST_Type *ft, UTL_ScopedName *n,
		  UTL_StrList *p)
                    : AST_Decl(AST_Decl::NT_union_branch, n, p),
                      AST_Field(AST_Decl::NT_union_branch, ft, n, p),
                      AST_UnionBranch(lab, ft, n, p),
		      adabe_field(ft,n,p),
		      adabe_name()
{
}

void
adabe_union_branch::produce_ads(dep_list with, string &body, string &previous, AST_ConcreteType *concrete)
{
  body += "      when ";
  if (label()->label_kind() != AST_UnionLabel::UL_default)
    {
      body += produce_disc_value(concrete, label()->label_val());
      body += " => \n";
    }
  else if (label()->label_kind() == AST_UnionLabel::UL_default)
    {
      body += "others ";
      body += "=> \n";
    }
  adabe_field::produce_ads(with, body, previous);   
}

/*
  /////////////////////// peut etre inutile ///////////////////////
  void
  adabe_union_branch::produce_impl_ads(dep_list with,string &body, string &previous, AST_ConcreteType *concrete)
  {
  produce_ads(with, body, previous, concrete);
  }
*/ 

void
adabe_union_branch::produce_marshal_adb(dep_list with, string &body, string &previous)
{
}

static string
produce_disc_value( AST_ConcreteType* t,AST_Expression* exp)
{
  ostringstream ost;
  if (t->node_type() != AST_Decl::NT_enum)
    {
      AST_Expression::AST_ExprValue *v = exp->ev();
      switch (v->et) 
	 {
	 case AST_Expression::EV_short:
	   ost << v->u.sval;
	   break;
	 case AST_Expression::EV_ushort:
	   ost << v->u.usval;
	   break;
	 case AST_Expression::EV_long:
	   ost << v->u.lval;
	   break;
	 case AST_Expression::EV_ulong:
	   ost << v->u.ulval;
	   break
	 case AST_Expression::EV_bool:
	   return ((v->u.bval == 0) ? "FALSE" : "TRUE");
	 case AST_Expression::EV_char:        
	   ost <<  v->u.cval;
	     //	    if (c >= ' ' && c <= '~')
	     //	      s << "'" << c << "'";
	     //	    else {
	     //	      s << "'\\"
	     //		<< (int) ((c & 0100) >> 6)
	     //		<< (int) ((c & 070) >> 3)
	     //		<< (int) (c & 007)
	     //		<< "'";
	     //	    }
	   break;
	 default:
	   throw adabe_internal_error(__FILE__,__LINE__,
				      "Unexpected union discriminant value");
	 }
    }
  else
    {
      AST_EnumVal* v = AST_Enum::narrow_from_decl(t)->lookup_by_value(exp);
      return (v.get_ada_local_name());
    }
  return ost.str();
}
IMPL_NARROW_METHODS1(adabe_union_branch, AST_UnionBranch)
IMPL_NARROW_FROM_DECL(adabe_union_branch)







