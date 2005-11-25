------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--          P O R T A B L E I N T E R C E P T O R . I O R I N F O           --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2004 Free Software Foundation, Inc.             --
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
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with PortableInterceptor.IORInfo.Impl;

package body PortableInterceptor.IORInfo is

   -----------------------
   -- Add_IOR_Component --
   -----------------------

   procedure Add_IOR_Component
     (Self        : in Local_Ref;
      A_Component : in IOP.TaggedComponent)
   is
      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
   begin

      if CORBA.Object.Is_Nil (Self_Ref) then
         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
      end if;

      PortableInterceptor.IORInfo.Impl.Add_IOR_Component
        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)),
         A_Component);
   end Add_IOR_Component;

   ----------------------------------
   -- Add_IOR_Component_To_Profile --
   ----------------------------------

   procedure Add_IOR_Component_To_Profile
     (Self        : in Local_Ref;
      A_Component : in IOP.TaggedComponent;
      Profile_Id  : in IOP.ProfileId)
   is
      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
   begin

      if CORBA.Object.Is_Nil (Self_Ref) then
         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
      end if;

      PortableInterceptor.IORInfo.Impl.Add_IOR_Component_To_Profile
        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)),
         A_Component,
         Profile_Id);
   end Add_IOR_Component_To_Profile;

--   --------------------------
--   -- Get_Adapter_Template --
--   --------------------------
--
--   function Get_Adapter_Template
--     (Self : in Local_Ref)
--      return ObjectReferenceTemplate.Abstract_Value_Ref
--   is
--      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
--   begin
--
--      if CORBA.Object.Is_Nil (Self_Ref) then
--         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
--      end if;
--
--      return PortableInterceptor.IORInfo.Impl.Get_Adapter_Template
--        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)));
--   end Get_Adapter_Template;

--   -------------------------
--   -- Get_Current_Factory --
--   -------------------------
--
--   function Get_Current_Factory
--     (Self : in Local_Ref)
--      return ObjectReferenceFactory.Abstract_Value_Ref
--   is
--      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
--   begin
--
--      if CORBA.Object.Is_Nil (Self_Ref) then
--         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
--      end if;
--
--      return PortableInterceptor.IORInfo.Impl.Get_Current_Factory
--        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)));
--   end Get_Current_Factory;

   --------------------------
   -- Get_Effective_Policy --
   --------------------------

   function Get_Effective_Policy
     (Self     : in Local_Ref;
      IDL_Type : in CORBA.PolicyType)
      return CORBA.Policy.Ref
   is
      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
   begin

      if CORBA.Object.Is_Nil (Self_Ref) then
         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
      end if;

      return PortableInterceptor.IORInfo.Impl.Get_Effective_Policy
        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)),
         IDL_Type);
   end Get_Effective_Policy;

   --------------------
   -- Get_Manager_Id --
   --------------------

   function Get_Manager_Id (Self : in Local_Ref) return AdapterManagerId is
      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
   begin

      if CORBA.Object.Is_Nil (Self_Ref) then
         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
      end if;

      return PortableInterceptor.IORInfo.Impl.Get_Manager_Id
        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)));
   end Get_Manager_Id;

   ---------------
   -- Get_State --
   ---------------

   function Get_State (Self : in Local_Ref) return AdapterState is
      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
   begin

      if CORBA.Object.Is_Nil (Self_Ref) then
         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
      end if;

      return PortableInterceptor.IORInfo.Impl.Get_State
        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)));
   end Get_State;

--   -------------------------
--   -- Set_Current_Factory --
--   -------------------------
--
--   procedure Set_Current_Factory
--     (Self : in Local_Ref;
--      To   : in ObjectReferenceFactory.Abstract_Value_Ref)
--   is
--      Self_Ref : CORBA.Object.Ref := CORBA.Object.Ref (Self);
--   begin
--
--      if CORBA.Object.Is_Nil (Self_Ref) then
--         CORBA.Raise_Inv_Objref (CORBA.Default_Sys_Member);
--      end if;
--
--      PortableInterceptor.IORInfo.Impl.Set_Current_Factory
--        (PortableInterceptor.IORInfo.Impl.Object_Ptr (Entity_Of (Self)),
--         To);
--   end Set_Current_Factory;

end PortableInterceptor.IORInfo;
