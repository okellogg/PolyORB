------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                     B R O C A . E X C E P T I O N S                      --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1999-2000 ENST Paris University, France.          --
--                                                                          --
-- AdaBroker is free software; you  can  redistribute  it and/or modify it  --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. AdaBroker  is distributed  in the hope that it will be  useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with AdaBroker; see file COPYING. If  --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;
with Ada.Exceptions; use Ada.Exceptions;
with CORBA; use CORBA;
with Broca.CDR;
with Broca.Exceptions.Stack;
with Broca.Names; use Broca.Names;

package body Broca.Exceptions is

   -----------------------
   -- Exception mapping --
   -----------------------

   type String_Access is access constant String;

   type Exception_Mapping is record
      Exc  : Ada.Exceptions.Exception_Id;
      Name : String_Access;
   end record;

   Mapping : constant array (Positive range <>) of Exception_Mapping :=
     ((Exc  => CORBA.Unknown'Identity,
       Name => new String'("UNKNOWN")),
      (Exc  => CORBA.Bad_Param'Identity,
       Name => new String'("BAD_PARAM")),
      (Exc  => CORBA.No_Memory'Identity,
       Name => new String'("NO_MEMORY")),
      (Exc  => CORBA.Imp_Limit'Identity,
       Name => new String'("IMP_LIMIT")),
      (Exc  => CORBA.Comm_Failure'Identity,
       Name => new String'("COMM_FAILURE")),
      (Exc  => CORBA.Inv_Objref'Identity,
       Name => new String'("INV_OBJREF")),
      (Exc  => CORBA.No_Permission'Identity,
       Name => new String'("NO_PERMISSION")),
      (Exc  => CORBA.Internal'Identity,
       Name => new String'("INTERNAL")),
      (Exc  => CORBA.Marshal'Identity,
       Name => new String'("MARSHAL")),
      (Exc  => CORBA.Initialization_Failure'Identity,
       Name => new String'("INITIALIZATION_FAILURE")),
      (Exc  => CORBA.No_Implement'Identity,
       Name => new String'("NO_IMPLEMENT")),
      (Exc  => CORBA.Bad_Typecode'Identity,
       Name => new String'("BAD_TYPECODE")),
      (Exc  => CORBA.Bad_Operation'Identity,
       Name => new String'("BAD_OPERATION")),
      (Exc  => CORBA.No_Resources'Identity,
       Name => new String'("NO_RESOURCES")),
      (Exc  => CORBA.No_Response'Identity,
       Name => new String'("NO_RESPONSE")),
      (Exc  => CORBA.Persist_Store'Identity,
       Name => new String'("PERSIST_STORE")),
      (Exc  => CORBA.Bad_Inv_Order'Identity,
       Name => new String'("BAD_INV_ORDER")),
      (Exc  => CORBA.Transient'Identity,
       Name => new String'("TRANSIENT")),
      (Exc  => CORBA.Free_Mem'Identity,
       Name => new String'("FREE_MEM")),
      (Exc  => CORBA.Inv_Ident'Identity,
       Name => new String'("INV_IDENT")),
      (Exc  => CORBA.Inv_Flag'Identity,
       Name => new String'("INV_FLAG")),
      (Exc  => CORBA.Intf_Repos'Identity,
       Name => new String'("INTF_REPOS")),
      (Exc  => CORBA.Bad_Context'Identity,
       Name => new String'("BAD_CONTEXT")),
      (Exc  => CORBA.Obj_Adapter'Identity,
       Name => new String'("OBJ_ADAPTER")),
      (Exc  => CORBA.Data_Conversion'Identity,
       Name => new String'("DATA_CONVERSION")),
      (Exc  => CORBA.Object_Not_Exist'Identity,
       Name => new String'("OBJECT_NOT_EXIST")),
      (Exc  => CORBA.Transaction_Required'Identity,
       Name => new String'("TRANSACTION_REQUIRED")),
      (Exc  => CORBA.Transaction_Rolledback'Identity,
       Name => new String'("TRANSACTION_ROLLEDBACK")),
      (Exc  => CORBA.Invalid_Transaction'Identity,
       Name => new String'("INVALID_TRANSACTION")));


   ------------------------------------------------------------
   -- conversion between Unsigned_Long and Completion_Status --
   ------------------------------------------------------------

   To_Unsigned_Long :
     constant array (Completion_Status) of CORBA.Unsigned_Long
     := (Completed_Yes => 0, Completed_No => 1, Completed_Maybe => 2);

   To_Completion_Status :
     constant array (CORBA.Unsigned_Long range 0 .. 2) of Completion_Status
     := (0 => Completed_Yes, 1 => Completed_No, 2 => Completed_Maybe);


   -----------------------
   --  User_Get_Members --
   -----------------------
   --  Extract members from an exception occurence.
   procedure User_Get_Members
     (Occurrence : CORBA.Exception_Occurrence;
      Members : out CORBA.IDL_Exception_Members'Class)
     renames Broca.Exceptions.Stack.Get_Members;



   ---------------------------
   --  User_Raise_Exception --
   ---------------------------
   procedure User_Raise_Exception
     (Id : Ada.Exceptions.Exception_Id;
      Members : IDL_Exception_Members'Class)
     renames Broca.Exceptions.Stack.Raise_Exception;

   --------------------------------
   -- System exception handling  --
   --------------------------------

   ----------------------
   --  Raise_Exception --
   ----------------------
   --  Raises the corresponding exception CORBA exception and stores its
   --  member so that it can be retrieved with Get_Members
   procedure Raise_Exception
     (Excp : in Exception_Id; Excp_Memb : in System_Exception_Members);
   pragma No_Return (Raise_Exception);

   procedure Raise_Exception
     (Excp : in Exception_Id; Excp_Memb : in System_Exception_Members)
   is
      Str : String (1 .. 5);
      Val : CORBA.Unsigned_Long;
   begin
      --  Marshall Minor and Completed fields of EXCP_MEMB into a string.
      --  A trivial marshalling is used:
      --  str(1 .. 4) contains the minor, in big endian byte order.
      --  str(5) contains the completed.
      Str (5) := Character'Val (Completion_Status'Pos (Excp_Memb.Completed));
      Val := Excp_Memb.Minor;
      for I in 1 .. 4 loop
         Str (I) := Character'Val (Val / 2 ** 24);
         Val := (Val mod 2 ** 24) * 256;
      end loop;

      --  Raise the exception.
      Ada.Exceptions.Raise_Exception (Excp, Str);

      --  Huh, excp can't be null_id.
      raise Program_Error;
   end Raise_Exception;


   ------------------
   --  Get_Members --
   ------------------
   procedure Get_Members
     (From : in CORBA.Exception_Occurrence;
      To   : out System_Exception_Members)
   is
      Str : String := Ada.Exceptions.Exception_Message (From);
      Val : Unsigned_Long;
   begin
      --  Check length.
      if Str'Length /= 5 then
         Raise_Bad_Param;
      end if;

      --  Unmarshall completion status.
      --  This can raise constraint_error.
      To.Completed := Completion_Status'Val (Character'Pos (Str (Str'Last)));

      --  Unmarshall minor.
      Val := 0;
      for I in Str'First .. Str'Last - 1 loop
         Val := Val * 256 + Character'Pos (Str (I));
      end loop;
      To.Minor := Val;
   exception
      when Constraint_Error =>
         Raise_Bad_Param;
   end Get_Members;



   -------------------------------------------------------
   -- Useful methods to raise standard CORBA exceptions --
   -------------------------------------------------------

   --  Raise CORBA.bad_param with minor = 0 and completed = Completed_No.
   procedure Raise_Bad_Param (Minor : CORBA.Unsigned_Long := 0;
                              Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Bad_Param'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Bad_Param;

   --  Raise CORBA.marshal with minor = 0 and completed = Completed_No.
   procedure Raise_Marshal (Minor : CORBA.Unsigned_Long := 0;
                            Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Marshal'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Marshal;

   --  Raise CORBA.comm_failure with minor = 0 and completed = Completed_No.
   procedure Raise_Comm_Failure (Minor : CORBA.Unsigned_Long := 0;
                                 Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Comm_Failure'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Comm_Failure;

   --  Raise CORBA.inv_objref with minor = 0 and completed = Completed_No.
   procedure Raise_Inv_Objref (Minor : CORBA.Unsigned_Long := 0;
                               Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Inv_Objref'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Inv_Objref;

   procedure Raise_Object_Not_Exist
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Object_Not_Exist'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Object_Not_Exist;

   procedure Raise_Bad_Operation
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Bad_Operation'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Bad_Operation;

   procedure Raise_Transient
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Transient'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Transient;

   procedure Raise_Internal
     (Minor : Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Internal'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Internal;

   procedure Raise_Obj_Adapter
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Obj_Adapter'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Obj_Adapter;

   procedure Raise_No_Implement
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (No_Implement'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_No_Implement;

   ----------------------
   --  Raise_Imp_Limit --
   ----------------------
   procedure Raise_Imp_Limit (Minor : Unsigned_Long := 0;
                              Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception (Imp_Limit'Identity,
                       System_Exception_Members'(Minor => Minor,
                                                 Completed => Status));
   end Raise_Imp_Limit;

   procedure Raise_Bad_Inv_Order
     (Minor : CORBA.Unsigned_Long := 0;
      Status : Completion_Status := Completed_No) is
   begin
      Raise_Exception
        (Bad_Inv_Order'Identity,
         System_Exception_Members'(Minor => Minor, Completed => Status));
   end Raise_Bad_Inv_Order;




   -----------------------------------------------------------------------

   function Occurrence_To_Name (Occurrence : CORBA.Exception_Occurrence)
                                return CORBA.RepositoryId;

   --  System exceptions.
   --  Same as CORBA.To_CORBA_String, but redefined to avoid circular
   --  elaboration.
   function To_RepositoryId (S : in Standard.String) return CORBA.RepositoryId;

   function To_RepositoryId (S : in Standard.String)
                             return CORBA.RepositoryId is
   begin
      return
        CORBA.RepositoryId (Ada.Strings.Unbounded.To_Unbounded_String (S));
   end To_RepositoryId;

   function Occurrence_To_Name
     (Occurrence : CORBA.Exception_Occurrence)
     return CORBA.RepositoryId
   is
      use Ada.Exceptions;
      Id : constant Exception_Id := Exception_Identity (Occurrence);
   begin
      for I in Mapping'Range loop
         if Id = Mapping (I) .Exc then
            return To_RepositoryId (OMG_RepositoryId (Mapping (I) .Name.all));
         end if;
      end loop;
      raise Program_Error;
   end Occurrence_To_Name;

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (Buffer : access Buffer_Type;
      Excpt  : in CORBA.Exception_Occurrence)
   is
      use Broca.CDR;
      Members : System_Exception_Members;
   begin
      Get_Members (Excpt, Members);
      Marshall (Buffer, CORBA.String (Occurrence_To_Name (Excpt)));
      Marshall (Buffer, Members.Minor);
      Marshall (Buffer, To_Unsigned_Long (Members.Completed));
   end Marshall;

   procedure Unmarshall_And_Raise (Buffer : access Buffer_Type) is
      use Broca.CDR;
      use Ada.Exceptions;
      Minor      : CORBA.Unsigned_Long;
      Status     : CORBA.Unsigned_Long;
      Identity   : Exception_Id;
      Repository : CORBA.String;
   begin
      Repository := Unmarshall (Buffer);
      declare
         R : constant String  := To_Standard_String (Repository);
      begin
         Identity := Null_Id;
         for I in Mapping'Range loop
            if R = OMG_RepositoryId (Mapping (I) .Name.all) then
               Identity := Mapping (I) .Exc;
               exit;
            end if;
         end loop;
      end;

      if Identity = Null_Id then
         --  If not found, this is a marshal error.
         Identity := CORBA.Marshal'Identity;
         Minor := 0;
         Status := Completion_Status'Pos (Completed_Maybe);
      end if;

      Minor := Unmarshall (Buffer);
      Status := Unmarshall (Buffer);

      --  Raise the exception.
      Raise_Exception
        (Identity,
         System_Exception_Members'(Minor, To_Completion_Status (Status)));
   end Unmarshall_And_Raise;


end Broca.Exceptions;
