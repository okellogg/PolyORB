------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                                   X E                                    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 1995-2013, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
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

--  This package contains the routines used by the parser to handle
--  tokens and nodes corresponding to the configuration file.

with XE_Types; use XE_Types;

package XE is

   --  Several names are reserved keywords. For each of these names, a key
   --  is associated in the hash table. This allows to retrieve the nature
   --  of the name and especially its type. The key (an integer) is in one
   --  of the following ranges and therefore, the name corresponds to the
   --  image of an element in the enumeration type.

   --------------
   -- Keywords --
   --------------

   type Token_Type is new Int range 100 .. 126;

   Tok_Unknown         : constant Token_Type := 100;  -- (0)  Identifier
   Tok_String_Literal  : constant Token_Type := 101;  -- (1)  string literal
   Tok_Numeric_Literal : constant Token_Type := 102;  -- (2)  numeric literal
   Tok_Identifier      : constant Token_Type := 103;  -- (3)  identifer
   Tok_Dot             : constant Token_Type := 104;  -- (4)  .
   Tok_Apostrophe      : constant Token_Type := 105;  -- (5)  '
   Tok_Left_Paren      : constant Token_Type := 106;  -- (6)  (
   Tok_Right_Paren     : constant Token_Type := 107;  -- (7)  )
   Tok_Comma           : constant Token_Type := 108;  -- (8)  ,
   Tok_Colon_Equal     : constant Token_Type := 109;  -- (9)  :=
   Tok_Colon           : constant Token_Type := 110;  -- (10) :
   Tok_Configuration   : constant Token_Type := 111;  -- (11) CONFIGURATION
   Tok_Pragma          : constant Token_Type := 112;  -- (12) PRAGMA
   Tok_Procedure       : constant Token_Type := 113;  -- (13) PROCEDURE
   Tok_Is              : constant Token_Type := 114;  -- (14) IS
   Tok_In              : constant Token_Type := 115;  -- (15) IN
   Tok_For             : constant Token_Type := 116;  -- (16) FOR
   Tok_Use             : constant Token_Type := 117;  -- (17) USE
   Tok_Function        : constant Token_Type := 118;  -- (18) FUNCTION
   Tok_End             : constant Token_Type := 119;  -- (19) END
   Tok_Begin           : constant Token_Type := 120;  -- (20) BEGIN
   Tok_Null            : constant Token_Type := 121;  -- (21) NULL
   Tok_Semicolon       : constant Token_Type := 122;  -- (22) ;
   Tok_Arrow           : constant Token_Type := 123;  -- (23) =>
   Tok_Return          : constant Token_Type := 124;  -- (24) return
   Tok_EOF             : constant Token_Type := 125;  -- (25) end of file
   Tok_Reserved        : constant Token_Type := 126;  -- (26) Ada keywords

   type Token_List_Type is array (Positive range <>) of Token_Type;

   Reserved : array (Token_Type) of Boolean := (others => False);

   --------------------
   -- Attribute type --
   --------------------

   type Attribute_Type is new Int range 200 .. 217;

   Attribute_Unknown               : constant Attribute_Type := 200;
   Attribute_Host                  : constant Attribute_Type := 201;
   Attribute_Directory             : constant Attribute_Type := 202;
   Attribute_Main                  : constant Attribute_Type := 203;
   Attribute_Command_Line          : constant Attribute_Type := 204;
   Attribute_Termination           : constant Attribute_Type := 205;
   Attribute_Leader                : constant Attribute_Type := 206;
   Attribute_PFilter               : constant Attribute_Type := 207;
   Attribute_CFilter               : constant Attribute_Type := 208;
   Attribute_Task_Pool             : constant Attribute_Type := 209;
   Attribute_Reconnection          : constant Attribute_Type := 210;
   Attribute_Protocol              : constant Attribute_Type := 211;
   Attribute_Storage               : constant Attribute_Type := 212;
   Attribute_Passive               : constant Attribute_Type := 213;
   Attribute_Priority              : constant Attribute_Type := 214;
   Attribute_Allow_Light_PCS       : constant Attribute_Type := 215;
   Attribute_Environment_Variables : constant Attribute_Type := 216;
   Attribute_ORB_Tasking_Policy    : constant Attribute_Type := 217;

   -----------------
   -- Pragma type --
   -----------------

   type Pragma_Type is new Int range 300 .. 308;

   Pragma_Unknown       : constant Pragma_Type := 300;
   Pragma_Boot_Location : constant Pragma_Type := 301;
   Pragma_Import        : constant Pragma_Type := 302;
   Pragma_Name_Server   : constant Pragma_Type := 303;
   Pragma_Priority      : constant Pragma_Type := 304;
   Pragma_Reg_Filter    : constant Pragma_Type := 305;
   Pragma_Remote_Shell  : constant Pragma_Type := 306;
   Pragma_Starter       : constant Pragma_Type := 307;
   Pragma_Version       : constant Pragma_Type := 308;

   ------------------------
   -- Import Method type --
   ------------------------

   type Import_Method_Type is new Int range 341 .. 343;

   Ada_Import   : constant Import_Method_Type := 341;
   Shell_Import : constant Import_Method_Type := 342;
   None_Import  : constant Import_Method_Type := 343;

   ---------------------
   -- Predefined type --
   ---------------------

   type Predefined_Type is new Int range 401 .. 415;

   Pre_Type_Partition   : constant Predefined_Type := 401;
   Pre_Type_Channel     : constant Predefined_Type := 402;
   Pre_Type_Boolean     : constant Predefined_Type := 403;
   Pre_Type_Integer     : constant Predefined_Type := 404;
   Pre_Type_String      : constant Predefined_Type := 405;
   Pre_Type_Strings     : constant Predefined_Type := 406;
   Pre_Type_Entity      : constant Predefined_Type := 407;
   Pre_Type_Convention  : constant Predefined_Type := 408;
   Pre_Type_Ada_Unit    : constant Predefined_Type := 409;
   Pre_Type_Function    : constant Predefined_Type := 410;
   Pre_Type_Procedure   : constant Predefined_Type := 411;
   Pre_Type_Task_Pool   : constant Predefined_Type := 412;
   Pre_Type_Location    : constant Predefined_Type := 413;
   Pre_Type_Locations   : constant Predefined_Type := 414;
   Pre_Type_Name_Server : constant Predefined_Type := 415;

   ----------------------
   -- Termination type --
   ----------------------

   type Termination_Type is new Int range 500 .. 503;

   No_Termination       : constant Termination_Type := 500;
   Local_Termination    : constant Termination_Type := 501;
   Global_Termination   : constant Termination_Type := 502;
   Deferred_Termination : constant Termination_Type := 503;
   Termination_Img      : array (Termination_Type) of Name_Id;

   ------------------
   -- Boolean type --
   ------------------

   type Boolean_Type is new Int range 600 .. 602;

   BMaybe : constant Boolean_Type := 600;
   BFalse : constant Boolean_Type := 601;
   BTrue  : constant Boolean_Type := 602;

   Boolean_Img : array (Boolean_Type) of Name_Id;

   -----------------------
   -- Reconnection type --
   -----------------------

   type Reconnection_Type is new Int range 700 .. 703;

   No_Reconnection     : constant Reconnection_Type := 700;
   Reject_On_Restart   : constant Reconnection_Type := 701;
   Block_Until_Restart : constant Reconnection_Type := 702;
   Fail_Until_Restart  : constant Reconnection_Type := 703;
   Reconnection_Img    : array (Reconnection_Type) of Name_Id;

   --------------------------
   -- Priority Policy type --
   --------------------------

   type Priority_Policy_Type is new Int range 800 .. 802;

   No_Priority_Policy  : constant Priority_Policy_Type := 800;
   Server_Declared     : constant Priority_Policy_Type := 801;
   Client_Propagated   : constant Priority_Policy_Type := 802;
   Priority_Policy_Img : array (Priority_Policy_Type) of Name_Id;

   -----------------------------
   -- ORB tasking policy type --
   -----------------------------

   type ORB_Tasking_Policy_Type is new Int range 900 .. 903;

   No_ORB_Tasking_Policy  : constant ORB_Tasking_Policy_Type := 900;
   Thread_Pool            : constant ORB_Tasking_Policy_Type := 901;
   Thread_Per_Session     : constant ORB_Tasking_Policy_Type := 902;
   Thread_Per_Request     : constant ORB_Tasking_Policy_Type := 903;
   ORB_Tasking_Policy_Img : array (ORB_Tasking_Policy_Type) of Name_Id;

   ----------------------
   -- Name server type --
   ----------------------

   type Name_Server_Type is new Int range 950 .. 954;

   No_Name_Server  : constant Name_Server_Type := 950;
   None_NS         : constant Name_Server_Type := 951;
   Embedded_NS     : constant Name_Server_Type := 952;
   Standalone_NS   : constant Name_Server_Type := 953;
   Multicast_NS    : constant Name_Server_Type := 954;
   Name_Server_Img : array (Name_Server_Type) of Name_Id;

   ------------------
   -- Tasking type --
   ------------------

   type Tasking_Type is new Int range 1000 .. 1003;

   Unknown_Tasking : constant Tasking_Type := 1000;
   PCS_Tasking     : constant Tasking_Type := 1001;
   User_Tasking    : constant Tasking_Type := 1002;
   No_Tasking      : constant Tasking_Type := 1003;
   Tasking_Img     : array (Tasking_Type) of Name_Id;

   -------------
   -- Node Id --
   -------------

   type Type_Id          is new Node_Id;
   type Variable_Id      is new Node_Id;
   type Component_Id     is new Node_Id;
   type Parameter_Id     is new Node_Id;
   type Attribute_Id     is new Node_Id;
   type Statement_Id     is new Node_Id;
   type Subprogram_Id    is new Node_Id;
   type Configuration_Id is new Node_Id;

   Null_Node  : constant Node_Id := Node_Id'First;
   First_Node : constant Node_Id := Null_Node + 1;

   NN                 : constant Node_Id          := Null_Node;
   Null_Type          : constant Type_Id          := Type_Id (NN);
   Null_Variable      : constant Variable_Id      := Variable_Id (NN);
   Null_Parameter     : constant Parameter_Id     := Parameter_Id (NN);
   Null_Component     : constant Component_Id     := Component_Id (NN);
   Null_Subprogram    : constant Subprogram_Id    := Subprogram_Id (NN);
   Null_Configuration : constant Configuration_Id := Configuration_Id (NN);

   --------------------
   -- Standard nodes --
   --------------------

   Configuration_Node      : Configuration_Id;
   Configuration_File_Name : File_Name_Type := No_File_Name;

   Partition_Type_Node       : Type_Id;
   Channel_Type_Node         : Type_Id;
   Boolean_Type_Node         : Type_Id;
   Integer_Type_Node         : Type_Id;
   String_Type_Node          : Type_Id;
   String_List_Type_Node     : Type_Id;
   Convention_Type_Node      : Type_Id;
   Ada_Unit_Type_Node        : Type_Id;
   Subprogram_Type_Node      : Type_Id;
   Main_Procedure_Type_Node  : Type_Id;
   Host_Function_Type_Node   : Type_Id;
   Task_Pool_Type_Node       : Type_Id;
   Location_Type_Node        : Type_Id;
   Locations_Type_Node       : Type_Id;
   Priority_Policy_Type_Node : Type_Id;
   Name_Server_Type_Node     : Type_Id;

   Pragma_Starter_Node       : Subprogram_Id;
   Pragma_Import_Node        : Subprogram_Id;
   Pragma_Boot_Location_Node : Subprogram_Id;
   Pragma_Version_Node       : Subprogram_Id;
   Pragma_Reg_Filter_Node    : Subprogram_Id;
   Pragma_Priority_Node      : Subprogram_Id;
   Pragma_Remote_Shell_Node  : Subprogram_Id;
   Pragma_Name_Server_Node   : Subprogram_Id;

   Infinite : constant  Int := Int'Last;
   --  Size of an unconstrained array

   ---------------------------
   -- Internal System Names --
   ---------------------------

   Function_Name_Id    : Name_Id;
   Procedure_Name_Id   : Name_Id;
   Return_Name_Id      : Name_Id;

   type Context_Type is record
      Last_Decl : Node_Id;
      Last_Node : Node_Id;
      Conf_Node : Node_Id;
      Anonymous : Int;
   end record;

   ----------------------
   -- Node Subprograms --
   ----------------------

   procedure Add_Configuration_Declaration
     (Configuration_Node : Configuration_Id;
      Declaration_Node   : Node_Id);
   --  Add a configuration node to the list of configuration. Cannot
   --  be inlined.

   procedure Add_Subprogram_Parameter
     (Subprogram_Node : Subprogram_Id;
      Parameter_Node  : Parameter_Id);
   pragma Inline (Add_Subprogram_Parameter);
   --  Add a parameter node to the subprogram parameter list.

   procedure Add_Type_Component
     (Type_Node       : Type_Id;
      Component_Node  : Component_Id);
   pragma Inline (Add_Type_Component);
   --  Add a component to the type component list.

   procedure Add_Variable_Component
     (Variable_Node   : Variable_Id;
      Component_Node  : Component_Id);
   pragma Inline (Add_Variable_Component);
   --  Add a component to the variable component list.

   procedure Component_Is_Initialized
     (Component_Node : Component_Id;
      Is_Initialized : Boolean);
   pragma Inline (Component_Is_Initialized);
   --  Indicate whether a component is initialized or not.

   procedure Create_Component
     (Component_Node : out Component_Id;
      Component_Name : Name_Id);
   pragma Inline (Create_Component);

   procedure Create_Configuration
     (Configuration_Node : out Configuration_Id;
      Configuration_Name : Name_Id);
   pragma Inline (Create_Configuration);

   procedure Create_Parameter
     (Parameter_Node : out Parameter_Id;
      Parameter_Name : Name_Id);
   pragma Inline (Create_Parameter);

   procedure Create_Statement
     (Statement_Node : out Statement_Id;
      Statement_Name : Name_Id);
   pragma Inline (Create_Statement);

   procedure Create_Subprogram
     (Subprogram_Node : out Subprogram_Id;
      Subprogram_Name : Name_Id);
   pragma Inline (Create_Subprogram);

   procedure Create_Type
     (Type_Node : out Type_Id;
      Type_Name : Name_Id);
   pragma Inline (Create_Type);

   procedure Create_Variable
     (Variable_Node : out Variable_Id;
      Variable_Name : Name_Id);
   pragma Inline (Create_Variable);

   procedure First_Configuration_Declaration
     (Configuration_Node : Configuration_Id;
      Declaration_Node   : out Node_Id);
   --  Set to the first declaration in the configuration list. Cannot
   --  be inlined.

   procedure First_Subprogram_Parameter
     (Subprogram_Node : Subprogram_Id;
      Parameter_Node  : out Parameter_Id);
   pragma Inline (First_Subprogram_Parameter);
   --  Set to the first parameter in the subprogram parameter list.

   procedure First_Type_Component
     (Type_Node       : Type_Id;
      Component_Node  : out Component_Id);
   pragma Inline (First_Type_Component);
   --  Set to the first type component in the type component list.

   procedure First_Variable_Component
     (Variable_Node   : Variable_Id;
      Component_Node  : out Component_Id);
   pragma Inline (First_Variable_Component);
   --  Set to the first component of the variable component list. The
   --  variable component list can be different from the type
   --  component list when the type is an unconstrained array. In this
   --  case, each array element is considered as a component.

   function Get_Array_Component_Type
     (Type_Node : Type_Id) return Type_Id;
   pragma Inline (Get_Array_Component_Type);
   --  When the type is a component array type, this function returns the
   --  type of a component.

   function Get_Attribute_Kind
     (Component_Node : Component_Id) return Attribute_Type;
   pragma Inline (Get_Attribute_Kind);
   --  A type or a variable is a set of components and of attributes. This
   --  function returns the attribute type, Attribute_Unknown when it is
   --  not an attribute.

   function Get_Array_Length
     (Variable_Node : Variable_Id) return Int;
   pragma Inline (Get_Array_Length);
   --  When the type of Variable_Node is an unconstrained array, this
   --  function returns the current length of the array. Otherwise, it
   --  returns the length of the array type.

   function Get_Array_Length
     (Type_Node : Type_Id) return Int;
   pragma Inline (Get_Array_Length);
   --  When the type is a record type, return 0. For a constrained
   --  array type, this function returns the length of the array
   --  type. Infinite for an unconstrained array type.

   function Get_Component_Name
     (Component : Component_Id) return Name_Id;
   pragma Inline (Get_Component_Name);

   function Get_Component_Type
     (Component_Node : Component_Id) return Type_Id;
   pragma Inline (Get_Component_Type);

   function Get_Component_Value
     (Component_Node : Component_Id) return Variable_Id;
   pragma Inline (Get_Component_Value);
   --  The component has to be initialized. This function returns the
   --  variable set as component value.

   function Get_Node_Name
     (Node : Node_Id) return Name_Id;
   pragma Inline (Get_Node_Name);

   procedure Get_Node_SLOC
     (Node  : Node_Id;
      Loc_X : out Int;
      Loc_Y : out Int);
   pragma Inline (Get_Node_SLOC);

   function Get_Parameter_Type
     (Parameter_Node : Parameter_Id) return Type_Id;
   pragma Inline (Get_Parameter_Type);

   function Get_Parameter_Value
     (Parameter_Node : Parameter_Id) return Variable_Id;
   pragma Inline (Get_Parameter_Value);
   --  This parameter has to be initialized. This function returns the
   --  variable set as parameter value.

   function Get_Pragma_Kind
     (Subprogram_Node : Subprogram_Id) return Pragma_Type;
   pragma Inline (Get_Pragma_Kind);
   --  Subprograms are used to implement pragmas and to represent some
   --  ada units (function and procedures). This function returns
   --  Pragma_Unknown when this subprogram does not implement a
   --  pragma.

   function Get_Scalar_Value
     (Variable_Node : Variable_Id) return Int;
   --  Return a scalar rather than a variable as a value.

   function Get_Subprogram_Call
     (Statement_Node  : Statement_Id) return Subprogram_Id;
   --  This statement is a procedure call. This returns a copy of the
   --  subprogram call with the initialized parameters in it.

   function Get_Token (N : Name_Id) return Token_Type;
   --  Use name key to get back the token type.

   function Get_Type_Kind
     (Type_Node : Type_Id) return Predefined_Type;
   pragma Inline (Get_Type_Kind);
   --  This function returns the predefined_type id of Type_Node.

   function Get_Variable_Name
     (Variable : Variable_Id) return Name_Id;
   pragma Inline (Get_Variable_Name);

   function Get_Variable_Type
     (Variable_Node : Variable_Id) return Type_Id;
   pragma Inline (Get_Variable_Type);

   function Get_Variable_Value
     (Variable_Node : Variable_Id) return Variable_Id;
   pragma Inline (Get_Variable_Value);
   --  Return a variable rather than a scalar as a value.

   procedure Initialize;

   function Is_Component
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Component);

   function Is_Component_Initialized
     (Component_Node : Component_Id) return Boolean;
   pragma Inline (Is_Component_Initialized);
   --  Has this component a value.

   function Is_Configuration
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Configuration);

   function Is_Parameter_Initialized
     (Parameter_Node : Parameter_Id) return Boolean;
   --  Has this parameter a value. Parameter are marked to find which
   --  parameter is missing in a subprogram call.

   function Is_Statement
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Statement);

   function Is_Subprogram
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Subprogram);

   function Is_Subprogram_A_Procedure
     (Subprogram_Node : Subprogram_Id) return Boolean;
   pragma Inline (Is_Subprogram_A_Procedure);

   function Is_Type
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Type);

   function Is_Type_Composite
     (Type_Node : Type_Id) return Boolean;
   pragma Inline (Is_Type_Composite);

   function Is_Variable
     (Node : Node_Id) return Boolean;
   pragma Inline (Is_Variable);

   function Is_Variable_Initialized
     (Variable_Node : Variable_Id) return Boolean;
   pragma Inline (Is_Variable_Initialized);

   procedure Jump_Context (Context : Context_Type);
   pragma Inline (Jump_Context);
   --  Preserve the context of the parsing process to restore it in
   --  case of failure to try another solution.

   function New_Variable_Name
     return Name_Id;
   pragma Inline (New_Variable_Name);
   --  Return an anonymous name variable which does not conflict with
   --  user names. This name is composed of a constant prefix and an
   --  index.

   function New_Component_Name
     (Variable_Node : Variable_Id) return Name_Id;
   pragma Inline (New_Component_Name);
   --  Returns an anonymous name which does not conflict with user
   --  name. This name is composed of a constant prefix and the index
   --  of the component in the variable.

   procedure Next_Configuration_Declaration
     (Declaration_Node   : in out Node_Id);
   pragma Inline (Next_Configuration_Declaration);
   --  There are two configurations : the user one and the standard
   --  one. When the next declaration is a configuration node, go into
   --  this configuration and return the next declaration node.

   procedure Next_Subprogram_Parameter
     (Parameter_Node  : in out Parameter_Id);
   pragma Inline (Next_Subprogram_Parameter);
   --  Set to the next parameter in the subprogram parameter list.

   procedure Next_Type_Component
     (Component_Node  : in out Component_Id);
   pragma Inline (Next_Type_Component);
   --  Set to the next component of type component list.

   procedure Next_Variable_Component
     (Component_Node  : in out Component_Id);
   pragma Inline (Next_Variable_Component);
   --  Set to the next component in the variable component list.

   procedure Parameter_Is_Initialized
     (Parameter_Node : Parameter_Id;
      Is_Initialized : Boolean);
   pragma Inline (Parameter_Is_Initialized);
   --  Parameter are marked to find what parameter is missing in a
   --  subprogram call.

   procedure Save_Context
     (Configuration : Configuration_Id;
      Context       : out Context_Type);
   pragma Inline (Save_Context);
   --  Save the context of the parsing process to restore it in case
   --  of failure to try another solution.

   procedure Set_Array_Component_Type
     (Type_Node : Type_Id;
      Comp_Type : Type_Id);
   pragma Inline (Set_Array_Component_Type);
   --  This type becomes an component list type. Each element is of type
   --  comp_type.

   procedure Set_Attribute_Kind
     (Component_Node : Component_Id;
      Attribute_Kind : Attribute_Type);
   pragma Inline (Set_Attribute_Kind);
   --  See Get_Attribute_Kind.

   procedure Set_Array_Length
     (Type_Node    : Type_Id;
      Array_Length : Int);
   pragma Inline (Set_Array_Length);
   --  See Get_Array_Length.

   procedure Set_Array_Length
     (Variable_Node : Variable_Id;
      Array_Length  : Int);
   pragma Inline (Set_Array_Length);
   --  See Get_Array_Length.

   procedure Set_Component_Type
     (Component_Node : Component_Id;
      Type_Node      : Type_Id);
   pragma Inline (Set_Component_Type);
   --  See Get_Component_Type.

   procedure Set_Component_Value
     (Component_Node : Component_Id;
      Value_Node     : Variable_Id);
   pragma Inline (Set_Component_Value);
   --  See Get_Component_Value.

   procedure Set_Node_SLOC
     (Node  : Node_Id;
      Loc_X : Int;
      Loc_Y : Int);
   pragma Inline (Set_Node_SLOC);

   procedure Set_Parameter_Type
     (Parameter_Node : Parameter_Id;
      Parameter_Type : Type_Id);
   pragma Inline (Set_Parameter_Type);
   --  See Get_Parameter_Type.

   procedure Set_Pragma_Kind
     (Subprogram_Node : Subprogram_Id;
      Pragma_Kind     : Pragma_Type);
   pragma Inline (Set_Pragma_Kind);
   --  See Get_Pragam_Kind.

   procedure Set_Scalar_Value
     (Variable_Node : Variable_Id;
      Scalar_Value  : Int);
   pragma Inline (Set_Scalar_Value);
   --  See Get_Scalar_Value.

   procedure Set_Subprogram_Call
     (Statement_Node  : Statement_Id;
      Subprogram_Node : Subprogram_Id);
   pragma Inline (Set_Subprogram_Call);
   --  Initiliaze this statement with a copy of the subprogram tree. This
   --  tree contains the parameters with their associated values.

   procedure Set_Token
     (N : String;
      T : Token_Type);

   procedure Set_Type_Kind
     (Type_Node : Type_Id;
      Type_Kind : Predefined_Type);
   pragma Inline (Set_Type_Kind);
   --  See Get_Type_Kind.

   procedure Set_Variable_Type
     (Variable_Node : Variable_Id;
      Variable_Type : Type_Id);
   pragma Inline (Set_Variable_Type);
   --  See Get_Variable_Type.

   procedure Set_Variable_Value
     (Variable_Node : Variable_Id;
      Value_Node    : Variable_Id);
   pragma Inline (Set_Variable_Value);
   --  See Get_Variable_Value.

   procedure Subprogram_Is_A_Procedure
     (Subprogram_Node : Subprogram_Id;
      Procedure_Node  : Boolean);
   pragma Inline (Subprogram_Is_A_Procedure);
   --  See Is_Suprogram_A_Procedure

   procedure Type_Is_Composite
     (Type_Node : Type_Id;
      Composite : Boolean);

   procedure Variable_Is_Initialized
     (Variable_Node  : Variable_Id;
      Is_Initialized : Boolean);
   pragma Inline (Variable_Is_Initialized);
   --  See Is_Variable_Initialized

   procedure Write_SLOC (Node : Node_Id);
   pragma Inline (Write_SLOC);

   --------------------------
   -- Conversion Functions --
   --------------------------

   function Convert (Item : Attribute_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Attribute_Type;
   pragma Inline (Convert);

   function Convert (Item : Pragma_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Pragma_Type;
   pragma Inline (Convert);

   function Convert (Item : Import_Method_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Import_Method_Type;
   pragma Inline (Convert);

   function Convert (Item : Predefined_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Predefined_Type;
   pragma Inline (Convert);

   function Convert (Item : Reconnection_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Reconnection_Type;
   pragma Inline (Convert);

   function Convert (Item : Termination_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Termination_Type;
   pragma Inline (Convert);

   function Convert (Item : Priority_Policy_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Priority_Policy_Type;
   pragma Inline (Convert);

   function Convert (Item : ORB_Tasking_Policy_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return ORB_Tasking_Policy_Type;
   pragma Inline (Convert);

   function Convert (Item : Name_Server_Type) return Int;
   pragma Inline (Convert);

   function Convert (Item : Int) return Name_Server_Type;
   pragma Inline (Convert);

end XE;
