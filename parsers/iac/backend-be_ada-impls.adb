with Namet; use Namet;

with Frontend.Nodes;  use Frontend.Nodes;
with Frontend.Nutils;

with Backend.BE_Ada.IDL_To_Ada;  use Backend.BE_Ada.IDL_To_Ada;
with Backend.BE_Ada.Nodes;       use Backend.BE_Ada.Nodes;
with Backend.BE_Ada.Nutils;      use Backend.BE_Ada.Nutils;
with Backend.BE_Ada.Runtime;     use Backend.BE_Ada.Runtime;
with Backend.BE_Ada.Expand;      use Backend.BE_Ada.Expand;
with Backend.BE_Ada.Stubs;

package body Backend.BE_Ada.Impls is

   package FEN renames Frontend.Nodes;
   package BEN renames Backend.BE_Ada.Nodes;
   package FEU renames Frontend.Nutils;

   --  This function is used in the case of local interfaces to override the
   --  Is_A function of the abstract pparent type
   function Is_A_Spec (E : Node_Id) return Node_Id;

   package body Package_Spec is

      procedure Visit_Attribute_Declaration
        (E       : Node_Id;
         Binding : Boolean := True);
      procedure Visit_Interface_Declaration (E : Node_Id);
      procedure Visit_Module (E : Node_Id);
      procedure Visit_Operation_Declaration
        (E       : Node_Id;
         Binding : Boolean := True);
      procedure Visit_Specification (E : Node_Id);

      -----------
      -- Visit --
      -----------

      procedure Visit (E : Node_Id) is
      begin
         case FEN.Kind (E) is
            when K_Attribute_Declaration =>
               Visit_Attribute_Declaration (E);

            when K_Interface_Declaration =>
               Visit_Interface_Declaration (E);

            when K_Module =>
               Visit_Module (E);

            when K_Operation_Declaration =>
               Visit_Operation_Declaration (E);

            when K_Specification =>
               Visit_Specification (E);

            when others =>
               null;
         end case;
      end Visit;

      ---------------------------------
      -- Visit_Attribute_Declaration --
      ---------------------------------

      procedure Visit_Attribute_Declaration
        (E       : Node_Id;
         Binding : Boolean := True)
      is
         N          : Node_Id;
         R          : Node_Id;
         A          : Node_Id;
         Parameter  : Node_Id;
         Parameters : List_Id;
      begin
         Set_Impl_Spec;
         A := First_Entity (Declarators (E));
         while Present (A) loop
            Set_Impl_Spec;
            N := Stub_Node (BE_Node (Identifier (A)));

            if No (N) then
               raise Program_Error;
            end if;

            Parameters := New_List (K_Parameter_Profile);
            Parameter := Make_Parameter_Specification
              (Make_Defining_Identifier (PN (P_Self)),
               Make_Access_Type_Definition
               (Map_Impl_Type (Scope_Entity (Identifier (A)))));
            Append_Node_To_List (Parameter, Parameters);
            R := Copy_Node (Defining_Identifier (N));
            R := Make_Subprogram_Specification
              (R, Parameters, Copy_Designator (Return_Type (N)));
            Append_Node_To_List (R, Visible_Part (Current_Package));
            if Binding then
               Bind_FE_To_Impl (Identifier (A), R);
            end if;

            if not Is_Readonly (E) then
               N := Next_Node (Stub_Node (BE_Node (Identifier (A))));
               Parameters := New_List (K_Parameter_Profile);
               Parameter := Make_Parameter_Specification
                 (Make_Defining_Identifier (PN (P_Self)),
                  Make_Access_Type_Definition
                  (Map_Impl_Type (Scope_Entity (Identifier (A)))));
               Append_Node_To_List (Parameter, Parameters);
               R := Next_Node (First_Node (Parameter_Profile (N)));
               Parameter := Make_Parameter_Specification
                 (Copy_Node (Defining_Identifier (R)),
                  Copy_Designator (Parameter_Type (R)),
                  BEN.Parameter_Mode (R));
               Append_Node_To_List (Parameter, Parameters);
               R := Copy_Node (Defining_Identifier (N));
               R := Make_Subprogram_Specification
                 (R, Parameters, No_Node);
               Append_Node_To_List (R, Visible_Part (Current_Package));
               Link_BE_To_FE (R, Identifier (A));
            end if;

            A := Next_Entity (A);
         end loop;
      end Visit_Attribute_Declaration;

      ---------------------------------
      -- Visit_Interface_Declaration --
      ---------------------------------

      procedure Visit_Interface_Declaration (E : Node_Id) is
         N       : Node_Id;
         I       : Node_Id;
         D       : Node_Id;
         L       : List_Id;
         P       : Node_Id;
      begin
         --  No Impl package is generated for an abstract interface
         if FEN.Is_Abstract_Interface (E) then
            return;
         end if;

         N := BEN.Parent (Type_Def_Node (BE_Node (Identifier (E))));
         Push_Entity (BEN.IDL_Unit (Package_Declaration (N)));
         Set_Impl_Spec;

         --  Handling the case of inherited interfaces.
         L := Interface_Spec (E);
         if FEU.Is_Empty (L) then
            P := Map_Impl_Type_Ancestor (E);
         else
            P := Expand_Designator
              (Impl_Node
               (BE_Node
                (Identifier
                 (Reference
                  (First_Entity
                   (L))))));
         end if;

         --  The Object (or LocalObject) type

         I := Map_Impl_Type (E);
         N := Make_Full_Type_Declaration
           (I, Make_Derived_Type_Definition
            (Subtype_Indication    => P,
             Is_Private_Extention => True));
         Bind_FE_To_Impl (Identifier (E), N);
         Append_Node_To_List
           (N, Visible_Part (Current_Package));

         --  The Object_Ptr type

         D := New_Node (K_Designator);
         Set_Defining_Identifier (D, Copy_Node (I));
         N := Make_Full_Type_Declaration
           (Make_Defining_Identifier (TN (T_Object_Ptr)),
            Make_Access_Type_Definition
            (Make_Type_Attribute (D, A_Class),
             Is_All => True));
         Append_Node_To_List
           (N, Visible_Part (Current_Package));

         --  The record type definition

         I := Copy_Node (I);
         Set_Str_To_Name_Buffer
           ("Insert components to hold the state"
            & " of the implementation object.");
         N := Make_Ada_Comment (Name_Find);
         N := Make_Full_Type_Declaration
           (I, Make_Derived_Type_Definition
            (Subtype_Indication    => P,
             Record_Extension_Part =>
               Make_Record_Definition
             (Make_List_Id (N, New_Node (K_Null_Statement)))));
         Append_Node_To_List
           (N, Private_Part (Current_Package));
         N := First_Entity (Interface_Body (E));
         while Present (N) loop
            Visit (N);
            N := Next_Entity (N);
         end loop;

         --  In case of multiple inheritence, generate the mappings for
         --  the operations and attributes of the parents except the first one.
         Map_Inherited_Entities_Specs
           (Current_interface    => E,
            Visit_Operation_Subp => Visit_Operation_Declaration'Access,
            Visit_Attribute_Subp => Visit_Attribute_Declaration'Access,
            Impl                 => True);

         --  The Is_A spec in the case of local interfaces

         if Is_Local_Interface (E) then
            N := Is_A_Spec (E);
            Append_Node_To_List
              (N, Visible_Part (Current_Package));
         end if;

         Pop_Entity;
      end Visit_Interface_Declaration;

      ------------------
      -- Visit_Module --
      ------------------

      procedure Visit_Module (E : Node_Id) is
         D : Node_Id;
      begin
         Push_Entity (Stub_Node (BE_Node (Identifier (E))));
         D := First_Entity (Definitions (E));
         while Present (D) loop
            Visit (D);
            D := Next_Entity (D);
         end loop;
         Pop_Entity;
      end Visit_Module;

      ---------------------------------
      -- Visit_Operation_Declaration --
      ---------------------------------

      procedure Visit_Operation_Declaration
        (E       : Node_Id;
         Binding : Boolean := True)
      is
         Stub       : Node_Id;
         Subp_Spec  : Node_Id;
         Profile    : List_Id;
         Stub_Param : Node_Id;
         Impl_Param : Node_Id;
         Returns    : Node_Id := No_Node;
         Type_Designator : Node_Id;

      begin
         Stub := Stub_Node (BE_Node (Identifier (E)));
         Set_Impl_Spec;
         Profile := New_List (K_Parameter_Profile);

         --  Create a dispatching parameter

         Impl_Param := Make_Parameter_Specification
           (Make_Defining_Identifier (PN (P_Self)),
            Make_Access_Type_Definition
            (Map_Impl_Type (Scope_Entity (Identifier (E)))));
         Append_Node_To_List (Impl_Param, Profile);

         Stub_Param := Next_Node (First_Node (Parameter_Profile (Stub)));
         while Present (Stub_Param) loop
            Type_Designator := Copy_Designator (Parameter_Type (Stub_Param));
            Impl_Param := Make_Parameter_Specification
              (Copy_Node (Defining_Identifier (Stub_Param)),
               Type_Designator,
               BEN.Parameter_Mode (Stub_Param));
            Append_Node_To_List (Impl_Param, Profile);
            Stub_Param := Next_Node (Stub_Param);
         end loop;

         if Present (Return_Type (Stub)) then
            Returns := Copy_Designator (Return_Type (Stub));
         end if;

         Set_Impl_Spec;
         Subp_Spec := Make_Subprogram_Specification
           (Copy_Node (Defining_Identifier (Stub)), Profile, Returns);
         Append_Node_To_List (Subp_Spec, Visible_Part (Current_Package));

         if Binding then
            Bind_FE_To_Impl (Identifier (E), Subp_Spec);
         end if;
      end Visit_Operation_Declaration;

      -------------------------
      -- Visit_Specification --
      -------------------------

      procedure Visit_Specification (E : Node_Id) is
         Definition : Node_Id;
      begin
         Push_Entity (Stub_Node (BE_Node (Identifier (E))));
         Definition := First_Entity (Definitions (E));
         while Present (Definition) loop
            Visit (Definition);
            Definition := Next_Entity (Definition);
         end loop;
         Pop_Entity;
      end Visit_Specification;

   end Package_Spec;

   package body Package_Body is

      procedure Visit_Attribute_Declaration (E : Node_Id);
      procedure Visit_Interface_Declaration (E : Node_Id);
      procedure Visit_Module (E : Node_Id);
      procedure Visit_Operation_Declaration (E : Node_Id);
      procedure Visit_Specification (E : Node_Id);

      -----------
      -- Visit --
      -----------

      procedure Visit (E : Node_Id) is
      begin
         case FEN.Kind (E) is
            when K_Attribute_Declaration =>
               Visit_Attribute_Declaration (E);

            when K_Interface_Declaration =>
               Visit_Interface_Declaration (E);

            when K_Module =>
               Visit_Module (E);

            when K_Operation_Declaration =>
               Visit_Operation_Declaration (E);

            when K_Specification =>
               Visit_Specification (E);

            when others =>
               null;
         end case;
      end Visit;

      ---------------------------------
      -- Visit_Attribute_Declaration --
      ---------------------------------

      procedure Visit_Attribute_Declaration (E : Node_Id) is
         N          : Node_Id;
         A          : Node_Id;
         Subp_Spec  : Node_Id;
         D          : List_Id;
         S          : List_Id;
      begin
         Set_Impl_Body;
         A := First_Entity (Declarators (E));
         while Present (A) loop
            Subp_Spec := Impl_Node (BE_Node (Identifier (A)));
            D := New_List (K_List_Id);
            S := New_List (K_List_Id);

            if No (Subp_Spec) then
               raise Program_Error;
            end if;

            N := Make_Subprogram_Call
              (Make_Defining_Identifier (GN (Pragma_Warnings)),
               Make_List_Id
               (RE (RE_Off)));
            N := Make_Pragma_Statement (N);
            Append_Node_To_List (N, D);

            N := Make_Object_Declaration
              (Defining_Identifier =>
                 Make_Defining_Identifier (PN (P_Result)),
               Object_Definition =>
                 Copy_Designator (Return_Type (Subp_Spec)));
            Append_Node_To_List (N, D);

            N := Make_Subprogram_Call
              (Make_Defining_Identifier (GN (Pragma_Warnings)),
               Make_List_Id
               (RE (RE_On)));
            N := Make_Pragma_Statement (N);
            Append_Node_To_List (N, D);

            N := Make_Return_Statement
              (Make_Defining_Identifier (PN (P_Result)));
            Append_Node_To_List (N, S);
            N := Make_Subprogram_Implementation
              (Subp_Spec, D, S);
            Append_Node_To_List (N, Statements (Current_Package));

            if not Is_Readonly (E) then
               Subp_Spec := Next_Node (Subp_Spec);
               N := Make_Subprogram_Implementation
                 (Subp_Spec, No_List, No_List);
               Append_Node_To_List (N, Statements (Current_Package));
            end if;

            A := Next_Entity (A);
         end loop;
      end Visit_Attribute_Declaration;

      ---------------------------------
      -- Visit_Interface_Declaration --
      ---------------------------------

      procedure Visit_Interface_Declaration (E : Node_Id) is
         N       : Node_Id;
      begin
         --  No Impl package is generated for an abstract interface
         if FEN.Is_Abstract_Interface (E) then
            return;
         end if;

         N := BEN.Parent (Type_Def_Node (BE_Node (Identifier (E))));
         Push_Entity (BEN.IDL_Unit (Package_Declaration (N)));
         Set_Impl_Body;

         --  First of all we add a with clause for the Skel package to force
         --  the skeleton elaboration (only in the case wether this package
         --  exists of course)
         if not FEN.Is_Local_Interface (E) then
            Add_With_Package
              (Expand_Designator
               (Skeleton_Package
                (Current_Entity)));
         end if;

         N := First_Entity (Interface_Body (E));
         while Present (N) loop
            Visit (N);
            N := Next_Entity (N);
         end loop;
         --  In case of multiple inheritence, generate the mappings for
         --  the operations and attributes of the parents except the first one.
         Map_Inherited_Entities_Bodies
           (Current_interface    => E,
            Visit_Operation_Subp => Visit_Operation_Declaration'Access,
            Visit_Attribute_Subp => Visit_Attribute_Declaration'Access,
            Impl                 => True);

         --  For local interfaces, th body of the Is_A function

         if Is_Local_Interface (E) then
            N := Stubs.Local_Is_A_Body (E, Is_A_Spec (E));
            Append_Node_To_List (N, Statements (Current_Package));
         end if;

         Pop_Entity;
      end Visit_Interface_Declaration;

      ------------------
      -- Visit_Module --
      ------------------

      procedure Visit_Module (E : Node_Id) is
         D : Node_Id;
      begin
         Push_Entity (Stub_Node (BE_Node (Identifier (E))));
         D := First_Entity (Definitions (E));
         while Present (D) loop
            Visit (D);
            D := Next_Entity (D);
         end loop;
         Pop_Entity;
      end Visit_Module;

      ---------------------------------
      -- Visit_Operation_Declaration --
      ---------------------------------

      procedure Visit_Operation_Declaration (E : Node_Id) is
         Stub       : Node_Id;
         Subp_Spec  : Node_Id;
         Returns    : Node_Id := No_Node;
         D          : constant List_Id := New_List (K_List_Id);
         S          : constant List_Id := New_List (K_List_Id);
         N          : Node_Id;
      begin
         Stub := Stub_Node (BE_Node (Identifier (E)));
         Subp_Spec := Impl_Node (BE_Node (Identifier (E)));

         if Present (Return_Type (Stub)) then
            Returns := Copy_Designator (Return_Type (Stub));
            if Kind (Returns) = K_Attribute_Designator then
               Returns := Prefix (Returns);
            end if;

            N := Make_Subprogram_Call
              (Make_Defining_Identifier (GN (Pragma_Warnings)),
               Make_List_Id
               (RE (RE_Off)));
            N := Make_Pragma_Statement (N);
            Append_Node_To_List (N, D);

            N := Make_Object_Declaration
              (Defining_Identifier =>
                 Make_Defining_Identifier (PN (P_Result)),
               Object_Definition =>
                 Returns);
            Append_Node_To_List (N, D);

            N := Make_Subprogram_Call
              (Make_Defining_Identifier (GN (Pragma_Warnings)),
               Make_List_Id
               (RE (RE_On)));
            N := Make_Pragma_Statement (N);
            Append_Node_To_List (N, D);

            N := Make_Return_Statement
              (Make_Defining_Identifier (PN (P_Result)));
            Append_Node_To_List (N, S);
         end if;

         Set_Impl_Body;
         N := Make_Subprogram_Implementation
           (Subp_Spec, D, S);
         Append_Node_To_List (N, Statements (Current_Package));
      end Visit_Operation_Declaration;

      -------------------------
      -- Visit_Specification --
      -------------------------

      procedure Visit_Specification (E : Node_Id) is
         Definition : Node_Id;
      begin
         Push_Entity (Stub_Node (BE_Node (Identifier (E))));
         Definition := First_Entity (Definitions (E));
         while Present (Definition) loop
            Visit (Definition);
            Definition := Next_Entity (Definition);
         end loop;
         Pop_Entity;
      end Visit_Specification;
   end Package_Body;

   ---------------
   -- Is_A_Spec --
   ---------------

   function Is_A_Spec (E : Node_Id) return Node_Id is
      N       : Node_Id;
      Profile : List_Id;
      Param   : Node_Id;
   begin
      Profile := New_List (K_Parameter_Profile);

      Param := Make_Parameter_Specification
        (Make_Defining_Identifier (PN (P_Self)),
         Make_Access_Type_Definition (Map_Impl_Type (E)));
      Append_Node_To_List (Param, Profile);

      Param := Make_Parameter_Specification
        (Make_Defining_Identifier (PN (P_Logical_Type_Id)),
         RE (RE_String_2));
      Append_Node_To_List (Param, Profile);

      N := Make_Subprogram_Specification
        (Make_Defining_Identifier (SN (S_Is_A)),
         Profile,
         RE (RE_Boolean_1));
      return N;
   end Is_A_Spec;
end Backend.BE_Ada.Impls;