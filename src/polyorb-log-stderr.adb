------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                   P O L Y O R B . L O G . S T D E R R                    --
--                                                                          --
--                                 B o d y                                  --
--         Copyright (C) 2004-2005 Free Software Foundation, Inc.           --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 51 Franklin Street, Fifth    --
-- Floor, Boston, MA 02111-1301, USA.                                       --
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

with Interfaces.C;
with System;

with PolyORB.Initialization;
with PolyORB.Utils.Strings;

package body PolyORB.Log.Stderr is

   --------------
   -- Put_Line --
   --------------

   procedure Put_Line (S : String);

   procedure Put_Line (S : String) is
      SS : aliased String := S & ASCII.LF;

      procedure C_Write
        (Fd  : Interfaces.C.int;
         P   : System.Address;
         Len : Interfaces.C.int);
      pragma Import (C, C_Write, "write");

   begin
      C_Write (2, SS (SS'First)'Address, SS'Length);
      --  2 is standard error
   end Put_Line;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize;

   procedure Initialize is
      use type PolyORB.Log.Internals.Log_Hook_T;
   begin
      if PolyORB.Log.Internals.Log_Hook = null then
         PolyORB.Log.Internals.Log_Hook := Put_Line'Access;
      end if;
   end Initialize;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"log.stderr",
       Conflicts => Empty,
       Depends   => +"parameters",
       Provides  => +"log_sink",
       Implicit  => True,
       Init      => Initialize'Access));
end PolyORB.Log.Stderr;
