------------------------------------------------------------------------------
--                                                                          --
--                            GLADE COMPONENTS                              --
--                                                                          --
--                  S Y S T E M . G A R L I C . G R O U P                   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $Revision$
--                                                                          --
--         Copyright (C) 1996-1998 Free Software Foundation, Inc.           --
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

with Ada.Streams;              use Ada.Streams;
with System.Garlic.Debug;      use System.Garlic.Debug;
with System.Garlic.Heart;      use System.Garlic.Heart;
with System.Garlic.Partitions; use System.Garlic.Partitions;
with System.Garlic.Streams;    use System.Garlic.Streams;
with System.Garlic.Types;      use System.Garlic.Types;
with System.Garlic.Utils;      use System.Garlic.Utils;

package body System.Garlic.Group is

   package Partitions renames System.Garlic.Partitions.Partitions;

   Private_Debug_Key : constant Debug_Key :=
     Debug_Initialize ("S_GARGRO", "(s-gargro): ");

   procedure D
     (Level   : in Debug_Level;
      Message : in String;
      Key     : in Debug_Key := Private_Debug_Key)
     renames Print_Debug_Info;

   Barrier : Barrier_Access := Create;

   procedure Handle_Request
     (Partition : in Partition_ID;
      Opcode    : in External_Opcode;
      Query     : access Params_Stream_Type;
      Reply     : access Params_Stream_Type);

   function Neighbor (Right : Boolean := True) return Partition_ID;

   ------------------------
   -- Initiate_Broadcast --
   ------------------------

   procedure Broadcast
     (Opcode : in Any_Opcode;
      Params : access Streams.Params_Stream_Type) is
   begin
      Wait (Barrier);
      Insert (Params.all);
      Partition_ID'Write (Params, Self_PID);
      Any_Opcode'Write (Params, Opcode);
      Send (Neighbor, Group_Service, Params);
   end Broadcast;

   --------------------
   -- Handle_Request --
   --------------------

   procedure Handle_Request
     (Partition : in Types.Partition_ID;
      Opcode    : in External_Opcode;
      Query     : access Streams.Params_Stream_Type;
      Reply     : access Streams.Params_Stream_Type)
   is
      Inner_PID   : Partition_ID;
      Inner_Code  : Any_Opcode;
      Inner_Query : aliased Params_Stream_Type (Query.Count);
      Inner_Reply : aliased Params_Stream_Type (0);

      subtype QSEA is Stream_Element_Array (1 .. Query.Count);
      Query_Copy  : aliased Stream_Element_Array
        := QSEA (To_Stream_Element_Array (Query));
   begin
      pragma Debug (D (D_Debug, "Handle broadcast request"));
      Write (Inner_Query, Query_Copy);

      Partition_ID'Read (Inner_Query'Access, Inner_PID);
      Any_Opcode'Read (Inner_Query'Access, Inner_Code);
      Handle_Any_Request
        (Inner_PID, Inner_Code, Inner_Query'Access, Inner_Reply'Access);

      if Inner_PID = Self_PID then
         Signal (Barrier);

      else
         if Empty (Inner_Reply'Access) then
            pragma Debug (D (D_Debug, "Forward same query"));
            Dump (D_Debug, Query_Copy'Access, Private_Debug_Key);
            QSEA'Write (Inner_Reply'Access, QSEA (Query_Copy));

         else
            pragma Debug (D (D_Debug, "Forward new query"));
            Insert (Inner_Reply);
            Partition_ID'Write (Inner_Reply'Access, Inner_PID);
            Any_Opcode'Write (Inner_Reply'Access, Inner_Code);
         end if;

         Send (Neighbor, Group_Service, Inner_Reply'Access);
      end if;

   end Handle_Request;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Register_Handler (Group_Service, Handle_Request'Access);
      Signal (Barrier);
   end Initialize;

   --------------
   -- Neighbor --
   --------------

   function Neighbor (Right : Boolean := True) return Partition_ID
   is
      PID  : Partition_ID := Self_PID;
      Info : Partition_Info;
   begin
      loop
         Next_Partition (PID, Right, True);
         exit when PID = Self_PID;
         Info := Partitions.Get_Component (PID);
         exit when Info.Boot_Ability;
      end loop;
      return PID;
   end Neighbor;

end System.Garlic.Group;
