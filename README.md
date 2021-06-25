# aws-samples

**Project instructions**
Using the AWS free tier in the N. Virginia region, automate all steps necessary to complete the following exercise:



In your personal Virtual Private Cloud, create two EC2 instances using the type t2.micro.

# Instance “A”: 

  - Operating system image ami-0d5eff06f840b45e9
  - The root volume should be 9 GB in size.
  - Create an additional EBS volume
  - No encryption.
  - Volume type gp3 with 1 GB of storage.
  - File system of ext4.
  - Create the directory /dataup
  - Mount the volume.
  - Reboot the instance.

# Instance “B”:

  - Operating system image ami-08353a25e80beea3e
  - The root volume should be 9 GB in size.
 - Create two EBS volume and configure for RAID 0
  - Encrypted.
  - Volume type gp2 with 1 GB of storage.
  - File system of ext4.
  - Create the directory /datadown
  - Mount the volume.
  - Reboot the instance.

# Create an S3 bucket:
  - The bucket policy should enforce data encryption in flight.
  - The bucket should have encryption for objects at rest.



# Using the AWS CLI:

  - On instance “A” create a test file in the directory /dataup and upload it to the S3 bucket.

First Getinstance id.
Then Use aws ssm to send the script to run shell script
Execute the following command to retrieve the services running on the instance. Replace Instance-ID with ec2 instance id.

```
aws ec2 get-instance --service-id <value>
aws ssm send-command --document-name "AWS-RunShellScript" --comment "Creating Test File" --instance-ids "Instance-ID" --parameters commands="service --status-all" --region us-east-1 --output text
````

```
aws s3 cp file.txt s3://my-bucket/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=emailaddress=user@example.com
```

  -On instance “B” pull the test file from the S3 bucket to the /datadown directory.