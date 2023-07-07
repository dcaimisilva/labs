## Write a PowerShell Script to automate EC2 provisioning with a specific AMI, Security group, and Key Pair ##
## Make sure to execute this cmdlet first 'Install-Module -Name AWSPowerShell' ##


# Prompt for user input
$amiId = Read-Host -Prompt "Enter the AMI ID"
$instanceType = Read-Host -Prompt "Enter the instance type (e.g., t2.micro)"
$vpcId = Read-Host -Prompt "Enter the VPC ID"
$subnetId = Read-Host -Prompt "Enter the subnet ID"
$keyPairName = Read-Host -Prompt "Enter the key pair name"
$emailAddress = Read-Host -Prompt "Enter the email address for SNS notification"
$cpuThreshold = Read-Host -Prompt "Enter the CPU threshold for the CloudWatch alarm"

# Create EC2 instance
$instance = New-EC2Instance -ImageId $amiId -InstanceType $instanceType -KeyName $keyPairName -SecurityGroupIds $securityGroupId -VPCId $vpcId -SubnetId $subnetId

# Get the instance ID and public IP address
$instanceId = $instance.Instances.InstanceId
$publicIpAddress = $instance.Instances.PublicIpAddress

Write-Host "EC2 instance provisioned successfully."
Write-Host "Instance ID: $instanceId"
Write-Host "Public IP Address: $publicIpAddress"

# Create CloudWatch alarm
$alarmName = "CPUUtilizationAlarm-$instanceId"
$alarmDescription = "Alarm triggered when CPU utilization exceeds $cpuThreshold%"
$metricName = "CPUUtilization"
$namespace = "AWS/EC2"
$alarmActions = New-SNSNotificationConfiguration -TopicArn $snsTopicArn
$alarmActions.Enabled = $true

New-CWMetricAlarm -AlarmName $alarmName -AlarmDescription $alarmDescription -MetricName $metricName `
    -Namespace $namespace -Statistic Average -Period 300 -Threshold $cpuThreshold `
    -ComparisonOperator GreaterThanThreshold -ActionsEnabled $true -AlarmActions $alarmActions `
    -Dimensions @(New-CWDimension -Name "InstanceId" -Value $instanceId)

Write-Host "CloudWatch alarm created successfully."

# Subscribe email address to SNS topic
$snsTopicArn = (Get-SNSTopic -DisplayName "EC2InstanceNotifications").TopicArn
Subscribe-SNSTopic -TopicArn $snsTopicArn -Protocol email -Endpoint $emailAddress

Write-Host "Email address subscribed to SNS topic successfully."