# Polkadot automator

This project automates the deploy and provisioning of a [Polkadot](https://polkadot.network) node on Google Cloud, and attach on Kusama network.

## Tools

- [Terraform](https://www.terraform.io) provide the structure at the GCP.
- [Ansible](https://www.ansible.com) execute playbooks and install required softwares over the VM.
- [Docker](https://www.docker.com) abstract all tools and don't blow up your localhost.

## Prerequisites

* [Docker](https://docs.docker.com/engine/installation/)

## Getting started

### Setup

First off all, clone this repository and setup the docker image with all the tools to get things done.

```bash
$ git clone https://github.com/evaldofelipe/polkadot-automator.git
$ cd polkadot-automator
$ make setup
```

This process take a wile. Use this time to create the GCP project at console.


<details>
<summary>New at Google Cloud? Follow these steps!</summary>
<br>

- If you don't have a GCP account yet, you could use the the free trial provide by google to execute this project.
You can create your free account [here](https://cloud.google.com/free).

- After create the account ready, you need create a project. Follow [this](https://cloud.google.com/resource-manager/docs/creating-managing-projects) documentation to guide you.

**IMPORTANT:**
Choose a project name as you want, and store the `project_ID` not the project name! You'll use later on the project.

- After the project was created, we need interact with GCP using a Service Account, an key file provide to use cloud API's. Follow [this](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) guide to create the Service Account, with Owner/Owner permissions, download the json file (the create key button are just a bit hide!), and store the file on a security place. Ansible and terraform will use this key to interact with GCP.

- On this automation are possible to choose the region where your VM are deployed, but as a new GCP user, I recommend, don't worry about it, and use the default region already set here.

<br><br>
</details>

___

<details>
<summary> Already GCP user? Come on this way!</summary>
<br>

- At this time, this project don't support the project automatic creation, because the trial account don't have a main organization to control the projects. So it's necessary create a new project on the console.

- Create the project and store and store the `project_ID`. You'll use later on the project.

- Create a Service Account on the new project, with Owner/Owner permissions, download the json, and store the file on a security place. Ansible and terraform will use this key to interact with GCP.

- If you want change the default Region and Zones defined here, just keep in mind to don't forget to select the right variables. If you need, take a look on the regions [list](https://cloud.google.com/compute/docs/regions-zones).

<br><br>
</details>


### Finish the local setup

**IMPORTANT:** On this automation we assume your ssh keys are stored at `$HOME/.ssh/` with the names `id_rsa` and `id_rsa.pub` if you're using other path, edit the path at `Makefile` on line `13`:

```bash
--volume $(HOME)/.ssh/:/home/polkadot/.ssh/:ro \
```

With a new project, and their respective Service Account, export your SA as a env variable, and the project ID.


```bash
$  export GCP_TOKEN=$(cat /path/to/your/key.json)
$  export PROJECT="your-project-ID"
```

Choose the number of polkadots nodes you want deploy, and their respective names at `ansible/all.yml`

```yaml
- polkadot_node_name: "YOUR-POLKADOT-NODE-NAME-HERE"
- polkadot_node_count: 4
```

After this modifications, you're good to go!

## Deploy resources

### creating the infrastructure

To create the environment, execute:

```bash
$ make build-all
```

### provisioning the polkadot

After the VM was deployed, configure executing:

```bash
$ make provision-all
```

## Check service status

You could check you polkadot node running with the name you have choosed on the polkadot network telemetry [here](https://telemetry.polkadot.io/). Just ensure you have selected the Kusama network to find your node.


## Destroy the infrastructure

After realize your tests, you can destroy everything just running:

```bash
$ make destroy-all
```
