
## Write a PowerShell Script to create new VPC with two subnets (Private&Public) ##
## Make sure to execute this cmdlet first 'Install-Module -Name AWSPowerShell' ##


# Prompt for user input
$vpcCidrBlock = Read-Host -Prompt "Enter the VPC CIDR block"
$publicSubnetCidrBlock = Read-Host -Prompt "Enter the public subnet CIDR block"
$privateSubnetCidrBlock = Read-Host -Prompt "Enter the private subnnet CIDR block"
$amiId = Read-Host -Prompt "Enter the AMI ID"
$instanceType = Read-Host -Prompt "Enter the instance type"
$keyPairName = Read-Host -Prompt "Enter the key pair name"
$databaseEngine = Read-Host -Prompt "Enter the database engine"
$username = Read-Host -Prompt "Enter the database username"
$password = Read-Host -Prompt "Enter the database password"
$backupRetentionPeriod = Read-Host -Prompt "Enter the backup retention period (in days)"
$databaseInstanceClass = Read-Host -Prompt "Enter the database instance class"
$databaseStorageSize = Read-Host -Prompt "Enter the database storage size"

# Create VPC
$vpc = New-EC2Vpc -CidrBlock $vpcCidrBlock

# Create public subnet
$publicSubnet = New-EC2Subnet -VpcId $vpc.VpcId -CidrBlock $publicSubnetCidrBlock

# Create private subnet
$privateSubnet = New-EC2Subnet -VpcId $vpc.VpcId -CidrBlock $privateSubnetCidrBlock

# Create internet gateway
$internetGateway = New-EC2InternetGateway
$internetGatewayId = $internetGateway.InternetGatewayId
$null = Register-EC2RouteTable -VpcId $vpc.VpcId -GatewayId $internetGatewayId

# Associate public subnet with the internet gateway
$null = Set-EC2RouteTableAssociation -RouteTableId $publicSubnet.RouteTable.RouteTableId -SubnetId $publicSubnet.SubnetId

# Create security group for EC2 instance
$securityGroup = New-EC2SecurityGroup -GroupName "EC2InstanceSecurityGroup" -VpcId $vpc.VpcId -Description "Security group for EC2 instance"
$securityGroupId = $securityGroup.GroupId

# Allow inbound SSH access
$null = Authorize-EC2SecurityGroupIngress -GroupId $securityGroupId -IpProtocol tcp -FromPort 22 -ToPort 22 -CidrIp "0.0.0.0/0"

# Create EC2 instance in the public subnet
$instance = New-EC2Instance -ImageId $amiId -InstanceType $instanceType -KeyName $keyPairName -SecurityGroupIds $securityGroupId -SubnetId $publicSubnet.SubnetId

# Create security group for RDS instance
$rdsSecurityGroup = New-EC2SecurityGroup -GroupName "RDSSecurityGroup" -VpcId $vpc.VpcId -Description "Security group for RDS instance"
$rdsSecurityGroupId = $rdsSecurityGroup.GroupId

# Allow inbound access for the database engine
$```powershell
$null = Authorize-EC2SecurityGroupIngress -GroupId $rdsSecurityGroupId -Protocol tcp -Port 3306 -SourceSecurityGroupId $securityGroupId

# Create RDS instance in the private subnet
$rdsInstance = New-RDSDBInstance -DBInstanceIdentifier "MyDBInstance" -Engine $databaseEngine -DBInstanceClass $databaseInstanceClass `
    -AllocatedStorage $databaseStorageSize -MasterUsername $username -MasterUserPassword $password `
    -VpcSecurityGroupIds $rdsSecurityGroupId -DBSubnetGroupName $privateSubnet.SubnetId `
    -BackupRetentionPeriod $backupRetentionPeriod

Write-Host "RDS instance created with ID:" $rdsInstance.DBInstanceIdentifier

# Get the public IP address of the EC2 instance
$publicIpAddress = $instance.Instances.PublicIpAddress

Write-Host "VPC and subnets created successfully."
Write-Host "EC2 instance provisioned successfully."
Write-Host "RDS instance provisioned successfully."
Write-Host "Public IP Address: $publicIpAddress"