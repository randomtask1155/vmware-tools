# Usage 

* Install the vmware powershell CLI module on your windows host
  * https://my.vmware.com/group/vmware/get-download?downloadGroup=PCLI600R1
* Run `orphaned-disk.ps1` using Powershell ISE or direct via powershell
* the powershell script will output something that looks like this

```
@{DS=LUN01; Path=[Datastor01] a63aa458-8c34-058c-892c-000e1e53a1f0/; File=vm01.vmdk; Size=6450839552; ModDate=10/12/2016 9:00:18 PM}
```

* Then convert the output into a list of file paths we can build commands from.  Make sure to replace the datastore name in the sed `Path=` with yours

```
cat orphaned.vmdks | awk -F ";" '{print $2, $3}'   | sed s/' Path=\[Datastor01\] '//g | sed s/'  File='//g >paths.txt
```

* paths.txt should look like this

```
a63aa458-8c34-058c-892c-000e1e53a1f0/vm01.vmdk
a63aa458-8c34-058c-892c-000e1e53a1f0/vm02.vmdk
a63aa458-8c34-058c-892c-000e1e53a1f0/vm03.vmdk
.
.
```

* Generate the curl commands with `build-delete.py`

```
ubuntu@host:~$ ./build-delete.py --help
usage: build-delete.py [-h] [--vcenter VCENTER] [--user USER]
                       [--password PASSWORD] [--vcparams VCPARAMS]
                       [--file FILE]

optional arguments:
  -h, --help           show this help message and exit
  --vcenter VCENTER    hostname of vcenter server
  --user USER          vcenter username
  --password PASSWORD  vcenter password
  --vcparams VCPARAMS  url params like '?dcPath=Datacenter&dsName=Datastore'
  --file FILE          path to file to process
```

  * optionally you can export the username and password for vcenter

```
export VCENTERUSER="username"
export VCENTERPASSWORD='password'
```

  * Example run 

```
./build-delete.py --vcenter vcenter-host1.domain --vcparams "?dcPath=Datacenter&dsName=Datastore01" --file paths.txt
```

  * Example generated command

```
curl -v -k -u 'username:password' -X DELETE "https://vcenter-host1.domain/folder/a63aa458-8c34-058c-892c-000e1e53a1f0/vm01.vmdk?dcPath=Datacenter&dsName=Datastore01" 2>&1 | egrep "HTTP\/1.1"
```

