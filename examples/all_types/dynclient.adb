------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                               C L I E N T                                --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $LastChangedRevision$
--                                                                          --
--            Copyright (C) 1999 ENST Paris University, France.             --
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
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

--  all_types dynamic client.

with Ada.Command_Line;
with Ada.Text_IO;

with CORBA; use CORBA;
with CORBA.Object;
with CORBA.Object.Helper;
with CORBA.Context;
with CORBA.Request;
with CORBA.NVList;
with CORBA.ContextList;
with CORBA.ExceptionList;
with CORBA.ORB;

with Report;    use Report;

with all_types; use all_types;
with all_types.Helper;

with PolyORB.CORBA_P.Naming_Tools;
use PolyORB.CORBA_P.Naming_Tools;

with PolyORB.Setup.CORBA_Client;
pragma Warnings (Off, PolyORB.Setup.CORBA_Client);

procedure DynClient is

   pragma Warnings (Off);

   Myall_Types : CORBA.Object.Ref;
   One_Shot : Boolean := Ada.Command_Line.Argument_Count /= 2
     or else Boolean'Value (Ada.Command_Line.Argument (2));

   function EchoBoolean
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Boolean)
     return CORBA.Boolean is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoBoolean");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Arg_List : CORBA.NVList.Ref;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
      Result : CORBA.NamedValue;
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             To_Any (Arg),
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Boolean),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoBoolean;

   function EchoShort
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Short)
     return CORBA.Short is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoShort");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Short),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoShort;

   function EchoLong
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Long)
     return CORBA.Long is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoLong");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Long),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoLong;

   function EchoUShort
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Unsigned_Short)
     return CORBA.Unsigned_Short is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoUShort");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Unsigned_Short),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoUShort;

   function EchoULong
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Unsigned_Long)
     return CORBA.Unsigned_Long is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoULong");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Unsigned_Long),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoULong;

   function EchoFloat
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Float)
     return CORBA.Float is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoFloat");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Float),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoFloat;

   function EchoDouble
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Double)
     return CORBA.Double is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoDouble");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Double),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoDouble;

   function EchoChar
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Char)
     return CORBA.Char is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoChar");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Char),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoChar;

   function EchoOctet
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Octet)
     return CORBA.Octet is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoOctet");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Octet),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoOctet;

   function EchoString
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.String)
      return CORBA.String is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoString");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_String),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end EchoString;

   function EchoRef
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Object.Ref)
      return CORBA.Object.Ref is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoRef");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.Object.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any
                 (CORBA.Object.Helper.TC_Object),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return CORBA.Object.Helper.From_Any
        (Result.Argument);
   end EchoRef;

   function EchoColor
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Color)
      return all_types.Color is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoColor");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => CORBA.Get_Empty_Any (all_types.Helper.TC_Color),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoColor;

   function EchoMoney
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Money)
      return all_types.Money is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoMoney");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => CORBA.Get_Empty_Any (all_types.Helper.TC_Money),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoMoney;

   function EchoArray
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Simple_Array)
     return all_types.Simple_Array is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoArray");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Simple_Array),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoArray;

   function EchoMatrix
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Matrix)
     return all_types.Matrix is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoMatrix");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Matrix),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoMatrix;

   function EchoBigMatrix
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.BigMatrix)
     return all_types.BigMatrix is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoBigMatrix");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_BigMatrix),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoBigMatrix;

   function EchoStruct
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Simple_Struct)
      return all_types.Simple_Struct is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoStruct");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Simple_Struct),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoStruct;

   function EchoArrayStruct
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Array_Struct)
      return all_types.Array_Struct is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoArrayStruct");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Array_Struct),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoArrayStruct;

   function EchoUnion
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.myUnion)
      return all_types.myUnion is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoUnion");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Myunion),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoUnion;

   function EchoUnionEnumSwitch
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.myUnionEnumSwitch)
      return all_types.myUnionEnumSwitch is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoUnionEnumSwitch");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_MyunionEnumSwitch),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoUnionEnumSwitch;

   function EchoUsequence
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.U_sequence)
      return all_types.U_sequence is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoUsequence");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_U_Sequence),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoUsequence;

   function EchoBsequence
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.B_sequence)
      return all_types.B_sequence is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("echoBsequence");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_B_Sequence),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end EchoBsequence;

   procedure Set_MyColor
     (Self : in CORBA.Object.Ref;
      Arg : in all_types.Color) is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("_set_myColor");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := all_types.Helper.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Void),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
   end Set_MyColor;

   function Get_MyColor (Self : in CORBA.Object.Ref)
      return all_types.Color is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("_get_myColor");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (all_types.Helper.TC_Color),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return all_types.Helper.From_Any
        (Result.Argument);
   end Get_MyColor;

   function Get_Counter (Self : in CORBA.Object.Ref)
      return CORBA.Long is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("_get_Counter");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Arg_List : CORBA.NVList.Ref;
      Result : CORBA.NamedValue;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Long),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
      --  getting the answer
      return From_Any (Result.Argument);
   end Get_Counter;

   procedure TestException
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Long) is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("testException");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Excp_List : CORBA.ExceptionList.Ref;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
      Result : CORBA.NamedValue;
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  creating the exception list
      CORBA.ORB.Create_List (Excp_List);
      CORBA.ExceptionList.Add (Excp_List,
                               all_types.Helper.TC_My_Exception);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Void),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Excp_List,
                                   CORBA.ContextList.Nil_Ref,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
   end TestException;

   procedure TestUnknownException
     (Self : in CORBA.Object.Ref;
      Arg : in CORBA.Long) is
      Operation_Name : CORBA.Identifier := To_CORBA_String ("testUnknownException");
      Arg_Name : CORBA.Identifier := To_CORBA_String ("arg");
      Request : CORBA.Request.Object;
      Ctx : CORBA.Context.Ref := CORBA.Context.Nil_Ref;
      Argument : CORBA.Any;
      Arg_List : CORBA.NVList.Ref;
      Excp_List : CORBA.ExceptionList.Ref;
      Result_Name : CORBA.String := To_CORBA_String ("Result");
      Result : CORBA.NamedValue;
   begin
      --  creating the argument list
      CORBA.ORB.Create_List (0, Arg_List);
      Argument := CORBA.To_Any (Arg);
      CORBA.NVList.Add_Item (Arg_List,
                             Arg_Name,
                             Argument,
                             CORBA.ARG_IN);
      --  creating the exception list
      CORBA.ORB.Create_List (Excp_List);
      CORBA.ExceptionList.Add (Excp_List,
                               all_types.Helper.TC_My_Exception);
      --  setting the result type
      Result := (Name => Identifier (Result_Name),
                 Argument => Get_Empty_Any (CORBA.TC_Void),
                 Arg_Modes => 0);
      --  creating a request
      CORBA.Object.Create_Request (Myall_Types,
                                   Ctx,
                                   Operation_Name,
                                   Arg_List,
                                   Result,
                                   Excp_List,
                                   CORBA.ContextList.Nil_Ref,
                                   Request,
                                   0);
      --  sending message
      CORBA.Request.Invoke (Request, 0);
   end TestUnknownException;

begin
   CORBA.ORB.Initialize ("ORB");
   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line
         ("usage : client <IOR_string_from_server|name|-i> [oneshot]");
      return;
   end if;

   if Ada.Command_Line.Argument (1) = "-i" then
      Myall_types := Locate ("all_types");
   else
      Myall_types := Locate (Ada.Command_Line.Argument (1));
   end if;

   loop
      --  boolean
      Output ("test boolean", echoBoolean (Myall_types, True) = True);

      --  short
      Output ("test short", echoShort (Myall_types, 123) = 123);

      --  long
      Output ("test long",  echoLong (Myall_types, 456) = 456);

      --  unsigned_short
      Output ("test unsigned_short", echoUShort (Myall_types, 456) = 456);

      --  unsigned_long
      Output ("test unsigned_long", echoULong (Myall_types, 123) = 123);

      --  float
      Output ("test float", echoFloat (Myall_types, 2.7) = 2.7);

      --  double
      Output ("test double", echoDouble (Myall_types, 3.14) = 3.14);

      --  char
      Output ("test char", echoChar (Myall_types, 'A') = 'A');

      --  octet
      Output ("test octet", echoOctet (Myall_types, 5) = 5);

      --  string
      Output ("test string",
              To_Standard_String
              (echoString (Myall_types, To_CORBA_String ("hello"))) = "hello");

      --  CORBA.Object.Ref
      declare
         X : CORBA.Object.Ref;
      begin
         X := echoRef (Myall_types, Myall_types);
         Output ("test self reference", echoLong (X, 31337) = 31337);
      end;

      --  enum
      Output ("test enum", echoColor (Myall_types, all_types.Blue) =
              all_types.Blue);

      --  fixed
      Output ("test fixed point",
              echoMoney (Myall_Types, 6423.50) = 6423.50
              and then echoMoney (Myall_Types, 0.0) = 0.0
        and then echoMoney (Myall_Types, 3.14) = 3.14);

      --  array
      declare
         X : all_types.simple_array := (2, 3, 5, 7, 11);
      begin
         Output ("test simple array", echoArray (Myall_types, X) = X);
      end;
      declare
         M : all_types.Matrix := ((165, 252, 375), (377, 145, 222), (202, 477, 147));
      begin
         Output ("test multi-dimensional array",
                 echoMatrix (Myall_types, M) = M);
      end;

      --  struct
      declare
         Test_Struct : constant all_types.simple_struct
           := (123, To_CORBA_String ("Hello world!"));
      begin
         Output ("test struct",
                 echoStruct (Myall_types, Test_Struct) = Test_Struct);
      end;
      declare
         Test_Struct : constant array_struct
           :=  (A => (0,1,2,3,4,5,6,7,8,9), B => 65533);
      begin
         Output ("test array struct",
                 echoArrayStruct (Myall_types, Test_Struct) = Test_Struct);
      end;

      --  union
      declare
         Test_Unions : constant array (0 .. 3) of myUnion
           := ((Switch => 0, Unknown => 987),
               (Switch => 1, Counter => 1212),
               (Switch => 2, Flag => True),
               (Switch => 3, Hue => Green));
         Pass : Boolean := True;
      begin
         for I in Test_Unions'Range loop
            Pass := Pass and then echoUnion (Myall_types, Test_Unions (I))
              = Test_Unions (I);
            exit when not Pass;
         end loop;
         Output ("test union", Pass);
      end;
      declare
         Test_Unions : constant array (Integer range <>) of myUnionEnumSwitch
           := ((Switch => Red, Foo => 31337),
               (Switch => Green, Bar => 534),
               (Switch => Blue, Baz => CORBA.To_CORBA_String ("gr�mpf")));
         Pass : Boolean := True;
      begin
         for I in Test_Unions'Range loop
            Pass := Pass and then echoUnionEnumSwitch (Myall_types, Test_Unions (I))
              = Test_Unions (I);
            exit when not Pass;
         end loop;
         Output ("test union with enum switch", Pass);
      end;

      --  Unbounded sequences
      declare
         X : U_Sequence := U_Sequence (IDL_SEQUENCE_Short.Null_Sequence);
      begin
         X := X & 1 & 2 & 3 & 4 & 5;
         Output ("test unbounded sequence",  echoUsequence (Myall_types, X) = X);
      end;

      --  Bounded sequences
      declare
         X : B_Sequence := B_Sequence (IDL_SEQUENCE_Short_10.Null_Sequence);
      begin
         X := X & 1 & 2 & 3 & 4 & 5 & 6;
         Output ("test bounded sequence",  echoBsequence (Myall_types, X) = X);
      end;

      --  Attributes
      Set_MyColor (Myall_types, Green);
      Output ("test attribute", Get_MyColor (Myall_types) = Green);
      declare
         Counter_First_Value : CORBA.Long
           := get_Counter (Myall_types);
         Counter_Second_Value : CORBA.Long
           := get_Counter (Myall_types);
      begin
         Output ("test read-only attribute",
                 Counter_Second_Value = Counter_First_Value + 1);
      end;

      --  Exceptions
      declare
         Ok : Boolean;
      begin
         Ok := False;
         declare
            Member : UnknownUserException_Members;
            Actual_Member : My_Exception_Members;
         begin
            testException (Myall_types, 2485);
         exception
            when E : UnknownUserException =>
               Get_Members (E, Member);
               Actual_Member :=
                 all_types.Helper.From_Any (Member.IDL_Exception);
               Ok := (Actual_Member.Info = 2485);
            when others =>
              null;
         end;
         Output ("test user exception", Ok);
      end;

      declare
         Ok : Boolean;
      begin
         Ok := False;
         declare
            Member : UnknownUserException_Members;
            Actual_Member : My_Exception_Members;
         begin
            testUnknownException (Myall_types, 2485);
         exception
            when CORBA.UNKNOWN =>
               Ok := True;

            when others =>
               null;
         end;
         Output ("test unknown exception", Ok);
      end;

      exit when One_Shot;
   end loop;

end DynClient;
