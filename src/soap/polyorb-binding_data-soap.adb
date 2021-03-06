------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--            P O L Y O R B . B I N D I N G _ D A T A . S O A P             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2013, Free Software Foundation, Inc.          --
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

pragma Ada_2012;

--  Binding data concrete implementation for SOAP over HTTP.

with Ada.Streams;

with PolyORB.Binding_Objects;
with PolyORB.Buffers;
with PolyORB.Errors;
with PolyORB.Filters.HTTP;
with PolyORB.Initialization;

with PolyORB.ORB;
with PolyORB.Obj_Adapters;
with PolyORB.Parameters;
with PolyORB.Protocols;
with PolyORB.Protocols.SOAP_Pr;
with PolyORB.Setup;
with PolyORB.Sockets;
with PolyORB.References.IOR;
with PolyORB.References.URI;
with PolyORB.Representations.CDR.Common;
--  XXX Unfortunate dependency on CDR code. Should provide
--  To_Any methods instead!!!!!! (but actually the Any in question
--  would be specific of how IORs are constructed) (but we could
--  say that the notion of IOR is cross-platform!).

with PolyORB.Transport.Connected.Sockets;
with PolyORB.Utils.Strings;
with PolyORB.Log;

with PolyORB.Web.URL;

package body PolyORB.Binding_Data.SOAP is

   use Ada.Streams;

   use PolyORB.Log;
   use PolyORB.Buffers;
   use PolyORB.Filters.HTTP;
   use PolyORB.Objects;
   use PolyORB.Protocols.SOAP_Pr;
   use PolyORB.Representations.CDR.Common;
   use PolyORB.Transport;
   use PolyORB.Transport.Connected.Sockets;
   use PolyORB.Types;
   use PolyORB.Utils.Sockets;

   package L is new PolyORB.Log.Facility_Log ("polyorb.binding_data.soap");
   procedure O (Message : Standard.String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;

   Preference : Profile_Preference;
   --  Global variable: the preference to be returned
   --  by Get_Profile_Preference for SOAP profiles.

   function Profile_To_URI (P : Profile_Access) return String;

   function URI_To_Profile (Str : String) return Profile_Access;

   procedure Marshall_SOAP_Profile_Body
     (Buf     : access Buffers.Buffer_Type;
      Profile : Profile_Access);

   function Unmarshall_SOAP_Profile_Body
     (Buffer : access Buffers.Buffer_Type)
    return  Profile_Access;

   SOAP_URI_Prefix : constant String := "http://";

   -------------
   -- Release --
   -------------

   overriding procedure Release (P : in out SOAP_Profile_Type) is
   begin
      Free (P.Address);
      Free (P.Object_Id);
   end Release;

   ------------------
   -- Bind_Profile --
   ------------------

   Htt  : aliased Filters.HTTP.HTTP_Filter_Factory;
   Pro  : aliased Protocols.SOAP_Pr.SOAP_Protocol;
   SOAP_Factories : constant Filters.Factory_Array
     := (0 => Htt'Access, 1 => Pro'Access);

   overriding procedure Bind_Profile
     (Profile : access SOAP_Profile_Type;
      The_ORB :        Components.Component_Access;
      QoS     :        PolyORB.QoS.QoS_Parameters;
      BO_Ref  :    out Smart_Pointers.Ref;
      Error   :    out Errors.Error_Container)
   is
      pragma Unreferenced (QoS);

      use PolyORB.Components;
      use PolyORB.Binding_Objects;
      use PolyORB.Errors;
      use PolyORB.Filters;
      use PolyORB.ORB;
      use PolyORB.Protocols;
      use PolyORB.Sockets;

      Sock : Socket_Type;
      TE   : constant Transport.Transport_Endpoint_Access :=
        new Socket_Endpoint;

   begin
      Utils.Sockets.Create_Socket (Sock);
      Utils.Sockets.Connect_Socket (Sock, Profile.Address.all);
      Create (Socket_Endpoint (TE.all), Sock);

      Binding_Objects.Setup_Binding_Object
        (The_ORB,
         TE,
         SOAP_Factories,
         BO_Ref,
         Profile_Access (Profile));

      ORB.Register_Binding_Object
        (ORB.ORB_Access (The_ORB),
         BO_Ref,
         ORB.Client);

   exception
      when Sockets.Socket_Error =>
         Throw (Error, Comm_Failure_E, System_Exception_Members'
                (Minor => 0, Completed => Completed_Maybe));
   end Bind_Profile;

   ---------------------
   -- Get_Profile_Tag --
   ---------------------

   overriding function Get_Profile_Tag
     (Profile : SOAP_Profile_Type)
     return Profile_Tag
   is
      pragma Warnings (Off);
      pragma Unreferenced (Profile);
      pragma Warnings (On);

   begin
      return Tag_SOAP;
   end Get_Profile_Tag;

   ----------------------------
   -- Get_Profile_Preference --
   ----------------------------

   overriding function Get_Profile_Preference
     (Profile : SOAP_Profile_Type)
     return Profile_Preference
   is
      pragma Warnings (Off);
      pragma Unreferenced (Profile);
      pragma Warnings (On);
   begin
      return Preference;
   end Get_Profile_Preference;

   ------------------
   -- Is_Colocated --
   ------------------

   overriding function Is_Colocated
     (Left  : SOAP_Profile_Type;
      Right : Profile_Type'Class) return Boolean
   is
      use Sockets;
   begin
      return Right in SOAP_Profile_Type
        and then Left.Address = SOAP_Profile_Type (Right).Address;
   end Is_Colocated;

   ------------------
   -- Get_URI_Path --
   ------------------

   function Get_URI_Path
     (Profile : SOAP_Profile_Type)
     return Types.String is
   begin
      return Profile.URI_Path;
   end Get_URI_Path;

   --------------------
   -- Create_Factory --
   --------------------

   overriding function Create_Factory
     (TAP : not null access Transport.Transport_Access_Point'Class)
      return SOAP_Profile_Factory
   is
   begin
      return PF : SOAP_Profile_Factory do
         PF.Address :=
           new Socket_Name'
             (Connected_Socket_AP (TAP.all).Socket_AP_Publish_Name);
      end return;
   end Create_Factory;

   --------------------
   -- Create_Profile --
   --------------------

   overriding function Create_Profile
     (PF  : access SOAP_Profile_Factory;
      Oid : Objects.Object_Id)
     return Profile_Access
   is
      use PolyORB.Errors;

      Error : Error_Container;

      Result : constant Profile_Access := new SOAP_Profile_Type;

      TResult : SOAP_Profile_Type
        renames SOAP_Profile_Type (Result.all);

   begin
      TResult.Object_Id := new Object_Id'(Oid);
      TResult.Address   := new Socket_Name'(PF.Address.all);

      Obj_Adapters.Oid_To_Rel_URI
        (PolyORB.ORB.Object_Adapter (Setup.The_ORB),
         TResult.Object_Id,
         TResult.URI_Path, Error);

      if Found (Error) then
         Catch (Error);
         return null;

      else
         return Result;
      end if;
   end Create_Profile;

   --------------------
   -- Create_Profile --
   --------------------

   function Create_Profile
     (URI : Types.String)
     return Profile_Access
   is
      use PolyORB.Web.URL;
      use Sockets;

      URL : PolyORB.Web.URL.Object :=
        Parse (To_Standard_String (URI));

      Result : constant Profile_Access := new SOAP_Profile_Type;

      TResult : SOAP_Profile_Type
        renames SOAP_Profile_Type (Result.all);
   begin
      Normalize (URL);
      TResult.Address  := new Socket_Name'
                            (Server_Name (URL)
                             + Port_Type (Positive'(Port (URL))));
      TResult.URI_Path := To_PolyORB_String (PolyORB.Web.URL.URI (URL));

      if ORB.Is_Profile_Local (Setup.The_ORB, Result) then

         --  Fill Oid from URI for a local profile.

         TResult.Object_Id
           := PolyORB.Obj_Adapters.Rel_URI_To_Oid
           (PolyORB.ORB.Object_Adapter (Setup.The_ORB),
            PolyORB.Types.To_Standard_String (TResult.URI_Path));
      end if;

      return Result;
   end Create_Profile;

   -----------------------
   -- Duplicate_Profile --
   -----------------------

   overriding function Duplicate_Profile
     (P : SOAP_Profile_Type)
     return Profile_Access
   is
      Result : constant Profile_Access := new SOAP_Profile_Type;

      TResult : SOAP_Profile_Type
        renames SOAP_Profile_Type (Result.all);

      PP : SOAP_Profile_Type renames P;

   begin
      TResult.Object_Id := new Object_Id'(PP.Object_Id.all);
      TResult.Address   := new Socket_Name'(PP.Address.all);
      TResult.URI_Path  := PP.URI_Path;

      return Result;
   end Duplicate_Profile;

   ----------------------
   -- Is_Local_Profile --
   ----------------------

   overriding function Is_Local_Profile
     (PF : access SOAP_Profile_Factory;
      P  : not null access Profile_Type'Class)
      return Boolean
   is
      use type PolyORB.Sockets.Sock_Addr_Type;
   begin
      if P.all in SOAP_Profile_Type
        and then SOAP_Profile_Type (P.all).Address = PF.Address
      then
         P.Known_Local := True;
         return True;
      end if;
      return False;
   end Is_Local_Profile;

   --------------------------------
   -- Marshall_SOAP_Profile_Body --
   --------------------------------

   procedure Marshall_SOAP_Profile_Body
     (Buf     : access Buffer_Type;
      Profile : Profile_Access)
   is
      SOAP_Profile : SOAP_Profile_Type renames SOAP_Profile_Type (Profile.all);
      Profile_Body : Buffer_Access := new Buffer_Type;

   begin

      --  A Tag_SOAP Profile Body is an encapsulation.

      Start_Encapsulation (Profile_Body);

      --  Marshalling the socket address

      Marshall_Socket (Profile_Body, SOAP_Profile.Address.all);

      --  Marshalling the Object Id

      Marshall
        (Profile_Body, Stream_Element_Array
         (SOAP_Profile.Object_Id.all));

      Marshall_Latin_1_String (Profile_Body, SOAP_Profile.URI_Path);

      --  Marshall the Profile_Body into IOR.

      Marshall (Buf, Encapsulate (Profile_Body));
      Release (Profile_Body);
   end Marshall_SOAP_Profile_Body;

   ----------------------------------
   -- Unmarshall_SOAP_Profile_Body --
   ----------------------------------

   function Unmarshall_SOAP_Profile_Body
     (Buffer       : access Buffer_Type) return Profile_Access
   is
      Profile_Body   : aliased Encapsulation := Unmarshall (Buffer);
      Profile_Buffer : Buffer_Access := new Buffers.Buffer_Type;
      Result         : constant Profile_Access := new SOAP_Profile_Type;
      TResult        : SOAP_Profile_Type
        renames SOAP_Profile_Type (Result.all);
   begin

      --  A Tag_SOAP Profile Body is an encapsulation.

      Decapsulate (Profile_Body'Access, Profile_Buffer);

      --  Unmarshalling the socket address

      TResult.Address := new Socket_Name'(Unmarshall_Socket (Profile_Buffer));

      --  Unmarshalling the Object Id

      declare
         Str  : aliased constant Stream_Element_Array :=
           Unmarshall (Profile_Buffer);
      begin
         TResult.Object_Id := new Object_Id'(Object_Id (Str));
      end;

      TResult.URI_Path := Unmarshall_Latin_1_String (Profile_Buffer);
      Release (Profile_Buffer);

      return Result;
   end Unmarshall_SOAP_Profile_Body;

   --------------------
   -- Profile_To_URI --
   --------------------

   function Profile_To_URI (P : Profile_Access) return String is
      use PolyORB.Sockets;
      use PolyORB.Utils;
      use PolyORB.Utils.Strings;

      SOAP_Profile : SOAP_Profile_Type renames SOAP_Profile_Type (P.all);
   begin
      pragma Debug (C, O ("SOAP Profile to URI"));
      return SOAP_URI_Prefix
        & Image (SOAP_Profile.Address.all)
        & To_Standard_String (SOAP_Profile.URI_Path);
   end Profile_To_URI;

   --------------------
   -- URI_To_Profile --
   --------------------

   function URI_To_Profile (Str : String) return Profile_Access is
      use PolyORB.Utils;
      use PolyORB.Utils.Strings;

      Host_First, Host_Last : Natural;
   begin
      if Str'Length > SOAP_URI_Prefix'Length
        and then Str (Str'First .. Str'First + SOAP_URI_Prefix'Length - 1)
        = SOAP_URI_Prefix
      then
         declare
            Result  : constant Profile_Access := new SOAP_Profile_Type;
            TResult : SOAP_Profile_Type renames SOAP_Profile_Type (Result.all);
            S       : constant String
              := Str (Str'First + SOAP_URI_Prefix'Length .. Str'Last);
            Index   : Integer := S'First;
            Index2  : Integer;
         begin
            pragma Debug (C, O ("SOAP URI to profile: enter"));

            Index2 := Find (S, Index, ':');
            if Index2 = S'Last + 1 then
               return null;
            end if;
            pragma Debug (C, O ("Address = " & S (Index .. Index2 - 1)));
            Host_First := Index;
            Host_Last := Index2 - 1;
            Index := Index2 + 1;

            Index2 := Find (S, Index, '/');
            if Index2 = S'Last + 1 then
               return null;
            end if;
            pragma Debug (C, O ("Port = " & S (Index .. Index2 - 1)));
            TResult.Address :=
              new Socket_Name'(S (Host_First .. Host_Last)
                               + Sockets.Port_Type'Value
                                 (S (Index .. Index2 - 1)));
            Index := Index2;
            TResult.URI_Path := To_PolyORB_String (S (Index .. S'Last));

            pragma Debug (C, O ("URI_Path is " & S (Index .. S'Last)));
            pragma Debug (C, O ("SOAP URI to profile: leave"));
            return Result;
         end;
      else
         return null;
      end if;
   end URI_To_Profile;

   -----------
   -- Image --
   -----------

   overriding function Image (Prof : SOAP_Profile_Type) return String
   is
      Result : PolyORB.Types.String := To_PolyORB_String
        ("Address: " & Image (Prof.Address.all));
   begin
      if Prof.Object_Id /= null then
         Append
           (Result,
            ", Object_Id : " & PolyORB.Objects.Image
            (Prof.Object_Id.all));
      else
         Append (Result, ", object id not available.");
      end if;
      return To_Standard_String (Result);
   end Image;

   ------------
   -- To_URI --
   ------------

   function To_URI (Prof : SOAP_Profile_Type) return String is
   begin
      return "http://" & Image (Prof.Address.all)
        & To_Standard_String (Prof.URI_Path);
   end To_URI;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize;

   procedure Initialize
   is
      use PolyORB.References.URI;

      Preference_Offset : constant String :=
        PolyORB.Parameters.Get_Conf
        (Section => "soap",
         Key     => "polyorb.binding_data.soap.preference",
         Default => "0");
   begin
      Preference := Preference_Default + Profile_Preference'Value
        (Preference_Offset);
      References.IOR.Register
        (Tag_SOAP,
         Marshall_SOAP_Profile_Body'Access,
         Unmarshall_SOAP_Profile_Body'Access);
      References.URI.Register
        (Tag_SOAP,
         SOAP_URI_Prefix,
         Profile_To_URI'Access,
         URI_To_Profile'Access);
   end Initialize;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"binding_data.soap",
       Conflicts => Empty,
       Depends   => +"sockets",
       Provides  => +"binding_factories",
       Implicit  => False,
       Init      => Initialize'Access,
       Shutdown  => null));
end PolyORB.Binding_Data.SOAP;
