----------------------------------------------
--  This file has been generated automatically
--  by AdaBroker (http://adabroker.eu.org/)
----------------------------------------------

with CORBA.ORB.Typecode;
with CORBA.Object;

with CORBA.Repository_Root; use CORBA.Repository_Root;
with CORBA.Repository_Root.IRObject.Impl;
with CORBA.Repository_Root.Contained;
with CORBA.Repository_Root.OperationDef;
with CORBA.Repository_Root.OperationDef.Impl;
with CORBA.Repository_Root.AttributeDef;
with CORBA.Repository_Root.AttributeDef.Impl;
with CORBA.Repository_Root.ValueMemberDef;
with CORBA.Repository_Root.ValueMemberDef.Impl;
with CORBA.Repository_Root.IDLType;
with CORBA.Repository_Root.ValueDef.Skel;
with CORBA.Repository_Root.InterfaceDef;
with CORBA.Repository_Root.InterfaceDef.Impl;
with CORBA.Repository_Root.Helper;

with Broca.Server_Tools;
with PortableServer;

package body CORBA.Repository_Root.ValueDef.Impl is

   package ValDef renames IDL_SEQUENCE_CORBA_Repository_Root_ValueDef_Forward;
   package IdSeq renames IDL_SEQUENCE_CORBA_RepositoryId;

   ------------
   --  INIT  --
   ------------
   procedure Init (Self : access Object;
                   Real_Object :
                     CORBA.Repository_Root.IRObject.Impl.Object_Ptr;
                   Def_Kind : Corba.Repository_Root.DefinitionKind;
                   Id : CORBA.RepositoryId;
                   Name : CORBA.Identifier;
                   Version : CORBA.Repository_Root.VersionSpec;
                   Defined_In : CORBA.Repository_Root.Container_Forward.Ref;
                   Contents :
                     CORBA.Repository_Root.Contained.Impl.Contained_Seq.Sequence;
                   Contained_View :  CORBA.Repository_Root.Contained.Impl.Object_Ptr;
                   IDLType_View : CORBA.Repository_Root.IDLType.Impl.Object_Ptr;
                   Supported_Interfaces : CORBA.Repository_Root.InterfaceDefSeq;
                   Initializers : CORBA.Repository_Root.InitializerSeq;
                   Base_Value : CORBA.Repository_Root.ValueDef.Ref;
                   Abstract_Base_Values : CORBA.Repository_Root.ValueDefSeq;
                   Is_Abstract : CORBA.Boolean;
                   Is_Custom : CORBA.Boolean;
                   Is_Truncatable : CORBA.Boolean) is
   begin
       Container.Impl.Init (Container.Impl.Object_Ptr (Self),
                            Real_Object,
                            Def_Kind,
                            Contents);
       Contained.Impl.Init (Contained_View,
                            Real_Object,
                            Def_Kind,
                            Id,
                            Name,
                            Version,
                            Defined_In);
       IDLType.Impl.Init (IDLType_View,
                          Real_Object,
                          Def_Kind);
       Self.Contained_View := Contained_View;
       Self.IDLType_View := IDLType_View;
       Self.Supported_Interfaces := Supported_Interfaces;
       Self.Initializers := Initializers;
       Self.Base_Value := Base_Value;
       Self.Abstract_Base_Values := Abstract_Base_Values;
       Self.Is_Abstract := Is_Abstract;
       Self.Is_Custom := Is_Custom;
       Self.Is_Truncatable := Is_Truncatable;
   end Init;

   -----------------
   --  To_Object  --
    -----------------
   function To_Object (Fw_Ref : ValueDef_Forward.Ref)
                       return Object_Ptr is
      Result : Portableserver.Servant;
   begin
      Broca.Server_Tools.Reference_To_Servant
        (ValueDef.Convert_Forward.To_Ref (Fw_Ref),
         Result);
      return ValueDef.Impl.Object_Ptr (Result);
   end To_Object;

   ------------------
   --  To_Forward  --
   ------------------
   function To_Forward (Obj : Object_Ptr)
                        return ValueDef_Forward.Ref is
      Ref : ValueDef.Ref;
   begin
      Broca.Server_Tools.Initiate_Servant (PortableServer.Servant (Obj),
                                           Ref);
      return ValueDef.Convert_Forward.To_Forward (Ref);
   end To_Forward;

   ---------------------------------
   --  To get the secondary views --
   ---------------------------------

   function Get_Contained_View (Self : access Object)
     return CORBA.Repository_Root.Contained.Impl.Object_Ptr is
   begin
      return Self.Contained_View;
   end Get_Contained_View;

   function Get_IDLType_View (Self : access Object)
     return CORBA.Repository_Root.IDLType.Impl.Object_Ptr is
   begin
      return Self.IDLType_View;
   end Get_IDLType_View;


   function get_supported_interfaces
     (Self : access Object)
     return CORBA.Repository_Root.InterfaceDefSeq
   is
   begin
      return Self.Supported_Interfaces;
   end get_supported_interfaces;


   procedure set_supported_interfaces
     (Self : access Object;
      To : in CORBA.Repository_Root.InterfaceDefSeq) is
   begin
      Self.Supported_Interfaces := To;
   end set_supported_interfaces;


   function get_initializers
     (Self : access Object)
      return CORBA.Repository_Root.InitializerSeq
   is
   begin
      return Self.Initializers;
   end get_initializers;


   procedure set_initializers
     (Self : access Object;
      To : in CORBA.Repository_Root.InitializerSeq) is
   begin
      Self.Initializers := To;
   end set_initializers;


   function get_base_value
     (Self : access Object)
     return CORBA.Repository_Root.ValueDef.Ref
   is
   begin
      return Self.Base_Value;
   end get_base_value;


   procedure set_base_value
     (Self : access Object;
      To : in CORBA.Repository_Root.ValueDef.Ref) is
   begin
      Self.Base_Value := To;
   end set_base_value;


   function get_abstract_base_values
     (Self : access Object)
     return CORBA.Repository_Root.ValueDefSeq
   is
   begin
      return Self.Abstract_Base_Values;
   end get_abstract_base_values;


   procedure set_abstract_base_values
     (Self : access Object;
      To : in CORBA.Repository_Root.ValueDefSeq) is
   begin
      Self.Abstract_Base_Values := To;
   end set_abstract_base_values;


   function get_is_abstract
     (Self : access Object)
     return CORBA.Boolean
   is
   begin
      return Self.Is_Abstract;
   end get_is_abstract;


   procedure set_is_abstract
     (Self : access Object;
      To : in CORBA.Boolean) is
   begin
      Self.Is_Abstract := To;
   end set_is_abstract;


   function get_is_custom
     (Self : access Object)
     return CORBA.Boolean
   is
   begin
      return Self.Is_Custom;
   end get_is_custom;


   procedure set_is_custom
     (Self : access Object;
      To : in CORBA.Boolean) is
   begin
      Self.Is_Custom := To;
   end set_is_custom;


   function get_is_truncatable
     (Self : access Object)
     return CORBA.Boolean
   is
   begin
      return Self.Is_Truncatable;
   end get_is_truncatable;


   procedure set_is_truncatable
     (Self : access Object;
      To : in CORBA.Boolean) is
   begin
      Self.Is_Truncatable := To;
   end set_is_truncatable;


   function is_a
     (Self : access Object;
      id : in CORBA.RepositoryId)
     return CORBA.Boolean
   is
      Result : CORBA.Boolean;
   begin

      --  Insert implementation of is_a

      return Result;
   end is_a;


   function describe_value
     (Self : access Object)
     return CORBA.Repository_Root.ValueDef.FullValueDescription
   is
      Result : CORBA.Repository_Root.ValueDef.FullValueDescription;
   begin

      --  Insert implementation of describe_value

      return Result;
   end describe_value;


   function create_value_member
     (Self : access Object;
      id : in CORBA.RepositoryId;
      name : in CORBA.Identifier;
      version : in CORBA.Repository_Root.VersionSpec;
      IDL_type : in CORBA.Repository_Root.IDLType.Ref;
      IDL_access : in CORBA.Repository_Root.Visibility)
     return CORBA.Repository_Root.ValueMemberDef.Ref
   is
   begin
      if not Check_Structure (Self, Dk_ValueMember) or
        not Check_Id (Self, Id) or
        not Check_Name (Self, Name) then
         return (CORBA.Object.Nil_Ref with null record);
      end if;
      declare
         Result : CORBA.Repository_Root.ValueMemberDef.Ref;
         Obj : ValueMemberDef.Impl.Object_Ptr := new ValueMemberDef.Impl.Object;
      begin
         --  initialization of the object
         ValueMemberDef.Impl.Init (Obj,
                                   IRObject.Impl.Object_Ptr (Obj),
                                   Dk_ValueMember,
                                   Id,
                                   Name,
                                   Version,
                                   Container.Impl.To_Forward
                                   (Container.Impl.Object_Ptr (Self)),
                                   IDL_type,
                                   IDL_access);

         --  add it to the contents field of this container
         Container.Impl.Append_To_Contents
           (Container.Impl.Object_Ptr (Self),
            Contained.Impl.To_Contained (IRObject.Impl.Object_Ptr (Obj)));

         --  activate it
         Broca.Server_Tools.Initiate_Servant (PortableServer.Servant (Obj),
                                              Result);
         return Result;
      end;
   end create_value_member;


   function create_attribute
     (Self : access Object;
      id : in CORBA.RepositoryId;
      name : in CORBA.Identifier;
      version : in CORBA.Repository_Root.VersionSpec;
      IDL_type_1 : in CORBA.Repository_Root.IDLType.Ref;
      mode : in CORBA.Repository_Root.AttributeMode)
     return CORBA.Repository_Root.AttributeDef.Ref
   is
   begin
       if not Check_Structure (Self, Dk_Attribute) or
        not Check_Id (Self, Id) or
        not Check_Name (Self, Name) then
         return (CORBA.Object.Nil_Ref with null record);
      end if;
      declare
         Result : CORBA.Repository_Root.AttributeDef.Ref;
         Obj : AttributeDef.Impl.Object_Ptr := new AttributeDef.Impl.Object;
      begin
         --  initialization of the object
         AttributeDef.Impl.Init (Obj,
                                 IRObject.Impl.Object_Ptr (Obj),
                                 Dk_Attribute,
                                 Id,
                                 Name,
                                 Version,
                                 Container.Impl.To_Forward
                                 (Container.Impl.Object_Ptr (Self)),
                                 IDL_Type_1,
                                 Mode);

         --  add it to the contents field of this container
         Container.Impl.Append_To_Contents
           (Container.Impl.Object_Ptr (Self),
            Contained.Impl.To_Contained (IRObject.Impl.Object_Ptr (Obj)));
         --  activate it
         Broca.Server_Tools.Initiate_Servant (PortableServer.Servant (Obj),
                                            Result);

         return Result;
      end;
   end create_attribute;


   function create_operation
     (Self : access Object;
      id : in CORBA.RepositoryId;
      name : in CORBA.Identifier;
      version : in CORBA.Repository_Root.VersionSpec;
      IDL_result : in CORBA.Repository_Root.IDLType.Ref;
      mode : in CORBA.Repository_Root.OperationMode;
      params : in CORBA.Repository_Root.ParDescriptionSeq;
      exceptions : in CORBA.Repository_Root.ExceptionDefSeq;
      contexts : in CORBA.Repository_Root.ContextIdSeq)
     return CORBA.Repository_Root.OperationDef.Ref
   is
   begin
      if not Check_Structure (Self, Dk_Operation) or
        not Check_Id (Self, Id) or
        not Check_Name (Self, Name) then
         return (CORBA.Object.Nil_Ref with null record);
      end if;
      declare
         Result : CORBA.Repository_Root.OperationDef.Ref;
         Obj : OperationDef.Impl.Object_Ptr := new OperationDef.Impl.Object;
      begin
         --  initialization of the object
         OperationDef.Impl.Init (Obj,
                                 IRObject.Impl.Object_Ptr (Obj),
                                 Dk_Operation,
                                 Id,
                                 Name,
                                 Version,
                                 Container.Impl.To_Forward
                                 (Container.Impl.Object_Ptr (Self)),
                                 IDL_Result,
                                 Params,
                                 Mode,
                                 Contexts,
                                 Exceptions);

         --  add it to the contents field of this container
         Container.Impl.Append_To_Contents
           (Container.Impl.Object_Ptr (Self),
            Contained.Impl.To_Contained (IRObject.Impl.Object_Ptr (Obj)));

         --  activate it
         Broca.Server_Tools.Initiate_Servant (PortableServer.Servant (Obj),
                                              Result);

         return Result;
      end;
   end create_operation;

   --------------------------------
   --  inherited from contained  --
   --------------------------------
   function get_id
     (Self : access Object)
     return CORBA.RepositoryId
   is
   begin
      return Contained.Impl.Get_Id (Self.Contained_View);
   end get_id;


   procedure set_id
     (Self : access Object;
      To : in CORBA.RepositoryId) is
   begin
      Contained.Impl.Set_Id (Self.Contained_View, To);
   end set_id;


   function get_name
     (Self : access Object)
     return CORBA.Identifier
   is
   begin
      return Contained.Impl.Get_Name (Self.Contained_View);
   end get_name;


   procedure set_name
     (Self : access Object;
      To : in CORBA.Identifier) is
   begin
      Contained.Impl.Set_Name (Self.Contained_View, To);
   end set_name;


   function get_version
     (Self : access Object)
     return CORBA.Repository_Root.VersionSpec
   is
   begin
      return Contained.Impl.Get_Version (Self.Contained_View);
   end get_version;


   procedure set_version
     (Self : access Object;
      To : in CORBA.Repository_Root.VersionSpec) is
   begin
      Contained.Impl.Set_Version (Self.Contained_View, To);
   end set_version;


   function get_defined_in
     (Self : access Object)
     return CORBA.Repository_Root.Container_Forward.Ref
   is
   begin
       return Contained.Impl.Get_Defined_In (Self.Contained_View);
   end get_defined_in;


   function get_absolute_name
     (Self : access Object)
      return CORBA.ScopedName
   is
   begin
      return Contained.Impl.Get_Absolute_Name (Self.Contained_View);
   end get_absolute_name;


   function get_containing_repository
     (Self : access Object)
     return CORBA.Repository_Root.Repository_Forward.Ref
   is
   begin
      return Contained.Impl.Get_Containing_Repository (Self.Contained_View);
   end get_containing_repository;

   function describe
     (Self : access Object)
      return CORBA.Repository_Root.Contained.Description
   is
      Result : CORBA.Repository_Root.Contained.Description;
      Desc : CORBA.Repository_Root.ValueDescription;
      Obj : Portableserver.Servant;
   begin
      Broca.Server_Tools.Reference_To_Servant (Self.Base_Value,
                                               Obj);
      Desc := (Name => Get_Name (Self),
               Id => Get_Id (Self),
               Is_Abstract => Self.Is_Abstract,
               Is_Custom => Self.Is_Custom,
               Defined_In => Contained.Impl.Get_Defined_In
               (Self.Contained_View),
               Version => Get_Version (Self),
               Supported_Interfaces => InterfaceDef.Impl.Get_RepositoryIdSeq
               (Self.Supported_Interfaces),
               Abstract_Base_Values => Get_RepositoryIdSeq
               (Self.Abstract_Base_Values),
               Is_Truncatable => Self.Is_Truncatable,
               Base_Value => Get_Id (ValueDef.Impl.Object_Ptr
                                     (Obj)));
      Result := (Kind => Get_Def_Kind (Self),
                 Value => CORBA.Repository_Root.Helper.To_Any (Desc));
      return Result;
   end describe;


   procedure move
     (Self : access Object;
      new_container : in CORBA.Repository_Root.Container_Forward.Ref;
      new_name : in CORBA.Identifier;
      new_version : in CORBA.Repository_Root.VersionSpec) is
   begin
      Contained.Impl.Move (Self.Contained_View,
                           New_Container,
                           New_Name,
                           New_Version);
   end move;


   ------------------------------
   --  inherited from IDLType  --
   ------------------------------
   function get_type
     (Self : access Object)
     return CORBA.TypeCode.Object
   is
      Val : CORBA.ValueModifier;
      Base_TC : CORBA.TypeCode.Object;
      package VMS renames IDL_SEQUENCE_CORBA_Repository_Root_ValueMember;
   begin
      if not ValueDef.Is_Nil (Self.Base_Value) then
         declare
            Obj : Portableserver.Servant;
         begin
            Broca.Server_Tools.Reference_To_Servant (Self.Base_Value,
                                                     Obj);
            Base_TC := ValueDef.Impl.Get_Type
              (ValueDef.Impl.Object_Ptr (Obj));
         end;
      else
         Base_TC := CORBA.TC_Void;
      end if;

      if Self.Is_Custom then
         Val := VTM_CUSTOM;
      elsif Self.Is_Abstract then
         Val := VTM_ABSTRACT;
      elsif Self.Is_Truncatable then
         Val := VTM_TRUNCATABLE;
      else
         Val := VTM_NONE;
      end if;
      return CORBA.ORB.Typecode.Create_Value_Tc
        (Get_Id (Self),
         Get_Name (Self),
         Val,
         Base_TC,
         -- FIXME >>>>>>>> calculate the valuememberseq...
         ValueMemberSeq (VMS.Null_Sequence));
   end get_type;

   ---------------------------
   --  Get_RepositoryIdSeq  --
   ---------------------------
   function Get_RepositoryIdSeq (ValDefSeq : ValueDefSeq)
                                 return RepositoryIdSeq
   is
      Result : RepositoryIdSeq;
      Val_Array : ValDef.Element_Array
        := ValDef.To_Element_Array (ValDef.Sequence (ValDefSeq));
   begin
      for I in Val_Array'Range loop
         declare
            Val : Object_Ptr
              := To_Object (Val_Array (I));
         begin
            IdSeq.Append (IdSeq.Sequence (Result), Get_Id (Val));
         end;
      end loop;
      return Result;
   end;

end CORBA.Repository_Root.ValueDef.Impl;











