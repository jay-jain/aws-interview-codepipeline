# CodePipeline / Terraform Example
This repository uses Terraform to create the following components:
* CodeCommit Repository
* CodeBuild project
* CodeDeploy application
* S3 Bucket for artifact storage
* CodePipeline for CI/CD orchestration
* IAM Policies / Roles for all components
* EC2 instance with CodeDeploy agent installed

The Terraform code outputs:
* The public IP of the EC2 instance
* The HTTPS clone URL of the CodeCommit Repo
## Diagram
![diagram](/images/diagram.png)
## Instructions
### Deploy Pipeline with Terraform
Before you deploy the terraform, please create a file called `terraform.tfvars` and set the value of the `artifact_bucket_name` variable to a globally unique name. I suggest that you use the following name with your own string of random numbers and letters:
```
artifact_bucket_name = "web-app-artifacts-bucket-x235n32a3poiv"
```
When you have done this, you can run the code as follows in your terminal:
```
terraform init
terraform apply -auto-approve
```
This should create all the necessary resources for the pipeline. The output should look like this:
```
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

ec2-ip = 3.86.13.53
repo_url = https://git-codecommit.us-east-1.amazonaws.com/v1/repos/WebApplication
```
### Clone CodeCommit Repo
Before you clone the CodeCommit repository, you will need to do some extra configuration. For Linux, you will need to run the following commands:
```
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
```
See more information in the AWS Docs [here](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html).

Make sure you are outside of this repository's directory before you clone the CodeCommit repo. 
To *clone* the repo:
```
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/WebApplication
```
Move into the directory you just cloned with `cd WebApplication`. Now copy all the files from the [application_code](application_code/) directory. Make sure that you are not working in the `aws-interview-codepipeline/application_code` directory, but instead are working in the `WebApplication` directory that you cloned from CodeCommit.

### Deploying the App
When you go to the public IP of the EC2, the request will timeout, because there have been no commits to the repo and the pipeline has not been triggered yet. 

Save the files that you recently added to your repo directory and push your changes to the pipeline:
```
git add .
git commit -m "Initial commit"
git push -u origin master
```
This will kick off your pipeline as you will be able to see a couple of seconds in the CodePipeline console:
![Pipeline](/images/pipeline.png)

After the pipeline is complete, when you navigate to the public IP of your EC2 instance you will be able to see a page that looks like this:

![blue-page](/images/blue-page.png)



### Making a change
To make a change, modify the `index.html` file to your liking. I would recommend changing the `background-color` in the `<style>` tag so the change will be apparent.
Save your changes and push to the pipeline again.
```
git add .
git commit -m "Initial commit"
git push -u origin master
```
When the pipeline is complete and you navigate to the public IP of the EC2 instance your page should be updated. In my case, I changed the background color to green:
![green-page](/images/green-page.png)

### Tear down the Terraform
Once you are done, you can destroy the entire pipeline . Note, that this will also destroy the CodeCommit repo, so make sure that you back up your code repo before you tear down the pipeline.
```
terraform destroy -auto-approve
```
