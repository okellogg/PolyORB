package body Broca.Names is

   Prefix  : constant String := "omg.org";
   Version : constant String := "1.0";

   ----------------
   -- OMG_Prefix --
   ----------------

   function OMG_Prefix return String is
   begin
      return Prefix;
   end OMG_Prefix;

   ----------------------
   -- OMG_RepositoryId --
   ----------------------

   function OMG_RepositoryId (Name : String) return String is
   begin
      return "IDL:" & Prefix & "/CORBA/" & Name & ":" & Version;
   end OMG_RepositoryId;

   -----------------
   -- OMG_Version --
   -----------------

   function OMG_Version return String is
   begin
      return Version;
   end OMG_Version;

end Broca.Names;
