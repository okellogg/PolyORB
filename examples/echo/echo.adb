----------------------------------------------------------------------------
----                                                                    ----
----     This in an example which is hand-written                       ----
----     for the echo object                                            ----
----                                                                    ----
----                package body echo                                   ----
----                                                                    ----
----                authors : Fabien Azavant, Sebastien Ponce           ----
----                                                                    ----
----                                                                    ----
----------------------------------------------------------------------------

with Omniproxycallwrapper ;
with Echo.Proxies ;

package body Echo is

   --------------------------------------------------
   ----                spec                      ----
   --------------------------------------------------

   -- To_Ref
   ---------
   function To_Ref(The_Ref: in Corba.Object.Ref'Class) return Ref is
      Dynamic_Object : Corba.Object.Ref'Class := Corba.Object.Get_Dynamic_Object(The_Ref) ;
      Result : Ref ;
   begin
      -- AdaBroker_Cast_To_Parent(Dynamic_Object,Ref) ;
      return Result ;
   end ;


   -- EchoString
   -------------
   function EchoString(Self: in Ref ;
                       Message: in Corba.String)
                       return Corba.String is

      Opcd : Echo.Proxies.EchoString_Proxy ;
      Result : Corba.String ;
   begin
      Opcd := Echo.Proxies.Create(Message) ;
      OmniProxyCallWrapper.Invoke(Self, Opcd) ;
      Result := Echo.Proxies.Get_Result(Opcd) ;
      Echo.Proxies.Free(Opcd) ;
      return Result ;
   end ;


   --------------------------------------------------
   ----    not in  spec AdaBroker specific       ----
   --------------------------------------------------

   -- AdaBroker_Cast_To_Parent
   ---------------------------
   procedure AdaBroker_Cast_To_Parent(Real_Object: in Ref;
                                      Result: out Corba.Object.Ref'Class) is
      Tricky_Result : Corba.Object.Ref'Class := Real_Object ;
   begin
      if Result in Ref then
         Result := Tricky_Result ;
      else
         raise Constraint_Error ;
      end if;
   end ;



End Echo ;




