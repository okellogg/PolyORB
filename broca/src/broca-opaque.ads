------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                         B R O C A . O P A Q U E                          --
--                                                                          --
--                                 S p e c                                  --
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

with Ada.Unchecked_Deallocation;

with Interfaces;

with System;
--  For System.Address.

package Broca.Opaque is

   pragma Preelaborate;

   subtype Opaque_Pointer is System.Address;
   --  The address of some data.

   type Index_Type is new Interfaces.Unsigned_32;
   subtype Positive_Index_Type is Index_Type
     range 1 .. Index_Type'Last;

   subtype Octet is Interfaces.Unsigned_8;
   type Octet_Array is array (Positive_Index_Type range <>)
     of aliased Octet;
   pragma Convention (C, Octet_Array);
   --  Some storage space.

   type Octet_Array_Ptr is access Octet_Array;

   procedure Free is
      new Ada.Unchecked_Deallocation (Octet_Array, Octet_Array_Ptr);

   subtype Alignment_Type is Index_Type range 1 .. 8;

end Broca.Opaque;
