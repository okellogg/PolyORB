------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                         C O R B A . O B J E C T                          --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2005 Free Software Foundation, Inc.           --
--                                                                          --
-- This specification is derived from the CORBA Specification, and adapted  --
-- for use with PolyORB. The copyright notice above, and the license        --
-- provisions that follow apply solely to the contents neither explicitely  --
-- nor implicitely specified by the CORBA Specification defined by the OMG. --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
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
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Objects;
with PolyORB.References;

with CORBA.AbstractBase;
with CORBA.Context;
with CORBA.ContextList;
with CORBA.ExceptionList;
with CORBA.NVList;
with CORBA.Request;

package CORBA.Object is

   type Ref is new CORBA.AbstractBase.Ref with private;

   function Get_Interface
     (Self : in Ref)
     return CORBA.Object.Ref'Class;

   function Is_Nil  (Self : in Ref) return CORBA.Boolean;
   function Is_Null (Self : in Ref) return CORBA.Boolean
     renames Is_Nil;

   procedure Duplicate (Self : in out Ref);

   procedure Release (Self : in out Ref);

   function Is_A
     (Self            : in Ref;
      Logical_Type_Id : in Standard.String)
     return CORBA.Boolean;

   function Non_Existent (Self : Ref) return CORBA.Boolean;

   function Is_Equivalent
     (Self         : Ref;
      Other_Object : Ref'Class) return Boolean;

   procedure Create_Request
     (Self      : in     Ref;
      Ctx       : in     CORBA.Context.Ref;
      Operation : in     Identifier;
      Arg_List  : in     CORBA.NVList.Ref;
      Result    : in out NamedValue;
      Request   :    out CORBA.Request.Object;
      Req_Flags : in     Flags);
   --  Implementation Note: the CORBA specifications define one
   --  possible value for Req_Flags: CORBA::OUT_LIST_MEMORY, which is
   --  currently not supported. The only possible value for
   --  Req_Flags is 0, all other values will be ignored for now.

   procedure Create_Request
     (Self      : in     Ref;
      Ctx       : in     CORBA.Context.Ref;
      Operation : in     Identifier;
      Arg_List  : in     CORBA.NVList.Ref;
      Result    : in out NamedValue;
      Exc_List  : in     ExceptionList.Ref;
      Ctxt_List : in     ContextList.Ref;
      Request   :    out CORBA.Request.Object;
      Req_Flags : in     Flags);
   --  Implementation Notes:
   --  #1: see above
   --
   --  #2: this procedure implements the recommendation detailed in
   --  the OMG issue #3706, that add new primitives to
   --  CORBA::Object. It adds the Exc_List and Ctxt_List parameters,
   --  to provide more control on the request created.

   function Hash
     (Self    : Ref;
      Maximum : CORBA.Unsigned_Long)
     return CORBA.Unsigned_Long;

   --  Implementation Note: The following policy management related
   --  Object operations were moved into child package
   --  CORBA.Object.Policies to avoid circular dependency.
   --
   --     function Get_Policy
   --       (Self        : in Ref;
   --        Policy_Type : in PolicyType)
   --       return CORBA.Policy.Ref;

   --     function Get_Domain_Managers
   --       (Self : Ref)
   --       return CORBA.DomainManager.DomainManagerList;

   --     procedure Set_Policy_Overrides
   --       (Self     : in Ref;
   --        Policies : in CORBA.Policy.PolicyList;
   --        Set_Add  : in SetOverrideType);

   --     function Get_Client_Policy
   --       (Self     : in Ref;
   --        The_Type : in PolicyType)
   --       return CORBA.Policy.Ref;

   --     function Get_Policy_Overrides
   --       (Self  : in Ref;
   --        Types : in CORBA.Policy.PolicyTypeSeq)
   --       return CORBA.Policy.PolicyList;

   --     procedure Validate_Connection
   --       (Self                  : in     Ref;
   --        Inconsistent_Policies :    out CORBA.Policy.PolicyList;
   --        Result                :    out Boolean);

   function TC_Object return CORBA.TypeCode.Object;

   function  Object_To_String
     (Obj : in CORBA.Object.Ref'Class)
     return CORBA.String;

   package Internals is

      --  Implementation Note: This package defines internal subprograms
      --  specific to PolyORB. You must not use them.

      function To_PolyORB_Object
        (R : in Ref)
        return PolyORB.Objects.Object_Id;
      --  XXX What is this supposed to do?
      --   It is not possible in general to associate a PolyORB Object_Id
      --   with a CORBA.Object.Ref. This can be done only when R designates
      --   an object located on this middleware instance.

      function To_PolyORB_Ref (R : in Ref)
                              return PolyORB.References.Ref;
      procedure Convert_To_CORBA_Ref
        (Neutral_Ref : in     PolyORB.References.Ref;
         CORBA_Ref   : in out CORBA.Object.Ref'Class);
      --  Conversion functions between CORBA and neutral references.

   end Internals;

private

   type Ref is new CORBA.AbstractBase.Ref with null record;

   pragma Inline (Object_To_String);

end CORBA.Object;
