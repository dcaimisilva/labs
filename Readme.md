## Step1:

## Step2: Which AWS services or tools you leverage? WAF and GuardDuty

## Why?
There are several ways and powerful tools that can be used and work together to provide a security solution. In terms of HTTPS, what comes to mind is having a Web Application Firewall (WAF) that helps protect our web applications from web exploits and has the ability to create security rules to filter out malicious traffic.
As I mentioned, we can use many services and tools, but one tool I have used in the past is GuardDuty. It provides proactive threat detection by monitoring the AWS environment for suspicious activity. It analyzes network traffic, DNS data, and can also be used to detect potential attacks on your HTTPS traffic.

## How would you go about implementing it?
There are several ways and powerful tools that can be used together to provide a security solution. In terms of HTTPS, one tool that comes to mind is WAF. It helps protect web applications from web exploits and allows us to create security rules to filter out malicious traffic.

Another tool that can be used is GuardDuty, which provides proactive threat detection. It monitors the AWS environment for suspicious activity, analyzes network traffic, DNS data, and can also detect potential attacks on HTTPS traffic.

To implement these two applications, I would suggest following these specific steps:

WAF:

Enable AWS WAF on our account and configure it to work with our services such as EC2 instances, Application Load Balancer, or API Gateway, depending on our application architecture.
Define and create custom WAF rules to filter and block malicious traffic.
Configure Access Control Lists (ACLs) for each rule.
Enable logging to capture information and store it in a destination like S3, for example.


GuardDuty:
Enable GuardDuty at the AWS account level to cover all regions and services within the account, if required.
GuardDuty provides a dashboard to check findings, and you can also set up notifications.
Integrate GuardDuty with other services like CloudWatch to trigger actions based on specific findings.
The implementation details may vary depending on the environment setup and the level of detail you want to capture. These steps serve as a starting point for configuring and utilizing WAF and GuardDuty effectively

## Step3:

## Step4:











## Ref materials used to complete the scripting steps (5,6 & 7)
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_host
https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2.html
https://registry.terraform.io/modules/terraform-aws-modules/elb/aws/latest
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb