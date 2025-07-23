# project-tempest

Tasks:
* Tempest is planning to deploy a highly available and scalable Wordpress application on AWS.
* You are expected to use Terraform to provision the AWS infrastructure.
* Deploy a highly available and scalable WordPress application to the AWS infrastructure.
* You are expected to package the WordPress application with Helm/k8s manifest and deploy to AWS EKS using ArgoCD/GitHub Actions.

Deliverable:
* Infrastructure as Code (IaC) scripts.
* CI/CD pipeline configuration scripts.
* Wordpress k8s manifest
* Detailed documentation
* Steps to provision the infrastructure.
* Any assumptions or decisions made during the implementation.
* Ensure the documentation is clear and can be followed by another engineer.
* AWS WordPress architecture diagram

Bonus:
* Use of GitOps (e.g. ArgoCD)
* Secret management
* Deploy a custom domain (use freenom) + TLS on your application (examples: cert-manager,, etc)
* Create monitoring (examples: grafana, prometheus, etc)
* Autoscale Wordpress with load
* HPA and Metric server
* Zero downtime deployments (use helm)


# Design

## Limitations

Just a list for the time being

* There's no detailed specification for availability and scalability, so the
  settings presented might not be right, but they can be tweaked depending on
  requirements and observed traffic
* Target Operating Model of the customer is unknown, so the IaaC code is set in
  a simple-to-use-way, but still extensible down the road if desired
* This setup uses default Wordpress container image as there's a long list of
  configurations, plugins and libraries that might be needed depending on
  concrete use-case

# Deployment steps

## Prerequsites

You're expected to have base understanding of AWS, how to authenticate with AWS
to perform initial deployment and have few software tools installed on your
machine.

List of software:
* Terragrunt
* Terraform (alternatively OpenTofu)

## Initial deployment

It is recommended to run the initial deployment of the solution with identity
that supports longer-lived sessions (1h+) as some modules take a long time to
deploy for the first time.
Direct run from your machine might make it easier to control to execution, but
there's nothing preventing full deployment from pipeline too.

1. Create the environment and set configuration vaules
2. Initial deployment of solution
3. Pipeline setup 
