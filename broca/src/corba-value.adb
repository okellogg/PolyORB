with Broca.Value.Value_Skel;
with Broca.Exceptions;

package body Corba.Value is

   ------------
   --  Is_A  --
   ------------
   --  This code is copied from what is generated by idlac
   --  for any usual function call. This method is inherited
   --  by all valuetypes. Unlike Interfaces, we do not have to
   --  override this method in every valuetype. The only reason
   --  why we override this method for interfaces is to avoid
   --  the remote call. There cannot be any remote call with valuetypes
   --  so let's keep it simple like that.

   function Is_A
     (Self : in Base;
      Logical_Type_Id : Standard.String)
      return CORBA.Boolean
   is
      Is_A_Operation : Broca.Value.Value_Skel.Is_A_Type;
      Precise_Object : constant CORBA.Impl.Object_Ptr
        := CORBA.Impl.Object_Ptr (Object_Of (Self));
   begin
      --  Sanity check
      if Is_Nil (Self) then
         Broca.Exceptions.Raise_Inv_Objref;
      end if;

      --  Find the operation
      Is_A_Operation :=
        Broca.Value.Value_Skel.Is_A_Store.Get_Operation
        (Precise_Object.all'Tag);

      --  Call it operation
      return
        Is_A_Operation (Logical_Type_Id);

   end Is_A;

end Corba.Value;
