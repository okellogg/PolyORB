------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                P O L Y O R B . U T I L S . H T A B L E S                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2003 Free Software Foundation, Inc.           --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
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
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

--  Parent package for Hash Tables.

--  $Id$

package PolyORB.Utils.HTables is

   pragma Pure;

   No_Key : exception;

   --  Every hash table HTable on a given Item type must define
   --  the following procedures and functions.

   --     function Lookup
   --       (T           : HTable;
   --        Key         : String;
   --        Error_Value : Item)
   --        return Item;
   --     --  Find Key in hash table and return its associated Item.
   --     --  When Key does not exist, the function returns Error_Value.

   --     function Lookup
   --       (T     : HTable;
   --        Key   : String)
   --        return Item;
   --     --  Find Key in hash table and return its associated Item.
   --     --  When Key does not exist, the function raise No_Key exception.

   --     procedure Insert
   --       (T     : HTable;
   --        Key   : String;
   --        Value : Item);
   --     --  Insert (Key, Value) in hash table.
   --     --  Key is the string to hash and Value its associated Item.
   --     --  If Key already exists, nothing is done.

   --     procedure Delete
   --       (T   : HTable;
   --        Key : String);
   --     --  Delete key in hash table. In case of a non-existing Key, Delete
   --     --  ignores deletion. Key is the string to hash.

end PolyORB.Utils.HTables;