
from test_utils import *
import sys

if not client_server(r'corba/interop/cpp/omniORB/all_types_dynclient', r'',
                     r'corba/interop/cpp/omniORB/all_types_dynserver', r''):
    fail()

