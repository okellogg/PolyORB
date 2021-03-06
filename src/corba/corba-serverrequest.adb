------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                  C O R B A . S E R V E R R E Q U E S T                   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
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

--  Mapping for the standard ServerRequest interface

with PolyORB.Any.NVList;
with PolyORB.CORBA_P.Exceptions;
with PolyORB.CORBA_P.Interceptors_Hooks;
with PolyORB.Log;
with PolyORB.Errors;

package body CORBA.ServerRequest is

   use PolyORB.CORBA_P.Interceptors_Hooks;
   use PolyORB.Log;

   package L is new PolyORB.Log.Facility_Log ("corba.serverrequest");
   procedure O (Message : Standard.String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;

   ---------------
   -- Operation --
   ---------------

   function Operation (O : Object) return Identifier is
   begin
      return To_CORBA_String (O.Operation.all);
   end Operation;

   ---------------
   -- Arguments --
   ---------------

   procedure Arguments (O : access Object; NV : in out NVList.Ref) is
      use PolyORB.Errors;

      PolyORB_Args : PolyORB.Any.NVList.Ref
        := CORBA.NVList.Internals.To_PolyORB_Ref (NV);
      Error : Error_Container;

   begin
      PolyORB.Requests.Arguments
        (PolyORB.Requests.Request_Access (O), PolyORB_Args, Error);

      if Found (Error) then
         PolyORB.CORBA_P.Exceptions.Raise_From_Error (Error);
      end if;

      NV := CORBA.NVList.Internals.To_CORBA_Ref (PolyORB_Args);

      if Server_Intermediate /= null then
         Server_Intermediate (PolyORB.Requests.Request_Access (O), True);
      end if;
   end Arguments;

   ----------------
   -- Set_Result --
   ----------------

   procedure Set_Result (O : access Object; Val : Any) is
      use PolyORB.Errors;

      Error : Error_Container;

   begin

      --  Need to copy the Any value here, because it may be living on the
      --  caller's stack.

      PolyORB.Requests.Set_Result
        (PolyORB.Requests.Request_Access (O),
         PolyORB.Any.Copy_Any (PolyORB.Any.Any (Val)), Error);

      if Found (Error) then
         PolyORB.CORBA_P.Exceptions.Raise_From_Error (Error);
      end if;
   end Set_Result;

   -------------------
   -- Set_Exception --
   -------------------

   procedure Set_Exception (Obj : access Object; Val : Any) is
      use PolyORB.Any;
      use PolyORB.Any.TypeCode;
   begin
      pragma Debug (C, O ("Server notifies exception: " & Image (Val)));

      if Kind (Get_Type (Val)) /= PolyORB.Any.Tk_Except then
         declare
            use PolyORB.Errors;

            Error : Error_Container;

            Member : constant System_Exception_Members
              := (Minor => 21, Completed => Completed_No);
         begin
            Throw (Error, Bad_Param_E, Member);

            PolyORB.CORBA_P.Exceptions.Raise_From_Error (Error);
         end;
      end if;

      --  Implementation Note: if the Any denotes an unlisted user
      --  exception, the CORBA specifications (8.3.1) manadate that
      --
      --  1. the server receives a BAD_PARAM system exception,
      --  or
      --  2. the client will receive an UNKNOWN exception.
      --
      --  1. cannot be asserted by our implementation, we retained 2.
      --  2. is made on the client side, when the middleware processes
      --  the request.

      Obj.Exception_Info := PolyORB.Any.Any (Val);

      if Server_Intermediate /= null then
         Server_Intermediate (PolyORB.Requests.Request_Access (Obj), False);
      end if;
   end Set_Exception;

end CORBA.ServerRequest;
