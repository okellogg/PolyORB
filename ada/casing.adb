------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                               C A S I N G                                --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $Revision$                             --
--                                                                          --
--          Copyright (C) 1992-1997 Free Software Foundation, Inc.          --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with GNAT;  see file COPYING.  If not, write --
-- to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
-- MA 02111-1307, USA.                                                      --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- It is now maintained by Ada Core Technologies Inc (http://www.gnat.com). --
--                                                                          --
------------------------------------------------------------------------------

with Csets;    use Csets;
with Namet;    use Namet;
with Opt;      use Opt;
with Types;    use Types;
with Widechar; use Widechar;

package body Casing is

   ----------------
   -- Set_Casing --
   ----------------

   procedure Set_Casing (C : Casing_Type; D : Casing_Type := Mixed_Case) is
      Ptr : Natural;

      Actual_Casing : Casing_Type;
      --  Set from C or D as appropriate

      After_Und : Boolean := True;
      --  True at start of string, and after an underline character or after
      --  any other special character that is not a normal identifier char).

   begin
      if C /= Unknown then
         Actual_Casing := C;
      else
         Actual_Casing := D;
      end if;

      Ptr := 1;

      while Ptr <= Name_Len loop
         if Name_Buffer (Ptr) = Ascii.ESC
           or else (Upper_Half_Encoding
                     and then Name_Buffer (Ptr) in Upper_Half_Character)
         then
            Skip_Wide (Name_Buffer, Ptr);
            After_Und := False;

         elsif Name_Buffer (Ptr) = '_'
            or else not Identifier_Char (Name_Buffer (Ptr))
         then
            After_Und := True;
            Ptr := Ptr + 1;

         elsif Is_Lower_Case_Letter (Name_Buffer (Ptr)) then
            if Actual_Casing = All_Upper_Case
              or else (After_Und and then Actual_Casing = Mixed_Case)
            then
               Name_Buffer (Ptr) := Fold_Upper (Name_Buffer (Ptr));
            end if;

            After_Und := False;
            Ptr := Ptr + 1;

         elsif Is_Upper_Case_Letter (Name_Buffer (Ptr)) then
            if Actual_Casing = All_Lower_Case
              or else (not After_Und and then Actual_Casing = Mixed_Case)
            then
               Name_Buffer (Ptr) := Fold_Lower (Name_Buffer (Ptr));
            end if;

            After_Und := False;
            Ptr := Ptr + 1;

         else  --  all other characters
            After_Und := False;
            Ptr := Ptr + 1;
         end if;
      end loop;
   end Set_Casing;

   ------------------------
   -- Set_All_Upper_Case --
   ------------------------

   procedure Set_All_Upper_Case is
   begin
      Set_Casing (All_Upper_Case);
   end Set_All_Upper_Case;

end Casing;
