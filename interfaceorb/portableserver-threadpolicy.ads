
package PortableServer.ThreadPolicy is

   type Ref is new CORBA.Policy.Ref with null record;

   function Get_Value (Self : Ref) return ThreadPolicyValue;

end PortableServer.ThreadPolicy;
