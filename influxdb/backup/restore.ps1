$title = 'InfluxDb instance choice for the restore.'
$instance = (Get-Location).Path.Split("\")[5]
$question = "Are you sure you want to restore on the instance $instance ?"
$choices = '&Yes', '&No'
$token = "1pCSFNkGgpilCavHt7ZCjkqabjKKa16VdROtvvy1qhD9E5Gi5i4TpRDYDxI8LEQ0yoMlg9Nr9bL6vg5T6Ac7dA=="

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1);
$containerName = 'sandbox-influxdb-1';
$organisation = 'GCM';
$bucket = 'AssetManagement'

if ($decision -eq 0) 
{
    Write-Host "Start the restore process."

    $backupDestinationPath = "I:/My Drive/influxdb/backup/data.zip"
    $restoredDataFolder = "$PSScriptRoot\data";
    Expand-Archive -Path $backupDestinationPath -DestinationPath $restoredDataFolder -Force
    $restoredFolderName = Get-ChildItem -Path $restoredDataFolder -Depth 0 | Select-Object -ExpandProperty Name

    $deleteBucketCommand = "influx bucket delete -name $bucket --org $organisation --token $token"
    Write-Host "Start the delete of bucket $bucket in docker container."
    docker exec  --tty $containerName '/bin/bash' -c $deleteBucketCommand
    Write-Host "End the delete of bucket $bucket in docker container."
    
    $restoreCommand = "influx restore '/etc/backup/data/$restoredFolderName' --host 'http://localhost:8086' --org $organisation --token '$token'";

    Write-Host "Start the restore in docker container."
    docker exec  --tty $containerName '/bin/bash' -c $restoreCommand
    Write-Host "End the restore in docker container."

    Write-Host "Start the cleaning of the restore data folder."
    Remove-Item -Recurse -Path $restoredDataFolder -Force -Verbose
    Write-Host "End the cleaning of the restore data folder."

    Write-Host "End the backup process."
} 
else 
{
    Write-Host "The restore is cancelled by the user."
}