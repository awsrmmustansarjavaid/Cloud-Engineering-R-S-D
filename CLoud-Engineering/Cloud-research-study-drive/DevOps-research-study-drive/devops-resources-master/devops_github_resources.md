# 🚀 DevOps GitHub Resources

> A curated collection of GitHub repositories, learning resources, roadmaps, DevOps tools, hands-on projects, cheat sheets, books, communities, and practical references for learning and practicing DevOps.

This repository brings together DevOps learning material from beginner fundamentals to advanced cloud-native technologies such as Kubernetes, GitOps, Infrastructure as Code, observability, security, and platform engineering.

[DevOps tools](https://github.com/collections/devops-tools)

---

# 📚 Table of Contents

* [About This Repository](#about-this-repository)
* [DevOps Learning Roadmap](#devops-learning-roadmap)
* [1. API Tools](#1-api-tools)
* [2. Artifact Management](#2-artifact-management)
* [3. Backup & Disaster Recovery](#3-backup--disaster-recovery)
* [4. Build Tools](#4-build-tools)
* [5. Bug & Issue Tracking](#5-bug--issue-tracking)
* [6. CI/CD Tools](#6-cicd-tools)
* [7. Cloud Cost Management](#7-cloud-cost-management)
* [8. Cloud Providers](#8-cloud-providers)
* [9. Code Analysis & Security](#9-code-analysis--security)
* [10. Code Coverage](#10-code-coverage)
* [11. Code Review](#11-code-review)
* [12. Collaboration](#12-collaboration)
* [13. Configuration Management](#13-configuration-management)
* [14. Container Autoscaling & Load Balancing](#14-container-autoscaling--load-balancing)
* [15. Container Orchestration](#15-container-orchestration)
* [16. Containerization](#16-containerization)
* [17. Continuous Delivery & GitOps](#17-continuous-delivery--gitops)
* [18. Data Processing & Analytics](#18-data-processing--analytics)
* [19. Design & Architecture](#19-design--architecture)
* [20. Development Environments](#20-development-environments)
* [21. DevOps Learning Resources](#21-devops-learning-resources)
* [22. Documentation](#22-documentation)
* [23. IDE & Editors](#23-ide--editors)
* [24. Infrastructure Provisioning & IaC](#24-infrastructure-provisioning--iac)
* [25. Internal Developer Platforms](#25-internal-developer-platforms)
* [26. Logging](#26-logging)
* [27. Metric Storage](#27-metric-storage)
* [28. Monitoring & Observability](#28-monitoring--observability)
* [29. Networking](#29-networking)
* [30. Operating Systems](#30-operating-systems)
* [31. Planning & Project Management](#31-planning--project-management)
* [32. Policy Management](#32-policy-management)
* [33. Programming](#33-programming)
* [34. Project-Based Learning](#34-project-based-learning)
* [35. Secret Management](#35-secret-management)
* [36. Service Mesh](#36-service-mesh)
* [37. Source Code Management](#37-source-code-management)
* [38. System Administration](#38-system-administration)
* [39. System Design](#39-system-design)
* [40. Test Automation & Performance Testing](#40-test-automation--performance-testing)
* [41. Visualization](#41-visualization)
* [42. Useful Communities](#42-useful-communities)
* [43. Books](#43-books)
* [44. Blogs & News](#44-blogs--news)
* [45. Cheat Sheets](#45-cheat-sheets)
* [46. Conferences](#46-conferences)
* [47. DevOps Snippets](#47-devops-snippets)
* [48. Other Useful Projects](#48-other-useful-projects)
* [Recommended DevOps Learning Order](#recommended-devops-learning-order)
* [How to Use This Repository](#how-to-use-this-repository)
* [Featured GitHub Repositories](#featured-github-repositories)
* [Contribution Guidelines](#contribution-guidelines)
* [License](#license)

---

# 📌 About This Repository

DevOps is not a single tool.

It is a combination of:

* Development
* Operations
* Automation
* Infrastructure
* Cloud
* Containers
* CI/CD
* Security
* Monitoring
* Observability
* Collaboration
* Reliability

This repository is designed to help learners understand **how these technologies connect together**, rather than simply collecting a list of tools.

A typical DevOps workflow can look like:

```text
Developer
    ↓
Git / GitHub
    ↓
CI Pipeline
    ↓
Code Quality & Security
    ↓
Build & Test
    ↓
Container Image
    ↓
Container Registry
    ↓
Infrastructure / Kubernetes
    ↓
Application Deployment
    ↓
Monitoring & Logging
    ↓
Feedback & Improvement
```

---

# 🗺️ DevOps Learning Roadmap

A practical learning path is:

```text
Linux
  ↓
Networking Basics
  ↓
Git & GitHub
  ↓
Programming Fundamentals
  ↓
Bash / Shell Scripting
  ↓
Web Servers / Databases / Load Balancers
  ↓
Docker / Containers
  ↓
CI/CD
  ↓
Jenkins / GitHub Actions
  ↓
Cloud
  ↓
Terraform / CloudFormation / OpenTofu
  ↓
Ansible
  ↓
Kubernetes
  ↓
GitOps
  ↓
Security
  ↓
Monitoring & Observability
  ↓
Logging
  ↓
SRE / Reliability
  ↓
Real-World DevOps Projects
```

> You do not need to master every tool. Learn the concepts first, then learn tools that help you implement those concepts.

---

# 1. API Tools

Tools for developing, testing, documenting, and debugging APIs.

* **Postman** — API development, testing, documentation, and collaboration.
* **Hoppscotch** — Open-source API development and testing platform.
* **SoapUI** — API testing for SOAP and REST services.
* **Swagger** — API specification and documentation ecosystem.
* **HTTPie** — Human-friendly command-line HTTP client.
* **HttpMaster** — HTTP testing and debugging tool.

---

# 2. Artifact Management

Artifact repositories store and manage packages, binaries, container images, and other deployable artifacts.

* **Nexus Repository** — Repository manager for dependencies and artifacts.
* **JFrog Artifactory** — Universal artifact repository.
* **npm** — JavaScript package registry and package manager.
* **NuGet** — Package manager for the .NET ecosystem.

---

# 3. Backup & Disaster Recovery

Tools for backing up applications, Kubernetes resources, persistent volumes, and infrastructure data.

* **Velero** — Backup, restore, disaster recovery, and migration for Kubernetes.
* **Kasten K10** — Kubernetes data management and disaster recovery.
* **CloudCasa** — Kubernetes backup and disaster recovery platform.

---

# 4. Build Tools

Build tools automate compilation, packaging, dependency management, and artifact creation.

* **Maven** — Build and dependency management for Java.
* **Gradle** — Build automation for JVM and other ecosystems.
* **npm** — JavaScript package management.
* **pnpm** — Fast and disk-efficient JavaScript package manager.
* **Yarn** — JavaScript and TypeScript package manager.
* **Rake** — Ruby build automation.
* **MSBuild** — Build platform for .NET and Visual Studio.
* **PyBuilder** — Python-based build automation.

---

# 5. Bug & Issue Tracking

Tools for tracking bugs, issues, tasks, and software-development workflows.

* **Backlog** — Project management and issue tracking.
* **Bugzilla** — Open-source bug tracking system.
* **Jira** — Issue tracking and project management.
* **Lean Testing** — Test case and bug management.
* **MantisBT** — Open-source web-based bug tracking.

---

# 6. CI/CD Tools

Continuous Integration and Continuous Delivery tools automate building, testing, packaging, and deployment.

### Popular CI/CD Tools

* **Jenkins** — Open-source automation server.
* **GitHub Actions** — CI/CD integrated with GitHub.
* **GitLab CI/CD** — CI/CD integrated with GitLab.
* **CircleCI** — Cloud and self-hosted CI/CD platform.
* **Buildkite** — CI/CD platform with self-hosted agents.
* **Drone** — Container-native CI/CD platform.
* **TeamCity** — CI/CD and build management platform.
* **Travis CI** — Hosted CI service.
* **Bamboo** — CI/CD platform from Atlassian.
* **Tekton** — Kubernetes-native CI/CD framework.
* **Zuul** — CI system designed around project gating.
* **Werf** — CI/CD and Kubernetes deployment tool.

---

# 7. Cloud Cost Management

Tools for understanding, monitoring, and optimizing cloud and Kubernetes costs.

* **Infracost** — Cloud cost estimation for Infrastructure as Code.
* **Kubecost** — Kubernetes cost monitoring and optimization.

---

# 8. Cloud Providers

Major cloud platforms used for DevOps, infrastructure, application hosting, and cloud-native workloads.

* **Amazon Web Services (AWS)** — Cloud computing platform.
* **Microsoft Azure** — Microsoft cloud platform.
* **Google Cloud** — Google cloud computing platform.
* **IBM Cloud** — Enterprise cloud platform.
* **Oracle Cloud** — Cloud infrastructure and enterprise services.
* **OpenStack** — Open-source cloud infrastructure platform.

---

# 9. Code Analysis & Security

Code analysis tools help identify bugs, code-quality problems, vulnerabilities, and security issues.

## Static Analysis

Static analysis examines source code without executing the application.

* **SonarQube** — Continuous code quality and security analysis.
* **PMD** — Static source-code analyzer.
* **Checkmarx** — Application security testing platform.

## Dynamic Analysis

Dynamic analysis tests applications while they are running.

* **Acunetix** — Web application vulnerability scanning.

## Container Security

* **Trivy** — Vulnerability and security scanner.
* **Clair** — Container vulnerability analysis.
* **Docker Bench Security** — Docker security best-practice checks.
* **Falco** — Runtime threat detection and cloud-native security.
* **Notary** — Software supply-chain trust and signing ecosystem.

---

# 10. Code Coverage

Code coverage tools measure which parts of an application are exercised by tests.

* **Cobertura** — Java code coverage.
* **Clover** — Code coverage and testing analysis.
* **JaCoCo** — Java code coverage library.

---

# 11. Code Review

Tools that support collaborative source-code review.

* **Gerrit** — Code review and Git-based collaboration.
* **Review Board** — Code review platform.
* **Pull Panda** — Pull-request management and review tools.

---

# 12. Collaboration

Tools for communication and team collaboration.

* **Slack** — Team communication and collaboration.
* **Cisco Webex** — Messaging, meetings, calling, and collaboration.
* **Flock** — Team communication and productivity.
* **Flowdock** — Team collaboration and communication.

> Google Hangouts has historically been listed in DevOps resource collections, but the product has been retired. Prefer current Google communication products instead.

---

# 13. Configuration Management

Configuration management tools automate the configuration and maintenance of servers and infrastructure.

* **Ansible** — Agentless automation and configuration management.
* **Chef** — Infrastructure and configuration automation.
* **Puppet** — Declarative configuration management.
* **Salt** — Infrastructure automation and remote execution.

---

# 14. Container Autoscaling & Load Balancing

Tools that help Kubernetes workloads automatically scale or expose services.

* **KEDA** — Event-driven Kubernetes autoscaling.
* **MetalLB** — Load-balancer implementation for bare-metal Kubernetes.

---

# 15. Container Orchestration

Container orchestration platforms manage containerized applications across clusters.

* **Kubernetes** — Container orchestration platform.
* **OpenShift** — Kubernetes-based application platform.
* **Nomad** — Workload orchestrator for containers and non-containerized applications.
* **k3s** — Lightweight Kubernetes distribution.

---

# 16. Containerization

Container technologies package applications and dependencies into portable runtime environments.

* **Docker** — Container development and runtime platform.
* **Podman** — Daemonless OCI container engine.
* **Buildah** — OCI container image building tool.
* **CRI-O** — Kubernetes-focused container runtime.

> `rkt` was historically an important container runtime but is no longer an active modern choice. It is retained here only as historical reference when studying older container technology.

---

# 17. Continuous Delivery & GitOps

GitOps uses Git as a source of truth for declarative application and infrastructure configuration.

* **Argo CD** — Kubernetes GitOps continuous delivery.
* **Flux CD** — GitOps continuous delivery for Kubernetes.
* **Jenkins** — Automation and deployment pipelines.
* **GoCD** — Continuous delivery server.
* **GitLab CI/CD** — Integrated CI/CD platform.
* **Jenkins X** — Kubernetes-focused CI/CD project.
* **Tekton** — Kubernetes-native CI/CD framework.

### Typical GitOps Workflow

```text
Developer
    ↓
Git Repository
    ↓
CI Pipeline
    ↓
Build & Test
    ↓
Container Image
    ↓
Container Registry
    ↓
GitOps Repository
    ↓
Argo CD / Flux
    ↓
Kubernetes
```

---

# 18. Data Processing & Analytics

Tools for processing, transforming, querying, and analyzing large datasets.

## Data Processing

* **Apache Spark**
* **Apache Hadoop**
* **Apache Airflow**
* **Presto**

## Analytics Engines

* **Apache Druid**
* **Dremio**
* **Snowflake**

## Operations Data

* **Salesforce**
* **Zuora**

---

# 19. Design & Architecture

Resources for learning software architecture, distributed systems, and cloud-native application design.

* **The Twelve-Factor App** — Principles for building modern application services.
* **Distributed Systems Reading List** — Distributed-systems learning material.
* **System Design Primer** — System design concepts, examples, and interview preparation.

---

# 20. Development Environments

Tools for creating reproducible development and testing environments.

* **VirtualBox** — Desktop virtualization.
* **QEMU** — Machine emulator and virtualizer.
* **Vagrant** — Virtual machine environment management.
* **Docker Desktop** — Desktop container development environment.
* **Podman Desktop** — Desktop container and Kubernetes environment.
* **Rancher Desktop** — Local Kubernetes and container environment.
* **Minikube** — Local Kubernetes clusters.
* **kind** — Kubernetes clusters using containers as nodes.
* **k3d** — Runs lightweight k3s clusters inside Docker.

> Minishift was designed for local OpenShift development but is no longer a recommended modern choice.

---

# 21. DevOps Learning Resources

## 21.1 DevOps Roadmaps & Guides

### Developer Roadmap

**Repository:** `kamranahmedse/developer-roadmap`

A large collection of roadmaps covering DevOps, cloud, Kubernetes, Docker, programming, and other technology areas.

Useful for:

* DevOps roadmap
* Cloud
* Docker
* Kubernetes
* CI/CD
* Career planning

### DevOps Resources

**Repository:** `bregman-arie/devops-resources`

A broad collection of DevOps learning resources.

Useful for:

* Linux
* Jenkins
* AWS
* Kubernetes
* Terraform
* DevOps fundamentals

### Learn DevOps

**Repository:** `codeaprendiz/learn-devops`

A task-oriented DevOps learning repository.

Useful for:

* Practical learning
* DevOps tasks
* Hands-on objectives
* Examples

### DevOps Tutorial

**Repository:** `manikcloud/DevOps-Tutorial`

Tutorials and practical material related to DevOps technologies.

### Tech Vault

**Repository:** `moabukar/tech-vault`

A collection of technical tutorials and resources.

Useful for:

* Docker
* Kubernetes
* Ansible
* Cloud
* Infrastructure

---

## 21.2 DevOps Exercises

**Repository:** `bregman-arie/devops-exercises`

A large collection of DevOps questions, exercises, troubleshooting topics, and interview preparation material.

Useful for:

* Linux
* AWS
* Docker
* Kubernetes
* Terraform
* Jenkins
* SRE
* Troubleshooting
* Interview preparation

---

## 21.3 System Administration Practice

### Test Your Sysadmin Skills

**Repository:** `trimstray/test-your-sysadmin-skills`

Practical challenges for developing system administration and infrastructure knowledge.

Useful for:

* Linux
* Networking
* System administration
* Troubleshooting

---

# 22. Documentation

Documentation platforms help teams maintain technical knowledge, architecture documentation, runbooks, and internal guides.

* **Confluence** — Collaborative documentation and knowledge management.
* **ClickUp Docs** — Documentation integrated with project management.
* **GitHub Wiki** — Repository-based documentation.
* **Markdown** — Lightweight format commonly used for technical documentation.

---

# 23. IDE & Editors

* **Visual Studio Code** — Lightweight source-code editor.
* **Sublime Text** — Fast text and code editor.
* **Notepad++** — Windows source-code editor.

---

# 24. Infrastructure Provisioning & IaC

Infrastructure as Code allows infrastructure to be defined and managed through configuration or programming languages.

* **Terraform** — Multi-cloud Infrastructure as Code.
* **OpenTofu** — Open-source Infrastructure as Code tool.
* **Pulumi** — Infrastructure as Code using general-purpose programming languages.
* **AWS CloudFormation** — AWS-native infrastructure provisioning.
* **Azure Resource Manager** — Azure resource deployment and management.
* **Azure Bicep** — Declarative language for Azure infrastructure.

---

# 25. Internal Developer Platforms

Platform engineering tools provide developers with self-service interfaces for infrastructure, applications, services, and operational workflows.

* **Backstage** — Open-source developer portal framework.
* **Port** — Internal developer platform.
* **Cortex** — Developer experience and service management platform.
* **OpsLevel** — Service catalog and platform engineering capabilities.
* **Configure8** — Infrastructure and application management platform.

---

# 26. Logging

Centralized logging collects application and infrastructure logs into systems where they can be searched and analyzed.

## Log Management

* **Elastic Stack**
* **Graylog**
* **Fluentd**
* **Splunk**
* **Sumo Logic**
* **Syslog-ng**
* **Logz.io**

## Log Aggregation

* **Grafana Loki**
* **Logstash**

---

# 27. Metric Storage

Metric storage systems store time-series data generated by applications and infrastructure.

* **Prometheus**
* **VictoriaMetrics**
* **InfluxDB**
* **Thanos**

---

# 28. Monitoring & Observability

Monitoring and observability help teams understand the health, performance, reliability, and behavior of applications and infrastructure.

* **Prometheus** — Metrics monitoring and alerting.
* **VictoriaMetrics** — Time-series database and monitoring platform.
* **Grafana** — Visualization, dashboards, and alerting.
* **Thanos** — Highly available and long-term Prometheus-compatible metrics architecture.
* **Zabbix** — Infrastructure monitoring.
* **Nagios** — Infrastructure monitoring.
* **Sensu** — Infrastructure and application monitoring.
* **Datadog** — Cloud monitoring and observability.
* **New Relic** — Application and infrastructure observability.
* **Dynatrace** — Full-stack observability.
* **AppDynamics** — Application performance monitoring.
* **Sumo Logic** — Cloud-native monitoring and analytics.
* **Middleware** — Full-stack observability.
* **Cilium** — Networking, security, and observability using eBPF.
* **Calico** — Kubernetes networking and security.
* **Falco** — Runtime security and threat detection.
* **HolmesGPT** — Open-source alert investigation assistant.

---

# 29. Networking

Networking knowledge is essential for DevOps and cloud infrastructure.

Important concepts include:

* IP addressing
* Subnets
* Routing
* DNS
* DHCP
* TCP
* UDP
* HTTP
* HTTPS
* SSH
* TLS
* Load balancing
* Firewalls
* NAT
* VPN
* Network security
* Service discovery

Useful tools and technologies include:

* Kubernetes networking
* CNI plugins
* Cilium
* Calico
* MetalLB
* Nginx
* HAProxy

---

# 30. Operating Systems

Linux is one of the most important foundations for DevOps.

## Linux Learning Resources

* **Linux Journey** — Linux guides and exercises.
* **TecMint Linux Guide** — Linux tutorials and administration resources.
* **Linux Survival** — Interactive Linux learning.

## Linux Topics

Start with:

* Filesystem
* Permissions
* Users and groups
* Processes
* Services
* Package management
* Networking
* SSH
* Storage
* Logs
* System monitoring
* Shell scripting

Then progress toward:

* Kernel
* Memory management
* Virtualization
* Process management
* Storage architecture
* Networking internals

---

# 31. Planning & Project Management

* **Jira** — Agile project and issue management.
* **Trello** — Board-based task management.
* **Asana** — Project and task management.
* **Backlog** — Project management and collaboration.
* **Monday.com** — Workflow and project management.
* **ClickUp** — Project management, documentation, and collaboration.

---

# 32. Policy Management

Policy engines help enforce security, compliance, and configuration rules.

* **Open Policy Agent (OPA)** — General-purpose policy engine.
* **Kyverno** — Kubernetes-native policy engine.
* **Cloud Custodian** — Policy and governance engine for cloud resources.

---

# 33. Programming

DevOps engineers benefit from understanding at least one programming language and being comfortable with automation.

Useful languages include:

* Python
* Go
* Bash
* JavaScript
* Java
* C#
* Ruby

## Programming Practice

* **HackerRank** — Programming practice.
* **Exercism** — Programming exercises across many languages.
* **LeetCode** — Algorithm and programming practice.

## DevOps Programming Projects

Try building:

* Infrastructure provisioning scripts
* Log-analysis scripts
* Monitoring scripts
* Backup automation
* Deployment scripts
* API clients
* Cloud automation tools
* Kubernetes utilities

---

# 34. Project-Based Learning

Hands-on projects are essential for turning DevOps theory into practical skills.

### Project-Based Learning

**Repository:** `practical-tutorials/project-based-learning`

A collection of project ideas for learning through implementation.

### Build Your Own X

**Repository:** `codecrafters-io/build-your-own-x`

Learn how technologies work by building simplified versions of them.

Projects cover areas such as:

* Git
* Docker
* Databases
* Operating systems
* Networking
* Programming languages
* Development tools

### Kubernetes The Hard Way

**Repository:** `kelseyhightower/kubernetes-the-hard-way`

A hands-on Kubernetes project designed to help learners understand Kubernetes components and cluster internals.

Useful for:

* Kubernetes architecture
* Certificates
* Networking
* Cluster components
* Kubernetes internals

> Recommended after learning basic Kubernetes concepts.

### Fast Kubernetes

**Repository:** `omerbsezer/Fast-Kubernetes`

Kubernetes-focused learning material, projects, and deployment examples.

---

# 35. Secret Management

Secret management tools protect passwords, API keys, certificates, tokens, and other sensitive information.

* **HashiCorp Vault** — Centralized secret management.
* **External Secrets Operator** — Synchronizes secrets from external secret-management systems into Kubernetes.
* **AWS Secrets Manager** — Managed AWS secret storage.
* **Google Cloud Secret Manager** — Managed GCP secret storage.
* **Azure Key Vault** — Azure secrets, keys, and certificate management.
* **Teller** — Developer-focused secret management.

---

# 36. Service Mesh

Service meshes provide infrastructure for service-to-service communication in distributed applications.

* **Istio** — Service connectivity, security, and observability.
* **Linkerd** — Lightweight service mesh.
* **Cilium Service Mesh** — eBPF-based service networking and observability.

---

# 37. Source Code Management

Source-control systems store and manage application and infrastructure code.

* **GitHub** — Git repository hosting and developer collaboration.
* **GitLab** — Source control and DevOps platform.
* **Bitbucket** — Git repository hosting from Atlassian.
* **Azure Repos** — Source control within Azure DevOps.
* **Codeberg** — Community-oriented Git hosting.
* **Forgejo** — Open-source Git hosting platform.
* **Gitea** — Lightweight Git hosting.
* **Gogs** — Lightweight Git service.
* **Fossil** — Distributed version-control system with integrated project management features.

## Git Skills to Learn

You should become comfortable with:

* Repositories
* Commits
* Branches
* Merging
* Rebasing
* Pull requests
* Merge requests
* Tags
* Releases
* Remote repositories
* Conflict resolution

### Git Practice

* **Learn Git Branching** — Interactive Git branching exercises.
* **Learn Git Concepts, Not Commands** — Concept-focused Git learning.
* **Codecademy Learn Git** — Guided Git learning.

---

# 38. System Administration

DevOps builds heavily on system-administration knowledge.

Important areas include:

* Linux administration
* Users and groups
* Permissions
* Processes
* Services
* Networking
* Storage
* Backups
* Security
* Troubleshooting
* Monitoring
* Automation

### Practice

**Test Your Sysadmin Skills**

A useful collection of practical system-administration challenges.

---

# 39. System Design

System design helps DevOps engineers understand how infrastructure and applications behave at scale.

Important concepts:

* Availability
* Reliability
* Scalability
* Performance
* Fault tolerance
* Load balancing
* Caching
* Databases
* Networking
* Distributed systems
* Disaster recovery

### Resources

* **System Design Notebook** — System design learning material.
* **System Design Primer** — Large-scale system design and interview preparation.
* **Distributed Systems Reading List** — Distributed systems resources.

---

# 40. Test Automation & Performance Testing

Testing should be part of the CI/CD lifecycle.

* **Selenium** — Browser automation.
* **Appium** — Mobile application automation.
* **JMeter** — Performance and load testing.
* **BlazeMeter** — Continuous performance testing platform.
* **Tosca** — Enterprise test automation.
* **UFT** — Functional test automation.

---

# 41. Visualization

Visualization tools turn metrics, logs, and operational data into dashboards and reports.

* **Grafana** — Metrics and observability dashboards.
* **Kibana** — Elasticsearch visualization interface.
* **Tableau** — Business intelligence and data visualization.
* **Meshery** — Visual management and design for cloud-native infrastructure.

---

# 42. Useful Communities

Learning from other engineers can help with troubleshooting and understanding real-world practices.

* **Reddit DevOps** — DevOps community discussions.
* **LinkedIn DevOps Communities** — Professional DevOps discussions.
* **DevOps Facebook Groups** — Community discussions and resources.
* **CNCF Landscape** — Cloud-native ecosystem discovery.

---

# 43. Books

Books provide deeper understanding of DevOps culture, engineering practices, architecture, and reliability.

Recommended titles include:

* **The Phoenix Project**
* **The DevOps Handbook**
* **Google SRE Books**
* **Essential Infrastructure as Code**

Recommended topics:

* DevOps culture
* Continuous delivery
* Infrastructure as Code
* Site Reliability Engineering
* Systems thinking
* Automation

---

# 44. Blogs & News

Useful sources for following DevOps, cloud, Kubernetes, infrastructure, and SRE topics.

* **Spacelift Blog**
* **Codefresh Blog**
* **Red Hat Blog**
* **Atlassian DevOps Blog**
* **Azure DevOps Blog**
* **Netflix Tech Blog**
* **Uber Engineering**
* **DoorDash Engineering**
* **CloudBees Blog**
* **Palark Tech Blog**
* **This Week in DevOps**
* **opensource.com**
* **CooperPress**

---

# 45. Cheat Sheets

Cheat sheets are useful for quick revision and daily command reference.

* **Christian Lempa Cheat Sheets**
* **Awesome Cheat Sheets**
* **DevOps Cheat Sheet PDF**
* **Denny Zhang Cheat Sheets**

Useful topics include:

* Linux
* Git
* Docker
* Kubernetes
* Jenkins
* Terraform
* YAML
* Groovy
* Bash
* Cloud commands

---

# 46. Conferences

Conferences provide access to presentations, community discussions, and real-world engineering experiences.

* **DevOpsDays** — DevOps conferences around the world.
* **Velocity** — Engineering and performance-focused conference resources.

---

# 47. DevOps Snippets

Small scripts and reusable examples can accelerate everyday DevOps tasks.

* **DevOpsnipp** — DevOps snippets and examples.
* **GitHub Gists** — Small reusable pieces of code and configuration.

---

# 48. Other Useful Projects

Additional repositories and resources worth exploring:

### DevOps Wiki

`Leo-G/DevopsWiki`

A collection of DevOps tools, tutorials, and scripts.

### SRE Checklist

`bregman-arie/sre-checklist`

A checklist for Site Reliability Engineering practices.

### How They DevOps

`bregman-arie/howtheydevops`

Examples and information about how organizations approach DevOps.

### Infraverse

`bregman-arie/infraverse`

Infrastructure and DevOps-related resources.

### DevOps Exercises

`bregman-arie/devops-exercises`

Practical DevOps questions and exercises.

---

# ⭐ Featured GitHub Repositories

The following repositories are especially useful for structured DevOps learning.

|  # | Repository                   | Main Purpose                        |
| -: | ---------------------------- | ----------------------------------- |
|  1 | Developer Roadmap            | DevOps learning roadmap             |
|  2 | DevOps Resources             | DevOps resources                    |
|  3 | Learn DevOps                 | Task-based learning                 |
|  4 | DevOps Tutorial              | DevOps tutorials                    |
|  5 | Tech Vault                   | Technical tutorials                 |
|  6 | DevOps Exercises             | Exercises and interview preparation |
|  7 | Test Your Sysadmin Skills    | System administration practice      |
|  8 | Project-Based Learning       | Practical projects                  |
|  9 | Build Your Own X             | Learn by building technologies      |
| 10 | Kubernetes The Hard Way      | Kubernetes internals                |
| 11 | Fast Kubernetes              | Kubernetes practice                 |
| 12 | DevOps Bash Tools            | Bash automation                     |
| 13 | Ansible Examples             | Ansible automation                  |
| 14 | Christian Lempa Cheat Sheets | DevOps cheat sheets                 |
| 15 | Awesome Cheat Sheets         | Quick technical references          |

---

# 🔗 Featured Repository Links

1. https://github.com/kamranahmedse/developer-roadmap
2. https://github.com/bregman-arie/devops-resources
3. https://github.com/codeaprendiz/learn-devops
4. https://github.com/manikcloud/DevOps-Tutorial
5. https://github.com/moabukar/tech-vault
6. https://github.com/bregman-arie/devops-exercises
7. https://github.com/trimstray/test-your-sysadmin-skills
8. https://github.com/practical-tutorials/project-based-learning
9. https://github.com/codecrafters-io/build-your-own-x
10. https://github.com/kelseyhightower/kubernetes-the-hard-way
11. https://github.com/omerbsezer/Fast-Kubernetes
12. https://github.com/HariSekhon/DevOps-Bash-tools
13. https://github.com/ansible/ansible-examples
14. https://github.com/christianlempa/cheat-sheets
15. https://github.com/LeCoupa/awesome-cheatsheets

---

# 🧩 DevOps Toolchain

A DevOps engineer does not need to use every available tool.

A realistic toolchain could look like:

```text
                    ┌───────────────┐
                    │   Developer   │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Git / GitHub  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │   CI / CD     │
                    │ Jenkins / GHA  │
                    └───────┬───────┘
                            ↓
              ┌─────────────┴─────────────┐
              ↓                           ↓
       Code Quality                  Security Scan
       SonarQube                     Trivy / SAST
              └─────────────┬─────────────┘
                            ↓
                    ┌───────────────┐
                    │ Docker Image  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │    Registry   │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Kubernetes    │
                    └───────┬───────┘
                            ↓
              ┌─────────────┴─────────────┐
              ↓                           ↓
        Prometheus                    Logging
              ↓                           ↓
          Grafana                  Loki / Elastic
```

---

# 🛠️ Recommended Core DevOps Stack

If you are learning DevOps, you do not need to install everything in this README.

A practical learning stack is:

```text
Git
GitHub
Linux
Bash
Docker
Jenkins / GitHub Actions
SonarQube
Trivy
Terraform
Ansible
AWS / Azure / Google Cloud
Kubernetes
Argo CD
Prometheus
Grafana
Loki / Elastic
```

Learn the concepts first and add additional tools when a project requires them.

---

# 🎯 Practical DevOps Learning Path

## Phase 1 — Foundations

Learn:

* Linux
* Networking
* Git
* GitHub
* Basic programming
* Bash

Build:

* Linux administration lab
* Git workflow
* Bash automation scripts

---

## Phase 2 — Containers

Learn:

* Docker
* Container images
* Dockerfiles
* Container networking
* Volumes
* Registries
* Container security

Build:

* Dockerized web application
* Docker Compose application
* Private container registry workflow

---

## Phase 3 — CI/CD

Learn:

* CI/CD concepts
* Jenkins
* GitHub Actions
* Pipeline as Code
* Automated testing
* Artifact management

Build:

```text
GitHub
   ↓
Jenkins
   ↓
Build
   ↓
Test
   ↓
Docker Image
   ↓
Registry
```

---

## Phase 4 — Infrastructure as Code

Learn:

* Terraform
* OpenTofu
* CloudFormation
* Pulumi
* Infrastructure state
* Modules
* Variables
* Outputs

Build:

```text
IaC
 ↓
VPC
 ↓
Subnets
 ↓
Security Groups
 ↓
Compute
 ↓
Database
```

---

## Phase 5 — Configuration Management

Learn:

* Ansible
* Inventory
* Playbooks
* Roles
* Variables
* Idempotency

Build:

```text
Ansible
   ↓
Linux Server
   ↓
Install Packages
   ↓
Configure Application
   ↓
Deploy Application
```

---

## Phase 6 — Kubernetes

Learn:

* Cluster
* Node
* Pod
* Deployment
* Service
* ConfigMap
* Secret
* Namespace
* Ingress
* Volumes
* StatefulSets
* DaemonSets
* Jobs
* CronJobs
* Scheduling
* Networking
* Scaling

Then learn:

* Helm
* Kustomize
* Kubernetes security
* Kubernetes storage
* Kubernetes troubleshooting

---

## Phase 7 — GitOps

Learn:

* GitOps concepts
* Declarative configuration
* Argo CD
* Flux CD

Typical workflow:

```text
Developer
   ↓
Application Repository
   ↓
CI Pipeline
   ↓
Container Image
   ↓
Container Registry
   ↓
GitOps Repository
   ↓
Argo CD
   ↓
Kubernetes
```

---

## Phase 8 — Observability

Learn:

* Metrics
* Logs
* Traces
* Alerts
* Dashboards
* SLOs
* SLIs
* Incident response

Common stack:

```text
Prometheus
    ↓
Grafana

Application Logs
    ↓
Loki / Elastic
    ↓
Grafana / Kibana
```

---

## Phase 9 — Security

Learn:

* Secret management
* IAM
* Image scanning
* Dependency scanning
* SAST
* DAST
* Runtime security
* Policy enforcement
* Supply-chain security

Example:

```text
Source Code
   ↓
SAST
   ↓
Dependency Scan
   ↓
Build
   ↓
Container Image
   ↓
Trivy
   ↓
Registry
   ↓
Kubernetes
   ↓
Runtime Security
```

---

# 🏗️ Example Real-World DevOps Project

A complete learning project can combine the major concepts:

```text
                    Developer
                        ↓
                     GitHub
                        ↓
                    Jenkins
                        ↓
             ┌──────────┴──────────┐
             ↓                     ↓
         SonarQube               Tests
             ↓                     ↓
             └──────────┬──────────┘
                        ↓
                  Docker Build
                        ↓
                     Trivy
                        ↓
                 Container Registry
                        ↓
                  GitOps Repository
                        ↓
                    Argo CD
                        ↓
                   Kubernetes
                        ↓
             ┌──────────┴──────────┐
             ↓                     ↓
        Prometheus               Loki
             ↓                     ↓
             └──────────┬──────────┘
                        ↓
                     Grafana
                        ↓
                      Users
```

This type of project allows you to practice:

* Git
* GitHub
* Jenkins
* CI/CD
* SonarQube
* Docker
* Trivy
* Container registry
* Kubernetes
* GitOps
* Argo CD
* Prometheus
* Grafana
* Logging
* Cloud infrastructure
* Infrastructure as Code

---

# 🧭 How to Use This Repository

Do not try to learn every tool listed here.

Instead:

1. Start with **Linux and networking fundamentals**.
2. Learn **Git and GitHub**.
3. Learn basic **programming and Bash**.
4. Learn **Docker and containers**.
5. Learn **CI/CD**.
6. Learn **Jenkins or GitHub Actions**.
7. Learn **cloud fundamentals**.
8. Learn **Terraform, OpenTofu, or CloudFormation**.
9. Learn **Ansible**.
10. Learn **Kubernetes**.
11. Learn **GitOps with Argo CD or Flux**.
12. Learn **monitoring and observability**.
13. Learn **DevOps security**.
14. Build complete projects.
15. Use exercises and troubleshooting resources to strengthen your knowledge.

---

# 🧪 Interactive Practice

Hands-on practice is one of the best ways to develop DevOps skills.

Useful platforms include:

* **KodeKloud Engineer** — Practical infrastructure and DevOps tasks.
* **Google Cloud Skills Boost** — Cloud and hands-on lab environments.
* Cloud-provider learning labs
* Local Kubernetes environments
* Virtual machines
* Docker-based labs

---

# 📖 Learn About DevOps

Useful introductory resources include:

* AWS DevOps documentation and learning resources
* Microsoft DevOps documentation
* Google Cloud DevOps resources
* Red Hat DevOps resources
* Spacelift DevOps resources

Focus on understanding:

* What DevOps means
* CI vs CD
* Infrastructure as Code
* Automation
* Continuous feedback
* Observability
* Collaboration
* Reliability
* Security

---

# 🏆 Recommended Practice Projects

Start small and increase complexity gradually.

### Beginner

* Linux administration lab
* Git/GitHub project
* Bash automation project
* Dockerized application
* Simple CI pipeline

### Intermediate

* Jenkins + Docker CI/CD
* Terraform cloud infrastructure
* Ansible server configuration
* Kubernetes application deployment
* Monitoring with Prometheus and Grafana

### Advanced

* GitOps with Argo CD
* Kubernetes production-style deployment
* Multi-service application
* Kubernetes observability
* Kubernetes security
* Complete cloud-native CI/CD platform

---

# 📊 DevOps Skill Areas

This repository covers the following major areas:

* Automation
* CI/CD
* Cloud
* Containers
* DevSecOps
* Git
* GitOps
* Infrastructure as Code
* Kubernetes
* Linux
* Monitoring
* Networking
* Observability
* Programming
* Security
* SRE
* System Administration
* System Design
* Testing

---

# 🧹 Repository Organization Principles

To keep this repository maintainable:

* Avoid listing the same tool multiple times.
* Put each tool in its primary category.
* Use cross-references when a tool belongs to multiple domains.
* Prefer official documentation for installation and usage.
* Keep learning repositories separate from production tools.
* Keep historical or deprecated technologies clearly labeled.
* Avoid outdated descriptions.
* Keep links current.
* Prefer practical examples over large collections of unrelated links.
* Update resources when their projects become inactive or change direction.

---

# 🤝 Contribution Guidelines

Contributions are welcome.

If you know of a useful DevOps repository, tool, tutorial, project, or learning resource, you can submit a pull request.

## Before Adding a Resource

Make sure the resource:

* Is relevant to DevOps, cloud, infrastructure, automation, security, SRE, or related engineering practices.
* Provides meaningful educational or practical value.
* Has a working link.
* Is placed in the correct category.
* Does not duplicate an existing resource.

## Recommended Format

```markdown
- **[Tool or Resource Name](URL)** — Short and clear description.
```

For GitHub repositories:

```markdown
### Repository Name

**Repository:** `owner/repository`

Short description.

Useful for:

- Topic 1
- Topic 2
- Topic 3
```

## Avoid

* Duplicate entries
* Broken links
* Promotional-only resources
* Unrelated tools
* Unverified claims
* Copying descriptions without attribution
* Outdated information presented as current

---

# 📚 Original 15-Repository Source

The original collection of 15 repositories was based on the article:

**“15 Best GitHub Repos to Learn DevOps”**

Author: **Tech Fusionist**

Published: **October 25, 2025**

Original article:

https://medium.com/@thetechfusionist/15-best-github-repos-to-learn-devops-eed9ea119f49

> The 15 repositories have been incorporated into the broader resource structure above rather than maintaining a separate duplicate section.

---

# ⚠️ Resource Status Notice

DevOps tools and repositories change frequently.

Repository:

* Stars
* Contributors
* Releases
* Documentation
* Supported technologies
* Licensing
* Maintenance status
* Availability

can change over time.

Always check the project's current repository and official documentation before using a resource in a production environment.

---

# 📌 Important Note

This repository is a **learning and reference collection**, not a recommendation to use every listed technology.

Different organizations use different DevOps stacks.

For example:

```text
CI/CD:
Jenkins OR GitHub Actions OR GitLab CI

IaC:
Terraform OR OpenTofu OR CloudFormation OR Pulumi

Containers:
Docker OR Podman

Orchestration:
Kubernetes OR another orchestrator

GitOps:
Argo CD OR Flux

Monitoring:
Prometheus + Grafana
OR
Commercial observability platforms

Logging:
Loki
OR
Elastic Stack
OR
Commercial logging platforms
```

The goal is to understand **the problem each category solves**, then choose appropriate tools for the project.

---

# ⭐ Quick Reference

```text
FOUNDATION
├── Linux
├── Networking
├── Git
├── Programming
└── Bash

CONTAINERS
├── Docker
├── Podman
└── Container Registry

CI/CD
├── Jenkins
├── GitHub Actions
└── GitLab CI

INFRASTRUCTURE
├── Terraform
├── OpenTofu
├── CloudFormation
└── Pulumi

CONFIGURATION
└── Ansible

CLOUD
├── AWS
├── Azure
├── Google Cloud
├── IBM Cloud
└── Oracle Cloud

KUBERNETES
├── Kubernetes
├── Helm
├── Ingress
├── Services
├── Storage
└── Networking

GITOPS
├── Argo CD
└── Flux CD

SECURITY
├── SonarQube
├── Trivy
├── Vault
├── OPA
└── Kyverno

OBSERVABILITY
├── Prometheus
├── Grafana
├── Loki
├── Elastic
└── OpenTelemetry

RELIABILITY
├── SRE
├── SLIs
├── SLOs
├── Alerting
└── Incident Management
```

---

# 🔗 Useful External Resource Collections

### DevOps Tool Directories

* Periodic Table of DevOps Tools
* DevOps Tool Chest
* CNCF Cloud Native Landscape
* DevOps Bookmarks

### Learning

* Linux Journey
* Learn Git Branching
* KodeKloud
* Google Cloud Skills Boost
* Exercism
* HackerRank
* LeetCode

### System Design

* System Design Primer
* System Design Notebook
* Distributed Systems Reading List

---

# 🗺️ Roadmap Visuals

If this repository contains roadmap images, keep them in the `images/` directory and link them here.

Recommended roadmap visuals:

```text
images/
├── linux_map.png
├── python_map.png
├── jenkins_map.png
└── terraform_map.png
```

Example:

```html
<div align="center">
  <img src="images/linux_map.png" alt="Linux Roadmap">
</div>
```

---

# 📜 License

If this repository combines material from multiple external projects, articles, or resource collections, verify the license and attribution requirements of each source before redistributing copied content.

For original content created specifically for this repository, choose an appropriate license and add the corresponding license file.

---

# ⭐ Support the Project

If this collection helps you learn DevOps:

* ⭐ Star the repository
* 🍴 Fork it
* 🐛 Report broken links
* 💡 Suggest useful resources
* 🔧 Submit improvements
* 📚 Share useful learning material

---

# 🚀 Keep Learning

DevOps is a continuous learning process.

Start small:

```text
Learn
  ↓
Practice
  ↓
Build
  ↓
Break
  ↓
Troubleshoot
  ↓
Automate
  ↓
Monitor
  ↓
Improve
```

The objective is not to memorize hundreds of tools.

The objective is to understand:

> **What problem does this tool solve, where does it fit in the workflow, and how does it connect with the other parts of the system?**

Happy Learning! 🚀
