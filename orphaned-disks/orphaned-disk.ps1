function LoadSnapin{
  param($PSSnapinName)
  if (!(Get-PSSnapin | where {$_.Name   -eq $PSSnapinName})){
    Add-pssnapin -name $PSSnapinName
  }
}

# Load PowerCLI snapin
LoadSnapin -PSSnapinName   "VMware.VimAutomation.Core"

# Variables
[string] $vCenter = "vcsa-01.haas-59.pez.pivotal.io" # vCenter FQDN
# Connect to vCenter
Connect-VIServer -Server $vCenter

$report = @()
$arrUsedDisks = Get-View -ViewType VirtualMachine | % {$_.Layout} | % {$_.Disk} | % {$_.DiskFile}
$arrDS = Get-Datastore | Sort-Object -property Name
foreach ($strDatastore in $arrDS) {
    Write-Host "Checking" $strDatastore.Name "..."
    $ds = Get-Datastore -Name $strDatastore.Name | % {Get-View $_.Id}
    $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
    $fileQueryFlags.FileSize = $true
    $fileQueryFlags.FileType = $true
    $fileQueryFlags.Modification = $true
    $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
    $searchSpec.details = $fileQueryFlags
    $searchSpec.matchPattern = "*.vmdk"
    $searchSpec.sortFoldersFirst = $true
    $dsBrowser = Get-View $ds.browser
    $rootPath = "[" + $ds.Name + "]"
    Write-Host $(Get-Date)
    $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
    Write-Host $(Get-Date)

    foreach ($folder in $searchResult)
    {
        foreach ($fileResult in $folder.File)
        {
            if ($fileResult.Path)
            {
                if (-not ($fileResult.Path.contains("ctk.vmdk"))) #Remove Change Tracking Files
                {
                    if (-not ($arrUsedDisks -contains ($folder.FolderPath.trim('/') + '/' + $fileResult.Path)))
                    {
                        $row = "" | Select DS, Path, File, Size, ModDate
                        $row.DS = $strDatastore.Name
                        $row.Path = $folder.FolderPath
                        $row.File = $fileResult.Path
                        $row.Size = $fileResult.FileSize
                        $row.ModDate = $fileResult.Modification
                        Write-Host $row
                        #$report += $row
                    }
                }
            }
        }
    }
} 
