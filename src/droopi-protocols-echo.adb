--  A dummy protocol, just for testing.

--  $Id$

with Ada.Exceptions;

with Droopi.Buffers;
with Droopi.Log;
with Droopi.Requests; use Droopi.Requests;

with Droopi.Representations.Test; use Droopi.Representations.Test;

package body Droopi.Protocols.Echo is

   use Droopi.Log;

   package L is new Droopi.Log.Facility_Log ("droopi.protocols.echo");
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;

   Rep : constant Rep_Test_Access := new Rep_Test;

   procedure Create_Session
     (Proto   : access Echo_Protocol;
      Server  : Servers.Server_Access;
      Sock    : Sockets.Socket_Type;
      Session : out Session_Access;
      Channel : out Channels.Channel_Access)
   is
   begin

      --  This should be factored in Droopi.Protocols.

      Session := new Echo_Session;
      Channel := new Session_Channel;
      Channels.Create (Channel, Sock);
      Session_Channel (Channel.all).Session := Session;
      Session.Server  := Server;
      Session.Channel := Channel;

      --  That is Echo-specific. Or is it?

      Echo_Session (Session.all).Buffer := new Buffers.Buffer_Type;

   end Create_Session;

   procedure Invoke_Request (S : access Echo_Session; R : Request) is
   begin
      null;
   end Invoke_Request;

   procedure Abort_Request (S : access Echo_Session; R : Request) is
   begin
      null;
   end Abort_Request;

   procedure Handle_Connect (S : access Echo_Session) is
   begin
      --  Send_String ("Hello, please type data." & ASCII.LF);
      pragma Debug (O ("Received new connection to echo service..."));
      Channels.Expect_Data (S.Channel, S.Buffer, 1024, False);
   end Handle_Connect;

   type String_Array is array (Integer range <>) of String_Ptr;

   function Split (S : String) return String_Array;
   function Split (S : String) return String_Array
   is
      Result : String_Array (1 .. S'Length);
      Last : Integer := Result'First - 1;
      Word_First : Integer := S'First;
      Word_Last : Integer;
   begin
      while Word_First <= S'Last loop
         Word_Last := Word_First - 1;
         Last := Last + 1;
         while Word_Last < S'Last and then S (Word_Last + 1) /= ' ' loop
            Word_Last := Word_Last + 1;
         end loop;
         Result (Last) := new String'(S (Word_First .. Word_Last));
         Word_First := Word_Last + 1;
         while Word_First <= S'Last and then S (Word_First) = ' ' loop
            Word_First := Word_First + 1;
         end loop;
      end loop;

      return Result (Result'First .. Last);
   end Split;

   procedure Free (SA : in out String_Array);
   procedure Free (SA : in out String_Array) is
   begin
      for I in SA'Range loop
         Free (SA (I));
      end loop;
   end Free;

   procedure Handle_Data (S : access Echo_Session) is
   begin
      pragma Debug (O ("Received data on echo service..."));
      pragma Debug (Buffers.Show (S.Buffer.all));

      declare
         Argv : String_Array
           := Split (Unmarshall_String (Rep, S.Buffer));

         Req : Request_Access := null;
      begin
         Buffers.Release_Contents (S.Buffer.all);
         --  Clear buffer

         begin
            pragma Debug (O ("Received request " & Argv (1).all
                             & " on object " & Argv (2).all
                             & " with args " & Argv (3).all));
            Create_Request
              (Req,
               Target    => Argv (2),
               Operation => Argv (1).all,
               Args      => Argv (3).all);

            Servers.Queue_Request (S.Server, Req);
         exception
            when E : others =>
               O ("Got exception: "
                  & Ada.Exceptions.Exception_Information (E));
         end;
         Free (Argv);
      end;

      Channels.Expect_Data (S.Channel, S.Buffer, 1024, False);
      --  Prepare to receive next message.
   end Handle_Data;

   procedure Handle_Connection_Closed (S : access Echo_Session) is
   begin
      pragma Debug (O ("Received disconnect."));

      --  Cleanup protocol.

      Buffers.Release (S.Buffer);

      --  Destroy channel, remove it from the ORB.

      --  Destroy session.

      null;
   end Handle_Connection_Closed;

end Droopi.Protocols.Echo;

