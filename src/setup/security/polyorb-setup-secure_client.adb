------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--          P O L Y O R B . S E T U P . S E C U R E _ C L I E N T           --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2005-2006, Free Software Foundation, Inc.          --
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

--  Setup secure client

with PolyORB.Setup.Security_Base;
pragma Warnings (Off, PolyORB.Setup.Security_Base);

--  Neutral Core Setup

with PolyORB.Security.Authentication_Mechanisms.GSSUP_Client;
pragma Warnings (Off, PolyORB.Security.Authentication_Mechanisms.GSSUP_Client);

--  CORBA Application Personality Setup

with PolyORB.CORBA_P.CSS_State_Machine;
pragma Warnings (Off, PolyORB.CORBA_P.CSS_State_Machine);

--  ATLAS Privilege Authority

--  with PolyORB.Security.Authority_Mechanisms.ATLAS_Client;
--  pragma Warnings (Off, PolyORB.Security.Authority_Mechanisms.ATLAS_Client);

package body PolyORB.Setup.Secure_Client is

end PolyORB.Setup.Secure_Client;
