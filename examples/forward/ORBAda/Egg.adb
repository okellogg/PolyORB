-- ==================================================== --
-- ===  Code automatically generated by IDL to Ada  === --
-- ===  compiler OrbAda-idl2ada                     === --
-- ===  Copyright Top Graph'X  1997                 === --
-- ==================================================== --

with Corba.Orb ;
with Corba.Type_Codes ;
with Corba_Ios ;
with Corba.Iop ;
with Corba.Object.Ref_To_Any_Conversion ;
with Corba ;
pragma Elaborate (Corba) ;
pragma Elaborate (Corba.Type_Codes) ;
package body Egg is

   Tc_Egg : constant Corba.Typecode.Object :=
      Corba.Typecode.Object_Typecode
         ( Id => Egg_R_Id, 
           Name => Corba.To_Unbounded_String( "Egg"));


   function To_Egg (Self : Corba.Object.Ref'class) return Ref'class is
      This : Ref ;
   begin
      Corba.Object.Ref (This) := Corba.Object.Ref (Self) ;
      return This ;
   end To_Egg;

   function hatch
      ( Self : in Ref)
         return Chicken.Ref is
      Tgx_Stream  : aliased Corba_Ios.Iop_Stream_Type;
      Tgx_Request : Corba.Iop.Request_Id;
      Tgx_Orb     : Corba.Orb.Object := Corba.Orb.Get (Self);
      Tgx_Result  : Chicken.Ref;

      pragma Suppress (Range_Check) ;
   begin
      Corba.Orb.Write_Request
         ( Self              => Self,
           Response_Expected => True,
           Operation         => "hatch",
           Stream            => Tgx_Stream'access) ;

      -- Write in and inout parameters
      -- None

      -- Send message to the ORB (wait for reply if required)
      Corba.Orb.Client_Send_And_Receive ( Self    => Tgx_Orb,
                                          Request => Tgx_Request,
                                          Stream  => Tgx_Stream'access);
      -- Get the result
      Chicken.Ref'Read (Tgx_Stream'access, Tgx_Result);
      return Tgx_Result;

      -- Get the out and inout parameters
      -- None
   end hatch;

   package Egg_To_Any is new Corba.Object.Ref_To_Any_Conversion
      (Ref => Ref, Code => Tc_Egg) ;

   function To_Any (From : in Ref) return Corba.Any renames
      Egg_To_Any.Ref_To_Any ;

   function To_Ref (From : in Corba.Any) return Ref renames
      Egg_To_Any.Any_To_Ref ;
end Egg;

