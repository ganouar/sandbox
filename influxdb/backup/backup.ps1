if($PSScriptRoot -IMatch 'gcm_influxdb')
{
    try{
        Write-Host "Start the backup process."

        $backupDestinationPath = "I:/My Drive/influxdb/backup/data.zip"
        $backupFolder = "at_$((Get-Date).ToString('yyyy-MM-ddTHH-mm-ssZ'))"
        $command = "influx backup /etc/backup/$backupFolder --host 'http://localhost:8086' --bucket 'AssetManagement' --org 'GCM' --token 'keagC2aftG_er2vdcdrK02lX-nKPDYjvoCG-vRVhJeP70TgDd1PYSzD2O5GdBrrimtL2FJmk82pw327pZRIqwQ=='";

        Write-Host "Start the backup in docker container."
        docker exec  --tty 'gcm_influxdb-influxdb-1' '/bin/bash' -c $command
        Write-Host "End the backup in docker container."

        $hostBackupFolder = "$PSScriptRoot\$backupFolder";

        if(Test-Path -Path $hostBackupFolder)
        {
            Write-Host "Start the copy of files into $backupDestinationPath"
            Compress-Archive -Path $hostBackupFolder -DestinationPath $backupDestinationPath -Force
            Write-Host "End the copy of files into $backupDestinationPath"

            Write-Host "Start the cleaning of backup folder."
            Remove-Item -Recurse -Path $hostBackupFolder -Force
            Write-Host "End the cleaning of backup folder."
        }
        else
        {
            Write-Host "Backup inside the container failed."
        }

        Write-Host "End the backup process."
    }
    catch
    {
        Write-Host "The error : $($_.ScriptStackTrace) occured during backup."
    }
}
else
{
    Write-Host "Backup is tried on the wrong server."
}
