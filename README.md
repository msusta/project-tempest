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
