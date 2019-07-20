
# Jenkins-CI/CD

This repository contains the Terraform modules for creating a production ready Jenkins on EC2 Instance. Firstly, create a ECR repository. For the deployment, first we have to add the basic configurations to Jenkins. Then, install the basic plugins required. We have to add Docker plugin and Cloud-bees AWS Credentials plugin by ourselves. Amazon ECR plugin will be a plus. Then, configure Jenkins for the URL of the web-hook. Add the web-hook to the Github repository settings. Add a new job of pipeline type and select "GitHub hook trigger for GITScm polling" for build triggers. Add variables to the configuration through parameters.Add the script through SCM and link this repository. Create AWS credentials in Jenkins.

## Table of contents
-   [What is Jenkins?](https://github.com/sikandarqaisar/Jenkins-CICD#what-is-jenkins)
-   [Terraform module's](https://github.com/sikandarqaisar/Jenkins-CICD#terraform-module)
-   [How to create the infrastructure](https://github.com/sikandarqaisar/Jenkins-CICD#create-it)
-    [Jenkins PipeLine](https://github.com/sikandarqaisar/Jenkins-CICD#create-it)
-   [Things you should know](https://github.com/sikandarqaisar/Jenkins-CICD#must-know)
    -   [SSH access to the instances](https://github.com/sikandarqaisar/Jenkins-CICD#ssh-access-to-the-instances)
    -   [Jenkins PipeLine](https://github.com/sikandarqaisar/Jenkins-CICD#ecs-configuration)
    -   [taskdef.json](https://github.com/sikandarqaisar/Jenkins-CICD#ecs-instances)
    -   [Jenkinsfile](https://github.com/sikandarqaisar/Jenkins-CICD#ecs-instances)



## [](https://github.com/sikandarqaisar/Jenkins-CICD#what-is-ecs)What is Jenkins


Jenkins is an open source automation tool written in Java with plugins built for Continuous Integration purpose. Jenkins is used to build and test your software projects continuously making it easier for developers to integrate changes to the project, and making it easier for users to obtain a fresh build. It also allows you to continuously deliver your software by integrating with a large number of testing and deployment technologies.

With Jenkins, organisations can accelerate the software development process through automation. Jenkins integrates development life-cycle processes of all kinds, including build, document, test, package, stage, deploy, static analysis and much more.

Jenkins achieves Continuous Integration with the help of plugins. Plugins allows the integration of Various DevOps stages. If you want to integrate a particular tool, you need to install the plugins for that tool. For example: Git, Maven 2 project, Amazon EC2, HTML publisher etc.


**What are we creating:**

-   VPC with a /16 ip address range and an internet gateway
-   We are choosing a number of availability zones we want to use. For high-availability we need at least two
-   In every availability zone we are creating a subnet with a /24 ip address range
    -   Public subnet convention is 10.x.0.x and 10.x.1.x etc..
-   In the public subnet we place a NAT gateway and the LoadBalancer
-   The public subnets are also used in the autoscale group which places instances in them



## [](https://github.com/sikandarqaisar/Jenkins-CICD#terraform-module)Terraform module

To be able to create the stated infrastructure we are using Terraform. To allow everyone to use the infrastructure code, this repository contains the code as Terraform modules so it can be easily used by others.

Creating one big module does not really give a benefit of modules. Therefore the ECS module itself consists of different modules. This way it is easier for others to make changes, swap modules or use pieces from this repository even if not setting up ECS.

Details regarding how a module works or why it is setup is described in the module itself if needed.

Modules need to be used to create infrastructure. For an example on how to use the modules to create a working ECS cluster see  **main.tf**  in  **EC2 Module**

**Note:**  You need to use Terraform version 0.9.5 and above

### [](https://github.com/sikandarqaisar/Jenkins-CICD#list-of-modules)List of modules

-   **EC2**
    -   **Template**
    -   **data**
-   **VPC**
    -   **Template**
    -   **data**
-   **IAM**

### [](https://github.com/sikandarqaisar/Jenkins-CICD#conventions)Conventions

These are the conventions we have in every module

-   Contains  **main.tf**  where all the terraform code is
-   Contains  **outputs.tf**  with the output parameters
-   Contains  **variables.tf**  which sets required attributes
-   Contains  **data.tf**  which sets required attributes
-   For grouping in AWS we set the tag "Environment" everywhere where possible

### [](https://github.com/sikandarqaisar/Jenkins-CICD#module-structure)Module structure



## [](https://github.com/sikandarqaisar/Jenkins-CICD#create-it)Create it

To create a working ECS cluster from this repository see  **prod_var.tfvars**  in main ECS module .

Quick way to create this from the repository as is:

`terraform apply -var-file=dev.tfvarsz`

Actual way for creating everything using the default terraform flow:

```
 terraform init
 terraform plan  -var-file=dev.tfvars
 terraform apply -var-file=dev.tfvars 

```

## [](https://github.com/sikandarqaisar/Jenkins-CICD#must-know)Must know

### [](https://github.com/sikandarqaisar/Jenkins-CICD#ssh-access-to-the-instances)SSH access to the instances

You should not put your EC2 instances directly on the internet. You should not allow SSH access to the instances directly but use a bastion server for that. Having SSH access to the acceptance environment is fine but you should not allow SSH access to production instances. You don't want to make any manual changes in the production environment.

### [](https://github.com/sikandarqaisar/Jenkins-CICD#ssh-access-to-the-instances)Jenkins PipeLine
Jenkins Pipeline  is a suite of plugins which supports implementing and integrating  _continuous delivery pipelines_  into Jenkins.

A  _continuous delivery (CD) pipeline_  is an automated expression of your process for getting software from version control right through to your users and customers. Every change to your software (committed in source control) goes through a complex process on its way to being released. This process involves building the software in a reliable and repeatable manner, as well as progressing the built software (called a "build") through multiple stages of testing and deployment.

### taskdef.json

This file contains the task definition which will determine the behaviour of the task running in the service.
```
{

"family":"webapp1",

"containerDefinitions":[

{

"name": "container1",

"image": "{{image}}",

"cpu": 128,

"memory": 128,

"essential": true,

"portMappings": [

{

"containerPort": 80,

"hostPort": 8081

}

],

"command": [],

"entryPoint": [],

"links": [],

"mountPoints": [],

"volumesFrom": []

}

]

}
```

### [](https://github.com/sikandarqaisar/Jenkins-CICD#jenkinsfile)Jenkinsfile

This file automates the pipeline. It builds Docker image from Dockerfile from Github . Adds it to task definition and pushes it to the ECR.

### [](https://github.com/sikandarqaisar/Jenkins-CICD#list-of-modules)Parameters
These are the parameters you need to define in you jenkins pipeline and Build it with parameters option 
-  **ECR_repo_uri** : Use your ECR repository URl
- **exec_role_arn** : Use execution role ARN
- **region** : Pass your region
- **cluster** : pass your Cluster name here
- **service** : use service name
- **task_def_arn** : Task definition ARN


```
node {

def COMMIT_ID= sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

stage 'Checkout'

git 'https://github.com/sikandarqaisar/Docker-image-nginx.git'

stage 'Docker build'

sh "docker build -t sikandar-repo:${COMMIT_ID} ."

stage 'Docker push'

docker.withRegistry('https://853219876644.dkr.ecr.us-east-2.amazonaws.com/', 'ecr:us-east-2:s-cred') {

docker.image('sikandar-repo').push ("${COMMIT_ID}")

}

stage 'Deploy'

sh "sed -i 's|{{image}}|${ECR_repo_uri}/:${COMMIT_ID}|' taskdef.json"

sh "aws ecs register-task-definition --execution-role-arn ${exec_role_arn} --cli-input-json file://taskdef.json --region ${region}"

sh "aws ecs update-service --cluster ${cluster} --service ${service} --task-definition ${task_def_arn} --region ${region}"

}
```
