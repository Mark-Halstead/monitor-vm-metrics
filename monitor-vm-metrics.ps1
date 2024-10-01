# Prompt the user for necessary inputs
$subscriptionId = Read-Host -Prompt "Enter your Azure Subscription ID"
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
$vmName = Read-Host -Prompt "Enter the VM name"

# Prompt for the time range (in hours) to retrieve the metrics
$hoursAgo = Read-Host -Prompt "Enter the time range (in hours) to retrieve metrics from (e.g., 1 for last hour)"
$timeGrainMinutes = Read-Host -Prompt "Enter the time grain in minutes for metric aggregation (e.g., 1, 5, or 15)"

# Set the desired subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Get the VM resource ID
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
$vmResourceId = $vm.Id

# Calculate the time range for the metrics
$startTime = (Get-Date).AddHours(-[int]$hoursAgo)
$endTime = Get-Date

# Convert time grain into a TimeSpan object
$timeGrain = New-TimeSpan -Minutes $timeGrainMinutes

# Retrieve CPU Usage metrics
$cpuUsage = Get-AzMetric -ResourceId $vmResourceId `
    -TimeGrain $timeGrain `
    -StartTime $startTime `
    -EndTime $endTime `
    -MetricName "Percentage CPU"

# Retrieve Disk Read IOPS metrics
$diskReadOps = Get-AzMetric -ResourceId $vmResourceId `
    -TimeGrain $timeGrain `
    -StartTime $startTime `
    -EndTime $endTime `
    -MetricName "Disk Read Operations/Sec"

# Retrieve Disk Write IOPS metrics
$diskWriteOps = Get-AzMetric -ResourceId $vmResourceId `
    -TimeGrain $timeGrain `
    -StartTime $startTime `
    -EndTime $endTime `
    -MetricName "Disk Write Operations/Sec"

# Display the CPU Usage metrics
Write-Host "`nCPU Usage (Percentage):"
$cpuUsage.Data | ForEach-Object {
    Write-Host ("Timestamp: {0}, Average CPU: {1}%" -f $_.TimeStamp, $_.Average)
}

# Display Disk Read IOPS
Write-Host "`nDisk Read Operations per Second:"
$diskReadOps.Data | ForEach-Object {
    Write-Host ("Timestamp: {0}, Disk Read Ops: {1}" -f $_.TimeStamp, $_.Average)
}

# Display Disk Write IOPS
Write-Host "`nDisk Write Operations per Second:"
$diskWriteOps.Data | ForEach-Object {
    Write-Host ("Timestamp: {0}, Disk Write Ops: {1}" -f $_.TimeStamp, $_.Average)
}
