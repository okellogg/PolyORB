with Ada.Text_IO; use Ada.Text_IO;

with Idl_Fe.Types; use Idl_Fe.Types;
with Idl_Fe.Tree;  use Idl_Fe.Tree;
with Idl_Fe.Tree.Accessors; use Idl_Fe.Tree.Accessors;
with Idl_Fe.Tree.Synthetic; use Idl_Fe.Tree.Synthetic;

with Ada_Be.Identifiers; use Ada_Be.Identifiers;
with Ada_Be.Source_Streams; use Ada_Be.Source_Streams;

package body Ada_Be.Idl2Ada is

   ---------------
   -- Constants --
   ---------------

   Stream_Suffix : constant String
     := ".Stream";
   --  The name of the CDR packages for a scope.

   -------------------------------------------------
   -- General purpose code generation subprograms --
   -------------------------------------------------

   procedure Gen_Scope
     (Node : N_Root_Acc);
   --  Generate all the files for scope Node.

   procedure Gen_Node_Stubs_Spec
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the declaration for the stubs of a node.

   procedure Gen_Node_Stubs_Body
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the body for the stubs of a node.

   procedure Gen_Node_Stream_Spec
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the package declaration for the
   --  marchalling function of a node.

   procedure Gen_Node_Stream_Body
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the package declaration for the
   --  marchalling function of a node.

   procedure Gen_Node_Default
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the text for a node whose mapping is
   --  common to all generated files.

   ----------------------------------------
   -- Specialised generation subprograms --
   ----------------------------------------

   procedure Gen_Object_Reference_Declaration
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc;
      Full_View : Boolean);
   --  Generate the declaration of an object reference
   --  type.

   procedure Gen_Marshall_Profile
     (CU        : in out Compilation_Unit;
      Type_Name : in String);
   --  Generate the profile for the Marshall procedure
   --  of a type.
   --  FIXME: This is marshall-by-value.
   --         Marshall-by-reference should be produced
   --         as well.

   procedure Gen_Unmarshall_Profile
     (CU        : in out Compilation_Unit;
      Type_Name : in String);
   --  Generate the profile for the Unmarshall function
   --  of a type.
   --  FIXME: This is unmarshall-by-value (see above).

   procedure Gen_Array_Iterator
     (CU               : in out Compilation_Unit;
      Array_Name       : String;
      Array_Dimensions : Natural;
      Stmt_Template    : String);
   --  Generate "for" loops that iterate over Array_Name,
   --  an array with Array_Dimensions dimensions, performing
   --  statement Stmt_Template on each array cell. The first
   --  occurence of the '%' character in Stmt_Template is
   --  replaced by the proper indices, with parentheses.

   procedure Gen_When_Clause
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc;
      Default_Case_Seen : out Boolean);
   --  Generate "when" clause for union N_Case Node.
   --  If this N_Case has a "default:" label, then
   --  Default_Case_Seen is set to True, else its
   --  value is left unchanged.

   procedure Gen_When_Others_Clause
     (CU   : in out Compilation_Unit);
   --  Generate a "when others => null;" clause.

   procedure Gen_Operation_Profile
     (CU : in out Compilation_Unit;
      Node : N_Root_Acc);
   --  Generate the profile for an N_Operation node.

   ------------------------
   -- Helper subprograms --
   ------------------------

   function Ada_Type_Name
     (Node : N_Root_Acc)
     return String;
   --  The name of the Ada type that maps Node.

   ----------------------------------------------
   -- End of internal subprograms declarations --
   ----------------------------------------------

   procedure Generate
     (Node : in N_Root_Acc) is
   begin
      pragma Assert (Is_Scope (Node));

      Gen_Scope (Node);
   end Generate;

   procedure Gen_Scope
     (Node : N_Root_Acc)
   is
      Stubs_Name : constant String
        := Ada_Full_Name (Node);
      Stream_Name : constant String
        := Stubs_Name & Stream_Suffix;

      Stubs_Spec : Compilation_Unit
        := New_Package (Stubs_Name, Unit_Spec);
      Stubs_Body : Compilation_Unit
        := New_Package (Stubs_Name, Unit_Body);

      Stream_Spec : Compilation_Unit
        := New_Package (Stream_Name, Unit_Spec);
      Stream_Body : Compilation_Unit
        := New_Package (Stream_Name, Unit_Body);

   begin
      case Get_Kind (Node.all) is
         when K_ValueType =>
            --  Not implemented yet.
            raise Program_Error;

         when
           K_Repository |
           K_Module     =>

            declare
               It   : Node_Iterator;
               Decl_Node : N_Root_Acc;
            begin
               Init (It, Contents (Node));
               while not Is_End (It) loop
                  Decl_Node := Get_Node (It);
                  Next (It);

                  if Is_Scope (Decl_Node) then
                     Gen_Scope (Decl_Node);
                  else
                     Gen_Node_Stubs_Spec
                       (Stubs_Spec, Decl_Node);

                     --  No stubs body for a module or
                     --  repository.

                     Gen_Node_Stream_Spec
                       (Stream_Spec, Decl_Node);
                     Gen_Node_Stream_Body
                       (Stream_Body, Decl_Node);
                  end if;

               end loop;
            end;

         when K_Interface =>

            Gen_Object_Reference_Declaration
              (Stubs_Spec, Node, Full_View => False);
            --  The object reference type.

            Gen_Node_Stream_Spec
              (Stream_Spec, Node);
            Gen_Node_Stream_Body
              (Stream_Body, Node);
            --  Marshalling subprograms for the object
            --  reference type.

            declare
               Forward_Node : constant N_Root_Acc
                 := N_Root_Acc (N_Forward_Interface_Acc'(Forward (Node)));
            begin
               if Forward_Node /= null then
                  --  This interface has a forward declaration.

                  New_Line (Stubs_Spec);
                  Put_Line (Stubs_Spec, "package Convert_Forward is");
                  Put_Line (Stubs_Spec, "  new "
                       & Ada_Full_Name (Forward_Node)
                       & ".Convert (Ref_Type => Ref);");
               end if;
            end;

            declare
               It   : Node_Iterator;
               Export_Node : N_Root_Acc;
            begin
               Init (It, Contents (Node));
               while not Is_End (It) loop
                  Export_Node := Get_Node (It);
                  Next (It);
                  if Is_Scope (Export_Node) then
                     Gen_Scope (Export_Node);
                  else
                     Gen_Node_Stubs_Spec
                       (Stubs_Spec, Export_Node);
                     Gen_Node_Stubs_Body
                       (Stubs_Body, Export_Node);

                     Gen_Node_Stream_Spec
                       (Stream_Spec, Export_Node);
                     Gen_Node_Stream_Body
                       (Stream_Body, Export_Node);
                  end if;

               end loop;
            end;

            --  XXX Declare also inherited subprograms
            --  (for multiple inheritance.) -> Expansion ?

            --  XXX Declare Repository_Id
            --  XXX Declare and implement Is_A

            New_Line (Stubs_Spec);
            Put_Line (Stubs_Spec, "function Unchecked_To_Ref");
            Put_Line (Stubs_Spec, "  (The_Ref : in CORBA.Object.Ref'Class)");
            Put_Line (Stubs_Spec, "  return Ref;");
            Put_Line (Stubs_Spec, "function To_Ref");
            Put_Line (Stubs_Spec, "  (The_Ref : in CORBA.Object.Ref'Class)");
            Put_Line (Stubs_Spec, "  return Ref;");
            New_Line (Stubs_Spec);

            Dec_Indent (Stubs_Spec);
            Put_Line (Stubs_Spec, "private");
            Inc_Indent (Stubs_Spec);

            Gen_Object_Reference_Declaration
              (Stubs_Spec, Node, Full_View => True);

            New_Line (Stubs_Body);
            Put_Line (Stubs_Body, "function Unchecked_To_Ref");
            Put_Line (Stubs_Body, "  (The_Ref : in CORBA.Object.Ref'Class)");
            Put_Line (Stubs_Body, "  return Ref");
            Put_Line (Stubs_Body, "is");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "Result : Ref;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "begin");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "Broca.Refs.Set");
            Put_Line (Stubs_Body, "  (Broca.Refs.Ref (Result),");
            Put_Line (Stubs_Body,
                      "   Broca.Refs.Get (Broca.Refs.Ref (The_Ref)));");
            Put_Line (Stubs_Body, "return Result;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "end Unchecked_To_Ref;");
            New_Line (Stubs_Body);
            Put_Line (Stubs_Body, "function To_Ref");
            Put_Line (Stubs_Body, "  (The_Ref : in CORBA.Object.Ref'Class)");
            Put_Line (Stubs_Body, "  return Ref");
            Put_Line (Stubs_Body, "is");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "Result : Ref;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "begin");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "Result := Unchecked_To_Ref (The_Ref);");
            Put_Line (Stubs_Body, "if Is_A (Result, Repository_Id) then");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "return Result;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "else");
            Inc_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "Broca.Exceptions.Raise_Bad_Param;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "end if;");
            Dec_Indent (Stubs_Body);
            Put_Line (Stubs_Body, "end To_Ref;");

         when others =>
            pragma Assert (False);
            --  This never happens.

            null;
      end case;

      New_Line (Stubs_Spec);
      New_Line (Stubs_Body);
      New_Line (Stream_Spec);
      New_Line (Stream_Body);

      Generate (Stubs_Spec);
      Generate (Stubs_Body);
      Generate (Stream_Spec);
      Generate (Stream_Body);

   end Gen_Scope;

   procedure Gen_Object_Reference_Declaration
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc;
      Full_View : Boolean) is
   begin
      case Get_Kind (Node.all) is

         when K_Interface =>

            New_Line (CU);
            if Parents (Node) = Nil_List then
               Add_With (CU, "CORBA");
               Put (CU, "type Ref is new CORBA.Object.Ref with ");
            else
               declare
                  First_Parent_Name : constant String
                    := Ada_Full_Name (Head (Parents (Node)));
               begin
                  Add_With (CU, First_Parent_Name);
                  Put (CU,
                       "type Ref is new "
                       & First_Parent_Name
                       & ".Ref with ");
               end;
            end if;

            if Full_View then
               Put_Line (CU, "null record;");
            else
               Put_Line (CU, "private;");
            end if;

            --  when K_ValueType =>...

         when others =>
            raise Program_Error;

      end case;
   end Gen_Object_Reference_Declaration;

   procedure Gen_When_Clause
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc;
      Default_Case_Seen : out Boolean)
   is
      It   : Node_Iterator;
      Label_Node : N_Root_Acc;
      First_Label : Boolean := True;
      Multiple_Labels : Boolean;
   begin
      pragma Assert (Get_Kind (Node.all) = K_Case);

      Init (It, Labels (Node));
      while not Is_End (It) loop
         Label_Node := Get_Node (It);
         Next (It);

         Multiple_Labels := not Is_End (It);

         if First_Label then
            Put (CU, "when");
         end if;

         if Multiple_Labels then
            pragma Assert (Label_Node /= null);
            --  The null label is the "default:"
            --  one, and must have its own case.

            if not First_Label then
               Put_Line (CU, " |");
            else
               New_Line (CU);
            end if;
         end if;

         if Label_Node /= null then
            Gen_Node_Stubs_Spec (CU, Label_Node);
         else
            Put (CU, "others");
            Default_Case_Seen := True;
         end if;

         First_Label := False;
      end loop;

      Put_Line (CU, " =>");
   end Gen_When_Clause;

   procedure Gen_When_Others_Clause
     (CU : in out Compilation_Unit) is
   begin
      New_Line (CU);
      Put_Line (CU, "when others =>");
      Inc_Indent (CU);
      Put_Line (CU, "null;");
      Dec_Indent (CU);
   end Gen_When_Others_Clause;

   procedure Gen_Node_Stubs_Spec
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         --  Scopes

         when
           K_Repository |
           K_Module     |
           K_Interface  =>
            null;

         when K_Forward_Interface =>
            declare
               Forward_Instanciation : Compilation_Unit
                 := New_Package (Ada_Full_Name (Node), Unit_Spec);
            begin
               Dec_Indent (Forward_Instanciation);
               Put_Line (Forward_Instanciation, "  new CORBA.Forward;");
               Generate
                 (Forward_Instanciation,
                  Is_Generic_Instanciation => True);
            end;

         -----------------
         -- Value types --
         -----------------

         when K_ValueType =>
            null;
         when K_Forward_ValueType =>
            null;
         when K_Boxed_ValueType =>
            null;
         when K_State_Member =>
            null;
         when K_Initializer =>
            null;

         ----------------
         -- Operations --
         ----------------

         when K_Operation =>

            Gen_Operation_Profile (CU, Node);
            Put_Line (CU, ";");

            --        when K_Attribute =>
            --  null;

         when K_Exception =>
            Put_Line (CU, Ada_Name (Node) & " : exception;");

         when K_Member =>

            declare
               It   : Node_Iterator;
               Decl_Node : N_Root_Acc;
            begin
               Init (It, Decl (Node));
               while not Is_End (It) loop
                  Decl_Node := Get_Node (It);
                  Next (It);

                  Gen_Node_Stubs_Spec (CU, Decl_Node);
                  Put (CU, " : ");
                  Gen_Node_Stubs_Spec (CU, M_Type (Node));
                  Put_Line (CU, ";");

               end loop;
            end;

         when K_Enum =>
            Put_Line (CU, "type " & Ada_Name (Node) & " is");

            declare
               First_Enumerator : Boolean := True;
               It   : Node_Iterator;
               E_Node : N_Root_Acc;
            begin

               Init (It, Enumerators (Node));
               while not Is_End (It) loop
                  if First_Enumerator then
                     First_Enumerator := False;
                     Put (CU, "  (");
                     Inc_Indent (CU);
                  end if;

                  E_Node := Get_Node (It);
                  Next (It);

                  Gen_Node_Stubs_Spec (CU, E_Node);

                  if Is_End (It) then
                     Put_Line (CU, ");");
                     Dec_Indent (CU);
                  else
                     Put_Line (CU, ",");
                  end if;
               end loop;
            end;

         when K_Type_Declarator =>
            declare
               Is_Interface : constant Boolean
                 := Is_Interface_Type (T_Type (Node));
            begin
               declare
                  It   : Node_Iterator;
                  Decl_Node : N_Root_Acc;
               begin
                  Init (It, Declarators (Node));
                  while not Is_End (It) loop
                     Decl_Node := Get_Node (It);
                     Next (It);

                     declare
                        Bounds_It : Node_Iterator;
                        Bound_Node : N_Root_Acc;
                        First_Bound : Boolean := True;
                        Is_Array : constant Boolean
                          := not Is_Empty (Array_Bounds (Decl_Node));
                     begin

                        if Is_Interface
                          and then not Is_Array then
                           --  A typedef where the <type_spec>
                           --  denotes an interface type, and
                           --  which is not an array declaration.
                           Put (CU, "subtype ");
                        else
                           Put (CU, "type ");
                        end if;

                        Gen_Node_Stubs_Spec (CU, Decl_Node);

                        Put (CU, " is ");

                        if Is_Array then
                           Init (Bounds_It, Array_Bounds (Decl_Node));
                           while not Is_End (Bounds_It) loop
                              Bound_Node := Get_Node (Bounds_It);
                              Next (Bounds_It);

                              if First_Bound then
                                 Put (CU, "array (");
                                 First_Bound := False;
                              else
                                 Put (CU, ", ");
                              end if;

                              Put (CU, "0 .. ");
                              Gen_Node_Stubs_Spec (CU, Bound_Node);
                              Put (CU, " - 1");
                           end loop;
                           Put (CU, ") of ");
                        else
                           if not Is_Interface then
                              Put (CU, "new ");
                           end if;
                        end if;

                        Gen_Node_Stubs_Spec (CU, T_Type (Node));
                        Put_Line (CU, ";");
                     end;
                  end loop;
               end;
            end;

         when K_Const_Dcl =>
            null;

         when K_Union =>
            Put_Line (CU, "type " & Ada_Name (Node)
                      & "(Switch : ");
            Gen_Node_Stubs_Spec (CU, Switch_Type (Node));
            Put (CU, " := ");
            Gen_Node_Stubs_Spec (CU, Switch_Type (Node));
            Put_Line (CU, "'First) is record");
            Inc_Indent (CU);
            Put_Line (CU, "case Switch is");
            Inc_Indent (CU);

            declare
               It   : Node_Iterator;
               Case_Node : N_Root_Acc;
               Has_Default : Boolean := False;
            begin
               Init (It, Cases (Node));
               while not Is_End (It) loop
                  Case_Node := Get_Node (It);
                  Next (It);

                  Gen_When_Clause (CU, Node, Has_Default);

                  Inc_Indent (CU);
                  Gen_Node_Stubs_Spec
                    (CU, N_Root_Acc (Case_Decl (Node)));
                  Put (CU, " : ");
                  Gen_Node_Stubs_Spec (CU, Case_Type (Node));
                  Put_Line (CU, ";");
                  Dec_Indent (CU);
               end loop;

               if not Has_Default then
                  Gen_When_Others_Clause (CU);
               end if;
            end;

            Dec_Indent (CU);
            Put_Line (CU, "end case;");
            Dec_Indent (CU);
            Put_Line (CU, "end record;");

         when K_Sequence =>
            null;

         when K_Struct =>
            Put_Line (CU, "type " & Ada_Name (Node)
                      & " is record");
            Inc_Indent (CU);

            declare
               It   : Node_Iterator;
               Member_Node : N_Root_Acc;
            begin
               Init (It, Members (Node));
               while not Is_End (It) loop
                  Member_Node := Get_Node (It);
                  Next (It);
                  Gen_Node_Stubs_Spec (CU, Member_Node);

               end loop;
            end;

            Dec_Indent (CU);
            Put_Line (CU, "end record;");

         when K_ValueBase =>
            null;
         when K_Native =>
            null;

         when K_Object =>
            null;
         when K_Any =>
            null;
         when K_Void =>
            null;

         when K_Fixed =>

            raise Program_Error;

            --  XXX This mapping shall be used for a
            --  {fixed} note created by the expander, NOT
            --  for the original (anonymous) <fixed_type_spec>.

            --  Put (CU, "delta 10 ** -(");
            --  Gen_Node_Stubs_Spec (CU, N_Root_Acc (Scale (Node)));
            --  Put (CU, ") digits ");
            --  Gen_Node_Stubs_Spec (CU, N_Root_Acc (Digits_Nb (Node)));

         when others =>
            Gen_Node_Default (CU, Node);
      end case;

   end Gen_Node_Stubs_Spec;

   procedure Gen_Node_Stubs_Body
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         --  Scopes

         when
           K_Repository |
           K_Module     |
           K_Interface  =>
            null;

         when K_Forward_Interface =>
            null;

         -----------------
         -- Value types --
         -----------------

         when K_ValueType =>
            null;
         when K_Forward_ValueType =>
            null;
         when K_Boxed_ValueType =>
            null;
         when K_State_Member =>
            null;
         when K_Initializer =>
            null;

         ----------------
         -- Operations --
         ----------------

         when K_Operation =>

            declare
               O_Name : constant String
                 := Ada_Name (Node);
               Response_Expected : constant Boolean
                 := not Is_Oneway (Node);
            begin
               Add_With (CU, "CORBA");
               Add_With (CU, "Broca.GIOP");

               New_Line (CU);
               Put_Line (CU, O_Name
                         & "_Operation : constant CORBA.Identifier");
               Put_Line (CU, "  := CORBA.To_CORBA_String ("""
                         & O_Name & """);");

               Gen_Operation_Profile (CU, Node);
               New_Line (CU);
               Put_Line (CU, "is");
               Inc_Indent (CU);
               Put_Line (CU, "Handler : Broca.GIOP.Request_Handler;");
               Put_Line (CU, "Send_Request_Result : "
                         & "Broca.GIOP.Send_Request_Result_Type;");
               Dec_Indent (CU);
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "loop");
               Inc_Indent (CU);
               Put_Line (CU, "Broca.GIOP.Send_Request_Marshall");
               Put_Line (CU, "  (Handler, Broca.Object.Object_Ptr");
               Put_Line (CU, "   (Get (Self)), "
                         & Response_Expected'Img
                         & ", " & O_Name & "_Operation);");
               --  XXX Marshall in and inout params
               Put_Line (CU, "--  Marshall in and inout arguments.");
               Put_Line (CU, "Broca.GIOP.Send_Request_Send");
               Put_Line (CU, "  (Handler, Broca.Object.Object_Ptr");
               Put_Line (CU, "   (Get (Self)), "
                         & Response_Expected'Img
                         & ", Send_Request_Result);");
               Put_Line (CU, "case Send_Request_Result is");
               Inc_Indent (CU);
               Put_Line (CU, "when Broca.GIOP.Sr_Reply =>");
               Inc_Indent (CU);
               --  XXX Unmarshall out, inout params and return value
               Put_Line (CU, "--  Unmarshall inout and out parameters.");
               Put_Line (CU, "--  Unmarshall return value.");
               Dec_Indent (CU);
               Put_Line (CU, "when Broca.GIOP.Sr_No_Reply =>");
               Inc_Indent (CU);
               --  XXX ??? What's this ? FIXME.
               Put_Line (CU, "raise Program_Error;");
               Dec_Indent (CU);
               Put_Line (CU, "when Broca.GIOP.Sr_User_Exception =>");
               Inc_Indent (CU);
               --  XXX NOT IMPLEMENTED YET! TODO!
               Put_Line (CU, "raise Program_Error;");
               Dec_Indent (CU);
               Put_Line (CU, "when Broca.GIOP.Sr_Forward =>");
               Inc_Indent (CU);
               Put_Line (CU, "null;");
               Dec_Indent (CU);
               Dec_Indent (CU);
               Put_Line (CU, "end case;");
               Dec_Indent (CU);
               Put_Line (CU, "end loop;");
               Dec_Indent (CU);
               Put_Line (CU, "end " & O_Name & ";");
            end;

         when others =>
            null;
      end case;
   end Gen_Node_Stubs_Body;

   procedure Gen_Node_Stream_Spec
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         when K_Exception =>
            --  ???
            null;

         when
           K_Interface |
           K_Enum      |
           K_Union     |
           K_Struct    =>
            declare
               Type_Name : constant String
                 := Ada_Type_Name (Node);
            begin
               New_Line (CU);
               Gen_Marshall_Profile (CU, Type_Name);
               Put_Line (CU, ";");
               Gen_Unmarshall_Profile (CU, Type_Name);
               Put_Line (CU, ";");
            end;

         when K_Type_Declarator =>

            declare
               Is_Interface : constant Boolean
                 := Is_Interface_Type (T_Type (Node));
            begin
               if not Is_Interface then

                  declare
                     It   : Node_Iterator;
                     Decl_Node : N_Root_Acc;
                  begin
                     Init (It, Declarators (Node));
                     while not Is_End (It) loop
                        Decl_Node := Get_Node (It);
                        Next (It);

                        New_Line (CU);
                        Gen_Marshall_Profile
                          (CU, Ada_Name (Decl_Node));
                        Put_Line (CU, ";");
                        Gen_Unmarshall_Profile
                          (CU, Ada_Name (Decl_Node));
                        Put_Line (CU, ";");
                     end loop;
                  end;
               end if;
            end;

         when others =>
            null;
      end case;

   end Gen_Node_Stream_Spec;

   procedure Gen_Operation_Profile
     (CU : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         when K_Operation =>
            --  Subprogram name

            New_Line (CU);
            if Get_Kind (Operation_Type (Node).all) = K_Void then
               Put (CU, "procedure ");
            else
               Put (CU, "function ");
            end if;

            Put (CU, Ada_Name (Node));

            --  Formals

            New_Line (CU);
            Put (CU, "  (Self : in Ref");
            Inc_Indent (CU);

            declare
               It   : Node_Iterator;
               P_Node : N_Root_Acc;
            begin

               Init (It, Parameters (Node));
               while not Is_End (It) loop
                  P_Node := Get_Node (It);
                  Next (It);

                  Put_Line (CU, ";");
                  Gen_Operation_Profile (CU, P_Node);
               end loop;

               Put (CU, ")");
               Dec_Indent (CU);
            end;

            --  Return type

            if Get_Kind (Operation_Type (Node).all) /= K_Void then
               New_Line (CU);
               --  XXX Add_With for Operation_Type (Node).
               Put (CU, "  return "
                    & Ada_Type_Name (Operation_Type (Node)));
            end if;

         when K_Param =>

            Gen_Operation_Profile
              (CU, N_Root_Acc (Declarator (Node)));
            case Mode (Node) is
               when Mode_In =>
                  Put (CU, " : in ");
               when Mode_Out =>
                  Put (CU, " : out ");
               when Mode_Inout =>
                  Put (CU, " : in out ");
            end case;
            --  XXX Add_With for Param_Type (Node)
            Gen_Operation_Profile (CU, Param_Type (Node));

         when others =>
            Gen_Node_Default (CU, Node);

      end case;
   end Gen_Operation_Profile;

   procedure Gen_Array_Iterator
     (CU               : in out Compilation_Unit;
      Array_Name       : String;
      Array_Dimensions : Natural;
      Stmt_Template    : String)
   is
      Indices_Pos : Natural := Stmt_Template'Last + 1;
   begin
      for I in Stmt_Template'Range loop
         if Stmt_Template (I) = '%' then
            Indices_Pos := I;
            exit;
         end if;
      end loop;

      pragma Assert (Indices_Pos in Stmt_Template'Range);

      declare
         Stmt_Prefix : constant String
           := Stmt_Template
           (Stmt_Template'First .. Indices_Pos - 1);
         Stmt_Suffix : constant String
           := Stmt_Template
           (Indices_Pos + 1 .. Stmt_Template'Last);
      begin
         for Dimen in 1 .. Array_Dimensions loop
            declare
               DImg : constant String
                 := Dimen'Img;
               D : constant String
                 := DImg (DImg'First + 1 .. DImg'Last);
            begin
               Put_Line
                 (CU, "for I_" & D
                  & " in " & Array_Name & "'Range ("
                  & D & ") loop");
               Inc_Indent (CU);
            end;
         end loop;

         Put_Line (CU, Stmt_Prefix);
         Put (CU, "  (");
         for Dimen in 1 .. Array_Dimensions loop
            declare
               DImg : constant String
                 := Dimen'Img;
               D : constant String
                 := DImg (DImg'First + 1 .. DImg'Last);
            begin
               if Dimen /= 1 then
                  Put (CU, ", ");
               end if;
               Put (CU, "I_" & D);
            end;
         end loop;
         Put_Line (CU, ") " & Stmt_Suffix);
         for Dimen in 1 .. Array_Dimensions loop
            Dec_Indent (CU);
            Put_Line (CU, "end loop;");
         end loop;
      end;
   end Gen_Array_Iterator;

   procedure Gen_Node_Stream_Body
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         when K_Exception =>
            --  ???
            null;

         when K_Struct =>

            declare
               S_Name : constant String
                 := Ada_Name (Node);
            begin
               New_Line (CU);
               Gen_Marshall_Profile (CU, S_Name);
               Put_Line (CU, " is");
               Put_Line (CU, "begin");
               Inc_Indent (CU);

               declare
                  It   : Node_Iterator;
                  Member_Node : N_Root_Acc;
               begin
                  Init (It, Members (Node));
                  while not Is_End (It) loop
                     Member_Node := Get_Node (It);
                     Next (It);

                     --  XXX Add_With for M_Type (Member_Node)
                     --  marshalling subprograms.

                     declare
                        DIt   : Node_Iterator;
                        Decl_Node : N_Root_Acc;
                     begin
                        Init (DIt, Decl (Member_Node));
                        while not Is_End (DIt) loop
                           Decl_Node := Get_Node (DIt);
                           Next (DIt);

                           Put_Line (CU, "Marshall (Stream, Val."
                                     & Ada_Name (Decl_Node)
                                     & ");");
                        end loop;
                     end;
                  end loop;
               end;

               Dec_Indent (CU);
               Put_Line (CU, "end Marshall;");

               New_Line (CU);
               Gen_Unmarshall_Profile (CU, S_Name);
               New_Line (CU);
               Put_Line (CU, " is");
               Inc_Indent (CU);
               Put_Line (CU, "Returns : " & S_Name & ";");
               Dec_Indent (CU);
               Put_Line (CU, "begin");
               Inc_Indent (CU);

               declare
                  It   : Node_Iterator;
                  Member_Node : N_Root_Acc;
               begin
                  Init (It, Members (Node));
                  while not Is_End (It) loop
                     Member_Node := Get_Node (It);
                     Next (It);

                     declare
                        DIt   : Node_Iterator;
                        Decl_Node : N_Root_Acc;
                     begin
                        Init (DIt, Decl (Member_Node));
                        while not Is_End (DIt) loop
                           Decl_Node := Get_Node (DIt);
                           Next (DIt);

                           Put_Line (CU, "Returns."
                                     & Ada_Name (Decl_Node)
                                     & " := Unmarshall (Stream);");
                        end loop;
                     end;

                  end loop;
               end;

               Dec_Indent (CU);
               Put_Line (CU, "end Unmarshall;");
            end;

         when K_Union =>

            declare
               U_Name : constant String
                 := Ada_Name (Node);
            begin
               New_Line (CU);
               Gen_Marshall_Profile (CU, U_Name);
               Put_Line (CU, " is");
               Put_Line (CU, "begin");
               Inc_Indent (CU);

               --  XXX Add_With for marshalling of
               --  Switch_Type (Node).

               Put_Line (CU, "Marshall (Stream, Val.Switch);");
               Put_Line (CU, "case Val.Switch is");
               Inc_Indent (CU);

               declare
                  It   : Node_Iterator;
                  Case_Node : N_Root_Acc;
                  Has_Default : Boolean := False;
               begin
                  Init (It, Cases (Node));
                  while not Is_End (It) loop
                     Case_Node := Get_Node (It);
                     Next (It);

                     New_Line (CU);
                     Gen_When_Clause (CU, Case_Node, Has_Default);
                     Inc_Indent (CU);
                     --  XXX Add_With for marshalling of
                     --  Case_Type (Case_Node);
                     Put_Line (CU, "Marshall (Stream, Val."
                               & Ada_Name
                               (N_Root_Acc (Case_Decl (Case_Node)))
                               & ");");
                     Dec_Indent (CU);
                  end loop;

                  if not Has_Default then
                     Gen_When_Others_Clause (CU);
                  end if;
               end;

               Dec_Indent (CU);
               Put_Line (CU, "end case;");
               Dec_Indent (CU);
               Put_Line (CU, "end Marshall;");

               New_Line (CU);
               Gen_Unmarshall_Profile (CU, U_Name);
               New_Line (CU);
               Put_Line (CU, " is");
               Inc_Indent (CU);
               Put_Line (CU, "Switch : "
                         & Ada_Type_Name (Switch_Type (Node))
                         & ";");
               Dec_Indent (CU);
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "Switch := Unmarshall (Stream);");
               New_Line (CU);
               Put_Line (CU, "declare");
               Inc_Indent (CU);
               Put_Line (CU, "Returns : " & U_Name & " (Switch);");
               Dec_Indent (CU);
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "case Val.Switch is");
               Inc_Indent (CU);

               declare
                  It   : Node_Iterator;
                  Case_Node : N_Root_Acc;
                  Has_Default : Boolean := False;
               begin
                  Init (It, Cases (Node));
                  while not Is_End (It) loop
                     Case_Node := Get_Node (It);
                     Next (It);

                     New_Line (CU);
                     Gen_When_Clause (CU, Case_Node, Has_Default);
                     Inc_Indent (CU);
                     Put_Line (CU, "Returns."
                               & Ada_Name
                               (N_Root_Acc (Case_Decl (Case_Node)))
                               & " := Unmarshall (Stream);");
                     Dec_Indent (CU);

                  end loop;
                  if not Has_Default then
                     Gen_When_Others_Clause (CU);
                  end if;
               end;

               Dec_Indent (CU);
               Put_Line (CU, "end case;");
               Dec_Indent (CU);
               Put_Line (CU, "end Unmarshall;");
            end;

         when K_Enum =>

            declare
               E_Name : constant String
                 := Ada_Name (Node);
            begin
               Add_With (CU, "CORBA");
               Add_With (CU, "Broca.CDR", Use_It => True);

               New_Line (CU);
               Gen_Marshall_Profile (CU, E_Name);
               Put_Line (CU, " is");
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "Marshall");
               Put_Line (CU, "  (Stream,");
               Put_Line (CU, "   CORBA.Unsigned_Long ("
                         & E_Name & "'Pos (Val)));");
               Dec_Indent (CU);
               Put_Line (CU, "end Marshall;");

               New_Line (CU);
               Gen_Unmarshall_Profile (CU, E_Name);
               Put_Line (CU, " is");
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "return " & E_Name
                         &"'Val");
               Put_Line
                 (CU,
                  "  (CORBA.Unsigned_Long'(Unmarshall (Stream));");
               Dec_Indent (CU);
               Put_Line (CU, "end Unmarshall;");
            end;

         when K_Type_Declarator =>

            declare
               Is_Interface : constant Boolean
                 := Is_Interface_Type (T_Type (Node));
            begin
               if not Is_Interface then

                  declare
                     Base_Type_Name : String
                       := Ada_Name (T_Type (Node));

                     It   : Node_Iterator;
                     Decl_Node : N_Root_Acc;
                  begin
                     --  XXX Add_With for
                     --  <Scope (Base_Type_Node)>.Stream;

                     Init (It, Declarators (Node));
                     while not Is_End (It) loop
                        Decl_Node := Get_Node (It);
                        Next (It);

                        declare
                           Type_Name : constant String
                             := Ada_Name (Decl_Node);
                           Array_Dimensions : constant Natural
                             := Length (Array_Bounds (Decl_Node));
                        begin
                           New_Line (CU);
                           Gen_Marshall_Profile
                             (CU, Type_Name);
                           Put_Line (CU, " is");
                           Put_Line (CU, "begin");
                           Inc_Indent (CU);
                           if Array_Dimensions = 0 then
                              Put_Line (CU, "Marshall");
                              Put_Line (CU, "  (Stream,");
                              Put_Line (CU, "   "
                                        & Base_Type_Name
                                        & " (Val));");
                           else
                              Gen_Array_Iterator
                                (CU, "Val", Array_Dimensions,
                                 "Marshall (Stream, Val %);");
                           end if;
                           Dec_Indent (CU);
                           Put_Line (CU, "end Marshall;");

                           New_Line (CU);
                           Gen_Unmarshall_Profile
                             (CU, Type_Name);
                           if Array_Dimensions = 0 then
                              Put_Line (CU, " is");
                              Put_Line (CU, "begin");
                              Inc_Indent (CU);
                              Put_Line (CU, "return " & Type_Name);
                              Put_Line (CU, "  (" & Base_Type_Name & "'");
                              Put_Line (CU, "   (Unmarshall (Stream)));");
                           else
                              New_Line (CU);
                              Put_Line (CU, "is");
                              Inc_Indent (CU);
                              Put_Line (CU, "Returns : " & Type_Name & ";");
                              Dec_Indent (CU);
                              Put_Line (CU, "begin");
                              Inc_Indent (CU);

                              Gen_Array_Iterator
                                (CU, "Returns", Array_Dimensions,
                                 "Returns % := Unmarshall (Stream);");
                           end if;
                           Put_Line (CU, "return Returns;");

                           Dec_Indent (CU);
                           Put_Line (CU, "end Unmarshall;");
                        end;
                     end loop;
                  end;
               end if;
            end;

         when K_Interface =>
            declare
               I_Name : constant String
                 := Ada_Name (Node);
            begin
               New_Line (CU);
               Gen_Marshall_Profile (CU, I_Name);
               Put_Line (CU, " is");
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "Marshall_Reference (Stream, Val);");
               Dec_Indent (CU);
               Put_Line (CU, "end Marshall;");

               New_Line (CU);
               Gen_Unmarshall_Profile (CU, I_Name);
               Put_Line (CU, " is");
               Inc_Indent (CU);
               Put_Line (CU, "New_Ref : Ref;");
               Dec_Indent (CU);
               Put_Line (CU, "begin");
               Inc_Indent (CU);
               Put_Line (CU, "Unmarshall_Reference (Stream, New_Ref);");
               Put_Line (CU, "return New_Ref;");
               Dec_Indent (CU);
               Put_Line (CU, "end Unmarshall;");
            end;

         when others =>
            null;
      end case;

   end Gen_Node_Stream_Body;

   procedure Gen_Node_Default
     (CU   : in out Compilation_Unit;
      Node : N_Root_Acc) is
   begin
      case Get_Kind (Node.all) is

         when K_Scoped_Name =>

            declare
               Denoted_Entity : constant N_Named_Acc
                 := Value (Node);
            begin
               case Get_Kind (Denoted_Entity.all) is
                  when
                    K_Forward_Interface |
                    K_Interface         =>
                     Add_With
                       (CU, Ada_Name (N_Root_Acc (Denoted_Entity)));
                  when others =>
                     --  XXX FIXME Add with for scope containing
                     --  Denoted_Entity.
                     null;
               end case;

               Put (CU, Ada_Type_Name (Node));
               --  In this context, a usage occurence of a
               --  scoped name is always denoting a type.
            end;

         when K_Declarator =>
            Put (CU, Ada_Name (Node));
            --  A simple or complex (array) declarator.

         --  Base types
         when K_Simple_Type'Range =>
            Add_With (CU, "CORBA");
            Put (CU, Ada_Type_Name (Node));

         when K_Enumerator =>
            Put (CU, Ada_Name (Node));

         when K_Or =>                   --  Binary operators.
            null;
         when K_Xor =>
            null;
            --        when K_And =>
            --        when K_Sub =>
            --        when K_Add =>
            --        when K_Shr =>
            --        when K_Shl =>
            --        when K_Mul =>
            --        when K_Div =>
            --        when K_Mod =>
            --        when K_Id =>                   --  Unary operators.
            --        when K_Neg =>
            --        when K_Not =>
            --        when K_Lit_Integer =>          --  Literals.
            --        when K_Lit_Floating_Point =>
            --        when K_Lit_Fixed_Point =>
            --        when K_Lit_Char =>
            --        when K_Lit_Wchar =>
         when K_Lit_String =>
            null;
            --        when K_Lit_Wstring =>
            --        when K_Lit_True =>
            --        when K_Lit_False =>

         when others =>
            null;
      end case;
   end Gen_Node_Default;

   procedure Gen_Marshall_Profile
     (CU        : in out Compilation_Unit;
      Type_Name : in String) is
   begin
      Add_With (CU, "Broca.Buffers", Use_It => True);
      Put_Line (CU, "procedure Marshall");
      Put_Line (CU, "  (Buffer : access Buffer_Type;");
      Put      (CU, "   Val    : in " & Type_Name & ")");
   end Gen_Marshall_Profile;

   procedure Gen_Unmarshall_Profile
     (CU        : in out Compilation_Unit;
      Type_Name : in String) is
   begin
      Add_With (CU, "Broca.Buffers", Use_It => True);
      Put_Line (CU, "function Unmarshall");
      Put_Line (CU, "  (Buffer : access Buffer_Type)");
      Put      (CU, "  return " & Type_Name);
   end Gen_Unmarshall_Profile;

   function Ada_Type_Name
     (Node : N_Root_Acc)
     return String
   is
      NK : constant Node_Kind
        := Get_Kind (Node.all);
   begin
      case NK is
         when K_Interface =>
            return Ada_Name (Node) & ".Ref";
         when
           K_Enum   |
           K_Union  |
           K_Struct =>
            return Ada_Name (Node);
         when K_Scoped_Name =>
            return Ada_Type_Name
              (N_Root_Acc (N_Named_Acc'(Value (Node))));

         when K_Short =>
            return "CORBA.Short";

         when K_Long =>
            return "CORBA.Long";

         when K_Long_Long =>
            return "CORBA.Long_Long";

         when K_Unsigned_Short =>
            return "CORBA.Unsigned_Short";

         when K_Unsigned_Long =>
            return "CORBA.Unsigned_Long";

         when K_Unsigned_Long_Long =>
            return "CORBA.Unsigned_Long_Long";

         when K_Char =>
            return "CORBA.Char";

         when K_Wide_Char =>
            return "CORBA.Wide_Char";

         when K_Boolean =>
            return "CORBA.Boolean";

         when K_Float =>
            return "CORBA.Float";

         when K_Double =>
            return "CORBA.Double";

         when K_Long_Double =>
            return "CORBA.Long_Double";

         when K_String =>
            return "CORBA.String";

         when K_Wide_String =>
            return "CORBA.Wide_String";

         when K_Octet =>
            return "CORBA.Octet";

         when others =>
            --  Improper use: node N is not
            --  mapped to an Ada type.

            Put_Line ("ATN: " & NK'Img);
            raise Program_Error;
      end case;
   end Ada_Type_Name;

end Ada_Be.Idl2Ada;
