#!/usr/bin/python

import urllib
import argparse
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--vcenter", help="hostname of vcenter server")
parser.add_argument("--user", help="vcenter username")
parser.add_argument("--password", help="vcenter password")
parser.add_argument("--vcparams", help="url params like '?dcPath=Datacenter&dsName=Datastore'")
parser.add_argument("--file", help="path to file to process")
args = parser.parse_args()

if not args.file or not args.vcenter or not args.vcparams:
     print parser.format_usage()
     sys.exit(1)

vcuser = ""
vcpass = ""

if os.environ.get('VCENTERUSER') and os.environ.get('VCENTERPASSWORD'):
     vcuser = os.environ['VCENTERUSER']
     vcpass = os.environ['VCENTERPASSWORD']
else:
     vcuser = args.user
     vcpass = args.password

with open(args.file, "r") as f:
     for line in f:
	  encodedLine = urllib.pathname2url(line.rstrip())
          url = "https://" + args.vcenter + "/folder/" +  encodedLine + args.vcparams
          cmd = "curl -v -k -u '" + vcuser  + ":" + vcpass  + "' -X DELETE \"" + url  + "\" 2>&1 | egrep \"HTTP\\/1.1\""
	  print cmd


