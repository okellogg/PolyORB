------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUNTIME COMPONENTS                          --
--                                                                          --
--                          G N A T . H T A B L E                           --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                            $Revision$                             --
--                                                                          --
--          Copyright (C) 1992-1997 Free Software Foundation, Inc.          --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with GNAT;  see file COPYING.  If not, write --
-- to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
-- MA 02111-1307, USA.                                                      --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- It is now maintained by Ada Core Technologies Inc (http://www.gnat.com). --
--                                                                          --
------------------------------------------------------------------------------

package GNAT.HTable is
pragma Preelaborate (HTable);

   -------------------
   -- Simple_HTable --
   -------------------

   --  A simple hash table abstraction, easy to instanciate, easy to use.
   --  The table associates one element to one key with the procedure Set.
   --  Get retrieves the Element stored for a given Key. The efficiency of
   --  retrieval is function of the size of the Table parameterized by
   --  Header_Num and the hashing function Hash.

   generic
      type Header_Num is range <>;
      --  An integer type indicating the number and range of hash headers.

      type Element is private;
      --  The type of element to be stored

      No_Element : Element;
      --  The object that is returned by Get when no element has been set for
      --  a given key

      type Key is private;
      with function Hash  (F : Key)      return Header_Num;
      with function Equal (F1, F2 : Key) return Boolean;

   package Simple_HTable is

      procedure Set (K : Key; E : Element);
      --  Associates an element with a given key. Overrides any previously
      --  associated element.

      function  Get (K : Key) return Element;
      --  Returns the Element associated wtih a key or No_Element if the
      --  given key has not associated element

   end Simple_HTable;

   -------------------
   -- Static_HTable --
   -------------------

   --  A low-level Hash-Table abstraction, not as easy to instantiate as
   --  Simple_HTable but designed to allow complete control over the
   --  allocation of necessary data structures. Particularly useful when
   --  dynamic allocation is not desired. The model is that "Element"
   --  contains its own Key that can be retrieved by "Get_Key". Furthermore,
   --  "Element" provides a link that can be used by the HTable for linking
   --   elements with same hash codes:

   --       Element

   --         +-------------------+
   --         |       Key         |
   --         +-------------------+
   --         :   other data      :
   --         +-------------------+
   --         |     Next Elmt     |
   --         +-------------------+

   generic
      type Header_Num is range <>;
      --  An integer type indicating the number and range of hash headers.

      type Element (<>) is limited private;
      --  The type of element to be stored

      type Elmt_Ptr is private;
      --  The type used to reference an element (will usually be an access
      --  type, but could be some other form of type such as an integer type).

      Null_Ptr : Elmt_Ptr;
      --  The null value of the Elmt_Ptr type.

      with procedure Set_Next (E : Elmt_Ptr; Next : Elmt_Ptr);
      with function  Next     (E : Elmt_Ptr) return Elmt_Ptr;
      --  The type must provide an internal link for the sake of the
      --  staticness of the HTable.

      type Key is limited private;
      with function Get_Key (E : Elmt_Ptr) return Key;
      with function Hash    (F : Key)      return Header_Num;
      with function Equal   (F1, F2 : Key) return Boolean;

   package Static_HTable is

      procedure Reset;
      --  Resets the hash table by setting all its elements to Null_Ptr. The
      --  effect is to clear the hash table so that it can be reused. For the
      --  most common case where Elmt_Ptr is an access type, and Null_Ptr is
      --  null, this is only needed if the same table is reused in a new
      --  context. If Elmt_Ptr is other than an access type, or Null_Ptr is
      --  other than null, then Reset must be called before the first use
      --  of the hash table.

      procedure Set (E : Elmt_Ptr);
      --  Insert the element pointer in the HTable

      function  Get (K : Key) return Elmt_Ptr;
      --  Returns the latest inserted element pointer with the given Key
      --  or null if none.

      procedure Remove (K : Key);
      --  Removes the latest inserted element pointer associated with the
      --  given key if any, does nothing if none.

   end Static_HTable;

   ----------
   -- Hash --
   ----------

   --  A generic hashing function working on String keys

   generic
      type Header_Num is range <>;
   function Hash (Key : String) return Header_Num;

end GNAT.HTable;
