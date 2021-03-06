#! /usr/bin/env python
#

import sys
import re


class Node:

    nodes = {}
    children = {}

    def __init__(self, name, parent=None):
        self.name = name
        if parent:
            self.parent = parent
        elif name == "Root":
            self.parent = None
        else:
            self.parent = "Root"
        self.fields = []
        if self.parent:
            if self.parent in Node.children:
                Node.children[self.parent].append(self.name)
            else:
                Node.children[self.parent] = [self.name]
        Node.nodes[name] = self

    def add_field(self, name, type, init):
        self.fields.append((name, type, init))


def get_words(str):
    return str[0:-1].split()


def get_fields(n):
    if n.parent:
        return get_fields(Node.nodes[n.parent]) + n.fields
    else:
        return n.fields


def append(kind, name, type):
    if name in fields:
        if typess[name] != type:
            sys.stderr.write("Conflicting types for field %s\n" % name)
            sys.exit(1)
        fields[name].append(kind)
    else:
        fields[name] = [kind]
        typess[name] = type


fields = {}
typess = {}

current = None
started = 0

input = open(sys.argv[1], "r").readlines()
for i in input:
    if re.match(r"^\s*--", i):
        continue
    words = get_words(i)
    if not words:
        continue
    if not started:
        if words == ['START']:
            started = 1
            continue
        continue
    if words == ['END']:
        break
    if len(words) >= 3 and words[1] == ':':
        if len(words) == 5 and words[3] == ':=':
            current.add_field(words[0], words[2], words[4])
        else:
            current.add_field(words[0], words[2], None)
    elif len(words) > 0:
        if len(words) == 3 and words[1] == '<--':
            current = Node(words[0], words[2])
        else:
            current = Node(words[0])
    else:
        sys.stderr.write("Unknown line: %s\n" % i)
        sys.exit(1)

nodes = list(Node.nodes.keys())
nodes.sort()

types = []
spec = []
body = []

for n in nodes:
    if n == "Root":
        continue
    i = Node.nodes[n]
    types.append("K_%s" % n)
    spec.append("   --")
    spec.append("   --  %s" % n)
    spec.append("   --")
    for (name, type, init) in get_fields(i):
        append(n, name, type)
        spec.append("   --     %-25s : %s" % (name, type))
    spec.append("   --")
    spec.append("")
    spec.append("   function Make_%s (Loc : Location) return Node_Id;" % n)
    spec.append("   function Is_%s (N : Node_Id) return Boolean;" % n)
    spec.append("")
    body.append("   function Make_%s (Loc : Location) return Node_Id is" % n)
    body.append("      Node  : constant Node_Access := new Node_Type;")
    body.append("      Index : constant Node_Id     := Nodes_Table.Allocate;")
    body.append("   begin")
    body.append("      Node.Loc := Loc;")
    body.append("      Node.Kind := K_%s;" % n)
    for (name, type, init) in get_fields(i):
        if init:
            body.append("      Node.%s := %s;" % (name, init))
    body.append("      Nodes_Table.Table (Index) := Node;")
    body.append("      return Index;")
    body.append("   end Make_%s;" % n)
    body.append("")
    body.append("   function Is_%s (N : Node_Id) return Boolean is" % n)
    body.append("   begin")
    body.append("      return Kind (N) = K_%s" % n)
    if n in Node.children:
        for c in Node.children[n]:
            body.append("        or else Is_%s (N)" % (c))
    body.append("        or else False;")
    body.append("   end Is_%s;" % n)
    body.append("")

f = list(fields.keys())
f.sort()

for name in f:
    type = typess[name]
    kinds = fields[name]
    spec.append("   function %s" % (name,))
    spec.append("     (N : Node_Id) return %s;" % (type,))
    spec.append("   procedure Set_%s" % (name,))
    spec.append("     (N : Node_Id; V : %s);" % (type,))

    body.append("   function %s" % (name,))
    body.append("     (N : Node_Id) return %s" % (type,))
    body.append("   is")
    body.append("      Node : constant Node_Access := Nodes_Table.Table (N);")
    body.append("   begin")
    for k in range(len(kinds)):
        if k == 0:
            if len(kinds) == 1:
                assrt = ["      pragma Assert (Node.Kind = K_%s);" % kinds[k]]
            else:
                assrt = ["      pragma Assert (Node.Kind = K_%s" % kinds[k]]
        else:
            if k == len(kinds) - 1:
                expr = ");"
            else:
                expr = ""
            assrt.append("             or else Node.Kind = K_%s%s" %
                         (kinds[k], expr))
    body = body + assrt
    body.append("      return Node.%s;" % name)
    body.append("   end %s;" % name)
    body.append("")
    body.append("   procedure Set_%s" % (name,))
    body.append("     (N : Node_Id; V : %s)" % (type,))
    body.append("   is")
    body.append("      Node : constant Node_Access := Nodes_Table.Table (N);")
    body.append("   begin")
    body = body + assrt
    body.append("      Node.%s := V;" % name)
    body.append("   end Set_%s;" % name)
    body.append("")
    if type == "Node_List":
        spec.append("   procedure Append_Node_To_%s" % (name))
        spec.append("     (N : Node_Id; V : Node_Id);")

        body.append("   procedure Append_Node_To_%s" % (name))
        body.append("     (N : Node_Id; V : Node_Id)")
        body.append("   is")
        body.append("   begin")
        body.append("      Set_%s" % (name))
        body.append("        (N, Append_Node (%s (N), V));" % (name))
        body.append("   end Append_Node_To_%s;" % (name))
        body.append("")

    spec.append("")
# with Nodes;      use Nodes;
print("""with GNAT.Table;
with Idl_Fe.Types; use Idl_Fe.Types;

package Idl_Fe.Tree is

   type Node_Kind is""")
for n in range(len(types)):
    if n == 0:
        s = '('
    else:
        s = ' '
    if n == len(types) - 1:
        e = ');'
    else:
        e = ','
    print("      %s%s%s" % (s, types[n], e))
print("")
for i in spec:
    print(i)

print("private")
print("")
print("   type Node_Type is record")
for i in f:
    if typess[i] == "Node_Id":
        print("      %-25s : %-25s%s;" % (i, typess[i], ":= No_Node"))
    elif typess[i] == "Node_List":
        print("      %-25s : %-25s%s;" % (i, typess[i], ":= Nil_List"))
    else:
        print("      %-25s : %s%s;" % (i, typess[i], ""))
print("   end record;")
print("""
   type Node_Access is access Node_Type;

   package Nodes_Table is
      new GNAT.Table (Table_Component_Type => Node_Access,
                      Table_Index_Type     => Node_Id,
                      Table_Low_Bound      => 1,
                      Table_Initial        => 1024,
                      Table_Increment      => 100);

end Idl_Fe.Tree;""")

print("package body Idl_Fe.Tree is")
print("")
print("   use Nodes_Table;")
print("")
for i in body:
    print(i)

print("end Idl_Fe.Tree;")
