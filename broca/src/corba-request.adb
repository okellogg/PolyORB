------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                       C O R B A . R E Q U E S T                          --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1999-2000 ENST Paris University, France.          --
--                                                                          --
-- AdaBroker is free software; you  can  redistribute  it and/or modify it  --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. AdaBroker  is distributed  in the hope that it will be  useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with AdaBroker; see file COPYING. If  --
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
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Broca.GIOP;
with Broca.Object;
with Broca.CDR;

package body CORBA.Request is

   procedure Add_Arg
     (Self      : in out Object;
      Arg_Type  : in     CORBA.TypeCode.Object;
      Value     : in     System.Address;
      Len       : in     Long;
      Arg_Flags : in     Flags) is
   begin
      null;
   end Add_Arg;

   procedure Add_Arg
     (Self : in out Object;
      Arg  : in     NamedValue) is
   begin
      CORBA.NVList.Add_Item (Self.Args_List, Arg);
   end Add_Arg;

   procedure Invoke
     (Self         : in out Object;
      Invoke_Flags : in     Flags  := 0) is
      Handler : Broca.GIOP.Request_Handler;
      Send_Request_Result : Broca.GIOP.Send_Request_Result_Type;
   begin
      loop
         --  create the request handler
         Broca.GIOP.Send_Request_Marshall
           (Handler,
            Broca.Object.Object_Ptr (CORBA.Object.Get (Self.Target)),
            True,
            Self.Operation);

         --  Marshall in and inout arguments.
         CORBA.NVList.Marshall (Handler.Buffer'Access,
                                Self.Args_List);

         --  send the request
         Broca.GIOP.Send_Request_Send
           (Handler,
            Broca.Object.Object_Ptr (CORBA.Object.Get (Self.Target)),
            True,
            Send_Request_Result);

         case Send_Request_Result is
            when Broca.GIOP.Sr_Reply =>
               --  Unmarshall out args
               CORBA.NVList.Unmarshall (Handler.Buffer'Access,
                                        Self.Args_List);
               --  Unmarshall return value
               Broca.CDR.Unmarshall (Handler.Buffer'Access,
                                     Self.Result);
               Broca.GIOP.Release (Handler);
            when Broca.GIOP.Sr_No_Reply =>
               Broca.GIOP.Release (Handler);
               raise Program_Error;
            when Broca.GIOP.Sr_User_Exception =>
               Broca.GIOP.Release (Handler);
               raise Program_Error;
            when Broca.GIOP.Sr_Forward =>
               null;
         end case;
      end loop;
   end Invoke;

   procedure Delete (Self : in out Object) is
   begin
      null;
   end Delete;

   procedure Send
     (Self         : in out Object;
      Invoke_Flags : in     Flags  := 0) is
   begin
      null;
   end Send;

   procedure Get_Response
     (Self         : in out Object;
      Invoke_Flags : in     Flags  := 0) is
   begin
      null;
   end Get_Response;

   function Poll_Response (Self : in Object) return Boolean is
   begin
      return False;
   end Poll_Response;

end CORBA.Request;
