------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--              P O L Y O R B . O B J _ A D A P T E R _ Q O S               --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--            Copyright (C) 2005 Free Software Foundation, Inc.             --
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

with PolyORB.Obj_Adapters;
with PolyORB.QoS;

package PolyORB.Obj_Adapter_QoS is

   procedure Set_Object_Adapter_QoS
     (OA  : access PolyORB.Obj_Adapters.Obj_Adapter'Class;
      QoS :        PolyORB.QoS.QoS_Parameters);
   --  Set Object Adapter QoS

   function Get_Object_Adapter_QoS
     (OA  : access PolyORB.Obj_Adapters.Obj_Adapter'Class)
      return PolyORB.QoS.QoS_Parameters;
   --  Retrieve Object Adapter QoS

   procedure Set_Object_Adapter_QoS
     (OA   : access PolyORB.Obj_Adapters.Obj_Adapter'Class;
      Kind :        PolyORB.QoS.QoS_Kind;
      QoS  :        PolyORB.QoS.QoS_Parameter_Access);

   function Get_Object_Adapter_QoS
     (OA   : access PolyORB.Obj_Adapters.Obj_Adapter'Class;
      Kind :        PolyORB.QoS.QoS_Kind)
      return PolyORB.QoS.QoS_Parameter_Access;

end PolyORB.Obj_Adapter_QoS;