------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--             R T C O R B A . T H R E A D P O O L P O L I C Y              --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2003-2004 Free Software Foundation, Inc.           --
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

--  $Id$

with PolyORB.CORBA_P.POA_Config;
with PolyORB.CORBA_P.Policy;
with PolyORB.CORBA_P.Policy_Management;

with PolyORB.Initialization;
pragma Elaborate_All (PolyORB.Initialization); --  WAG:3.15

with PolyORB.Lanes;
with PolyORB.POA_Policies;
with PolyORB.RTCORBA_P.ThreadPoolManager;
with PolyORB.RT_POA_Policies.Thread_Pool_Policy;
with PolyORB.Smart_Pointers;
with PolyORB.Utils.Strings;

package body RTCORBA.ThreadpoolPolicy is

   use CORBA;
   use CORBA.Policy;
   use CORBA.TypeCode;

   use PolyORB.CORBA_P.Policy;
   use PolyORB.CORBA_P.Policy_Management;

   function Create_ThreadpoolPolicy
     (The_Type : in CORBA.PolicyType;
      Value    : in CORBA.Any)
     return CORBA.Policy.Ref;

   ------------
   -- To_Ref --
   ------------

   function To_Ref (The_Ref : in CORBA.Object.Ref'Class) return Ref is
      use type CORBA.PolicyType;

   begin
      if The_Ref not in CORBA.Policy.Ref'Class
        or else Get_Policy_Type (CORBA.Policy.Ref (The_Ref))
        /= THREADPOOL_POLICY_TYPE
      then
         CORBA.Raise_Bad_Param (CORBA.Default_Sys_Member);
      end if;

      declare
         Entity : constant PolyORB.Smart_Pointers.Entity_Ptr
           := new Policy_Object_Type;

         Result : Ref;
      begin
         Set_Policy_Type (Policy_Object_Type (Entity.all),
                          THREADPOOL_POLICY_TYPE);

         Set_Policy_Value (Policy_Object_Type (Entity.all),
                           Get_Policy_Value
                           (Policy_Object_Type
                            (Entity_Of
                             (CORBA.Policy.Ref (The_Ref)).all)));

         CORBA.Policy.Set (CORBA.Policy.Ref (Result), Entity);

         return Result;
      end;
   end To_Ref;

   -----------------------------
   -- Create_ThreadpoolPolicy --
   -----------------------------

   function Create_ThreadpoolPolicy
     (The_Type : in CORBA.PolicyType;
      Value    : in CORBA.Any)
     return CORBA.Policy.Ref
   is
   begin
      pragma Assert (The_Type = THREADPOOL_POLICY_TYPE);

      if Get_Type (Value) /= TC_Unsigned_Long then
         Raise_PolicyError ((Reason => BAD_POLICY_TYPE));
      end if;

      declare
         Result : CORBA.Policy.Ref;
         Entity : constant PolyORB.Smart_Pointers.Entity_Ptr
           := new Policy_Object_Type;

      begin
         Set_Policy_Type (Policy_Object_Type (Entity.all), The_Type);
         Set_Policy_Value (Policy_Object_Type (Entity.all), Value);

         CORBA.Policy.Set (Result, Entity);

         return Result;
      end;
   end Create_ThreadpoolPolicy;

   --------------------
   -- Get_Threadpool --
   --------------------

   function Get_Threadpool (Self : in Ref) return RTCORBA.ThreadpoolId is
   begin
      return From_Any (Get_Policy_Value
                       (Policy_Object_Type
                        (Entity_Of
                         (CORBA.Policy.Ref (Self)).all)));
   end Get_Threadpool;

   ----------------------------------
   -- Thread_Pool_Policy_Allocator --
   ----------------------------------

   function Thread_Pool_Policy_Allocator
     (Self : in CORBA.Policy.Ref)
     return PolyORB.POA_Policies.Policy_Access;

   function Thread_Pool_Policy_Allocator
     (Self : in CORBA.Policy.Ref)
     return PolyORB.POA_Policies.Policy_Access
   is
      use PolyORB.RT_POA_Policies.Thread_Pool_Policy;
      use PolyORB.RTCORBA_P.ThreadPoolManager;

      Lanes : constant PolyORB.Lanes.Lane_Root_Access
        := Lane (Get_Threadpool (To_Ref (Self)));

   begin
      return Create (Lanes);
   end Thread_Pool_Policy_Allocator;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize;

   procedure Initialize is
   begin
      PolyORB.CORBA_P.POA_Config.Register
        (THREADPOOL_POLICY_TYPE,
         Thread_Pool_Policy_Allocator'Access);

      Register
        (The_Type       => THREADPOOL_POLICY_TYPE,
         POA_Level      => True,
         Factory        => Create_ThreadpoolPolicy'Access,
         System_Default =>
           Create_ThreadpoolPolicy (THREADPOOL_POLICY_TYPE,
                                    To_Any (CORBA.Unsigned_Long (0))));
   end Initialize;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"rtcorba-threadpoolpolicy",
       Conflicts => Empty,
       Depends   => +"rt_poa",
       Provides  => Empty,
       Implicit  => False,
       Init      => Initialize'Access));
end RTCORBA.ThreadpoolPolicy;
