------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--            P O L Y O R B . U T I L S . S I M P L E _ F L A G S           --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                Copyright (C) 2001 Free Software Fundation                --
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
--              PolyORB is maintained by ENST Paris University.             --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with PolyORB.Log;

package body PolyORB.Utils.Simple_Flags is

   use PolyORB.Log;

   package L is new PolyORB.Log.Facility_Log
     ("polyorb.utils.simple_flags");
--     ("polyorb.utils.simple_flags" & Bit_Count'Image (Bit_Count'Last));
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;

   ----------
   -- Mask --
   ----------

   function Mask
     (N : Bit_Count)
     return Flags_Type
   is
      Temp : Flags_Type := 1;
   begin
      for K in 0 .. (N - 1) loop
         Temp := Temp * 2;
      end loop;
      pragma Debug (O ("Max bit"
                       & Bit_Count'Image (Bit_Count'Last)
                       & "; Mask for "
                       & Bit_Count'Image (N)
                       & " : "
                       & Flags_Type'Image (Temp)));
      return Temp;
   end Mask;

   ------------
   -- Is_Set --
   ------------

   function Is_Set
     (Flag_To_Test : Flags_Type;
      In_Flags     : Flags_Type)
     return Boolean
   is
   begin
      return ((Flag_To_Test and In_Flags) = Flag_To_Test);
   end Is_Set;

   ------------
   -- Is_Set --
   ------------

   function Is_Set
     (N        : Bit_Count;
      In_Flags : Flags_Type)
     return Boolean
   is
      M : constant Flags_Type := Mask (N);
   begin
      return Is_Set (M, In_Flags);
   end Is_Set;

   ---------
   -- Set --
   ---------

   function Set
     (Flag_To_Set : Flags_Type;
      In_Flags    : Flags_Type)
     return Flags_Type
   is
   begin
      return (In_Flags and Flag_To_Set);
   end Set;

   ---------
   -- Set --
   ---------

   function Set
     (N        : Bit_Count;
      In_Flags : Flags_Type)
     return Flags_Type
   is
      M : constant Flags_Type := Mask (N);
   begin
      return Set (M, In_Flags);
   end Set;

   ---------
   -- Set --
   ---------

   procedure Set
     (Flag_Field : in out Flags_Type;
      N          : Bit_Count;
      Value      : Boolean)
   is
      M : constant Flags_Type := Mask (N);
   begin
      if Value then
         Flag_Field := (Flag_Field and (not M)) or M;
      else
         Flag_Field := Flag_Field and (not M);
      end if;
   end Set;

end PolyORB.Utils.Simple_Flags;
