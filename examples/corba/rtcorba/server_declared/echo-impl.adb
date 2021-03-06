------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                            E C H O . I M P L                             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2002-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Dynamic_Priorities;
with Ada.Text_IO;

with Echo.Skel;
pragma Warnings (Off, Echo.Skel);
--  No entity from Echo.Skel is referenced.

with RTCORBA.PriorityMapping;
with PolyORB.RTCORBA_P.Setup;
with PolyORB.Utils.Report;

with System;

package body Echo.Impl is

   ----------------
   -- EchoString --
   ----------------

   function EchoString
     (Self : access Object;
      Mesg : CORBA.String)
     return CORBA.String
   is
      use Ada.Dynamic_Priorities;
      use Ada.Text_IO;
      use RTCORBA;

      Ada_Priority : constant System.Any_Priority := Get_Priority;
      Rounded_Priority : RTCORBA.NativePriority;
      CORBA_Priority : RTCORBA.Priority;
      Ok : Boolean;

   begin
      RTCORBA.PriorityMapping.To_CORBA
        (PolyORB.RTCORBA_P.Setup.Get_Priority_Mapping.all,
         RTCORBA.NativePriority (Ada_Priority),
         CORBA_Priority,
         Ok);

      if not Ok then
         raise Program_Error;
      end if;

      RTCORBA.PriorityMapping.To_Native
        (PolyORB.RTCORBA_P.Setup.Get_Priority_Mapping.all,
         Self.Priority,
         Rounded_Priority,
         Ok);

      if not Ok then
         raise Program_Error;
      end if;

      Put_Line ("In echo servant, running thread at "
                & "Ada native priority"
                & System.Any_Priority'Image (Ada_Priority)
                & ", CORBA priority (approximation)"
                & RTCORBA.Priority'Image (CORBA_Priority));

      --  Test wether execution priority matches setup priority

      PolyORB.Utils.Report.Output
        ("Execution priority conformant with set up priority",
         Rounded_Priority = RTCORBA.NativePriority (Ada_Priority));

      if Rounded_Priority /= RTCORBA.NativePriority (Ada_Priority) then
         CORBA.Raise_Internal
           (CORBA.System_Exception_Members'(Minor     => 0,
                                            Completed => CORBA.Completed_No));
      end if;

      return Mesg;
   end EchoString;

   -------------
   -- Echoers --
   -------------

   function Echoers (Self : access Object) return Objects is
      pragma Unreferenced (Self);

   begin
      return Echo_Objects;
   end Echoers;
end Echo.Impl;
