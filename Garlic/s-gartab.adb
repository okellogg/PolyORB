------------------------------------------------------------------------------
--                                                                          --
--                            GLADE COMPONENTS                              --
--                                                                          --
--                  S Y S T E M . G A R L I C . T A B L E                   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $Revision$                             --
--                                                                          --
--         Copyright (C) 1996,1997 Free Software Foundation, Inc.           --
--                                                                          --
-- GARLIC is free software;  you can redistribute it and/or modify it under --
-- terms of the  GNU General Public License  as published by the Free Soft- --
-- ware Foundation;  either version 2,  or (at your option)  any later ver- --
-- sion.  GARLIC is distributed  in the hope that  it will be  useful,  but --
-- WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHANTABI- --
-- LITY or  FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public  --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License  distributed with GARLIC;  see file COPYING.  If  --
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
--               GLADE  is maintained by ACT Europe.                        --
--               (email: glade-report@act-europe.fr)                        --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with System.Garlic.Utils;      use System.Garlic.Utils;
with System.Garlic.Table;
with System.Garlic.Name_Table; use System.Garlic.Name_Table;

package body System.Garlic.Table is

   -------------
   -- Complex --
   -------------

   package body Complex is

      Min_Pos : constant Integer    := Index_Type'Pos (First_Index);
      Max_Pos :          Integer    := Min_Pos + Initial_Size - 1;

      Min     : constant Index_Type := Index_Type'Val (Min_Pos);
      Max     :          Index_Type := Index_Type'Val (Max_Pos);

      type Usage_Type is record
         Name : Name_Id;
         Free : Boolean;
      end record;
      Null_Usage : constant Usage_Type := (Null_Name, True);

      type Usage_Table_Type   is array (Index_Type range <>) of Usage_Type;
      type Usage_Table_Access is access Usage_Table_Type;

      Usage   : Usage_Table_Access;

      function Allocate (N : Index_Type := Null_Index) return Index_Type;
      --  Allocate a new component. When N /= Null_Index then allocate
      --  N. When this component index is not free, return Null_Index.

      procedure Check (N : Index_Type);
      --  Check whether N is in range of current table. Otherwise,
      --  raise Constraint_Error.

      procedure Free is
        new Ada.Unchecked_Deallocation
        (Component_Table_Type, Component_Table_Access);

      procedure Free is
        new Ada.Unchecked_Deallocation
        (Usage_Table_Type, Usage_Table_Access);

      Local_Mutex : Mutex_Type;
      --  This lock is used to block tasks until the table is
      --  modified. This uses special behaviour of Utils.Mutex_Type.
      --  Basically, Local_Mutex.Leave (Postponed) lets the run-time know
      --  that the mutex has been postponed and that it should be resumed
      --  when a Local_Mutex.Leave (Modified) occurs.

      --  Most of these subprograms are abort deferred. At the beginning of
      --  them, the code enter a critical section. At the end, it leaves
      --  the critical section. To avoid a premature abortion in the middle
      --  of the critical section, the code is protected against abortion.

      --------------
      -- Allocate --
      --------------

      function Allocate (N : Index_Type := Null_Index) return Index_Type is
         Old_Max   : Index_Type;
         Old_Table : Component_Table_Access;
         Old_Usage : Usage_Table_Access;

      begin

         --  Try to allocate N as required.

         if N /= Null_Index then
            if Max < N then
               return Null_Index;
            end if;
            if Usage (N).Free then
               Usage (N).Free := False;
               Table (N)      := Null_Component;
            end if;
            return N;
         end if;

         --  Try to allocate a free one

         for Index in Min .. Max loop
            if Usage (Index).Free then
               Usage (Index).Free := False;
               return Index;
            end if;
         end loop;

         --  Allocate new table

         Old_Max   := Max;
         Old_Table := Table;
         Old_Usage := Usage;

         Max_Pos   := Max_Pos + Increment_Size;
         Max       := Index_Type'Val (Max_Pos);
         Table     := new Component_Table_Type (Min .. Max);
         Usage     := new Usage_Table_Type     (Min .. Max);

         --  Copy old table in new table

         for Index in Min .. Old_Max loop
            Table (Index) := Old_Table (Index);
            Usage (Index) := Old_Usage (Index);
         end loop;

         --  Intialize incremented part of new table

         for Index in Old_Max + 1 .. Max loop
            Table (Index) := Null_Component;
            Usage (Index) := Null_Usage;
         end loop;

         Free (Old_Table);
         Free (Old_Usage);

         Usage (Old_Max + 1).Free := False;

         return Old_Max + 1;
      end Allocate;

      -----------
      -- Apply --
      -----------

      procedure Apply
        (N         : in Index_Type;
         Parameter : in Parameter_Type;
         Process   : in Process_Type) is
         Status    : Status_Type;

      begin
         pragma Abort_Defer;

         Check (N);
         loop
            Local_Mutex.Enter;
            Enter (Global_Mutex);
            Process (N, Parameter, Table (N), Status);
            Leave (Global_Mutex);
            Local_Mutex.Leave (Status);

            --  Loop when the subprogram execution has been postponed

            exit when Status /= Postponed;
         end loop;
      end Apply;

      -----------
      -- Check --
      -----------

      procedure Check (N : Index_Type) is
         Error : Boolean;

      begin
         Enter (Global_Mutex);
         Error := (Allocate (N) = Null_Index);
         Leave (Global_Mutex);

         if Error then
            raise Constraint_Error;
         end if;
      end Check;

      -------------------
      -- Get_Component --
      -------------------

      function Get_Component (N : Index_Type) return Component_Type is
         Component : Component_Type;

      begin
         pragma Abort_Defer;

         Check (N);
         Enter (Global_Mutex);
         Component := Table (N);
         Leave (Global_Mutex);

         return Component;
      end Get_Component;

      ---------------
      -- Get_Index --
      ---------------

      function Get_Index (S : String) return Index_Type is
         Index : Index_Type;
         Name  : Name_Id;
         Info  : Integer;

      begin
         pragma Abort_Defer;

         Enter (Global_Mutex);
         Name  := Get (S);
         Info  := Get_Info (Name);
         if Info = 0 then

            --  Info is a null index. Create new component and set its
            --  index as name info.

            Index := Allocate;
            Table (Index) := Null_Component;
            Usage (Index).Name := Name;
            Set_Info (Name, Integer (Index_Type'Pos (Index)));
         else
            Index := Index_Type'Val (Info);
         end if;
         Leave (Global_Mutex);

         return Index;
      end Get_Index;

      --------------
      -- Get_Name --
      --------------

      function  Get_Name  (N : Index_Type) return String is
         Name : Name_Id;

      begin
         pragma Abort_Defer;

         Enter (Global_Mutex);
         if Max < N or else Usage (N).Free then
            Name := Null_Name;
         else
            Name := Usage (N).Name;
         end if;
         Leave (Global_Mutex);

         return Get (Name);
      end Get_Name;

      -------------------
      -- Set_Component --
      -------------------

      procedure Set_Component (N : Index_Type; C : Component_Type) is
      begin
         pragma Abort_Defer;

         Check (N);
         Enter (Global_Mutex);
         Table (N) := C;
         Leave (Global_Mutex);
      end Set_Component;

      --------------
      -- Set_Name --
      --------------

      procedure Set_Name (N : Index_Type; S : String) is
      begin
         pragma Abort_Defer;

         Check (N);
         Enter (Global_Mutex);
         Usage (N).Name := Get (S);
         Set_Info (Usage (N).Name, Integer (Index_Type'Pos (N)));
         Leave (Global_Mutex);
      end Set_Name;

   begin
      Table := new Component_Table_Type'(Min .. Max => Null_Component);
      Usage := new Usage_Table_Type    '(Min .. Max => Null_Usage);
   end Complex;

   ------------
   -- Simple --
   ------------

   package body Simple is

      Min_Pos : constant Integer := Index_Type'Pos (First_Index);
      Max_Pos :          Integer := Min_Pos + Initial_Size - 1;

      Min     : constant Index_Type := Index_Type'Val (Min_Pos);
      Max     :          Index_Type := Index_Type'Val (Max_Pos);

      procedure Free is
        new Ada.Unchecked_Deallocation
        (Component_Table_Type, Component_Table_Access);

      Last  : Index_Type := Null_Index;

      --------------
      -- Allocate --
      --------------

      function Allocate return Index_Type is
         Old : Component_Table_Access;

      begin
         if Last = Max then
            Max_Pos := Max_Pos + Increment_Size;
            Max     := Index_Type'Val (Max_Pos);
            Old     := Table;
            Table   := new Component_Table_Type (Min .. Max);

            for Index in Min .. Last loop
               Table (Index) := Old (Index);
            end loop;
            for Index in Last + 1 .. Max loop
               Table (Index) := Null_Component;
            end loop;

            Free (Old);
         end if;

         Last := Last + 1;
         return Last;
      end Allocate;

   begin
      Table := new Component_Table_Type'(Min .. Max => Null_Component);
   end Simple;

end System.Garlic.Table;
