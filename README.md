# Deploying AWS S3 buckets and a lambda function with Terraform

The lambda function will be called every hour automatically by AWS cloudwatch event and will upload files to the S3 buckets.
In order to execute the code you will need to clone the repo to your local machine, have Terraform on your local machine and have an AWS account to which you have an service user for the Terraform with the proper permitions(for example you can make them as "admin"). Also the credentials for the AWS service user user must be stored on your local machine for security purposes in a separate file(example PATH to the file on a Linux OS: /home/{username}/.aws/credentials) in order Terraform to be able to access and use them.
When you are done with the above you need to run in the directory that you have cloned the repo:
```bash
terraform init
```
Then in order to see the changes that terraform will do before apply them in order review them and not to damage your existing AWS services:
```bash
terraform plan
```
Then if you are ok with the results you can proceed:
```bash
terraform apply
```

After the execution of the command successfully you can check the changes in your AWS account via the browser.