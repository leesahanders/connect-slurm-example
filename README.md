# connect-slurm-example

A subset of customers request options for leveraging Connect with Slurm. 

- What do customers want for an integration with Slurm for the Connect product? (Shiny apps, remote submitting, replacing k8s with slurm, etc)
- What are the current ways to achieve what customers are wanting?

Internal reference: <https://positpbc.atlassian.net/wiki/spaces/SE/pages/544538869/2023-12-19+Connect+with+Slurm> 

# Requirements

Make sure Connect server can submit to slurm cluster, at a minimum these are needed: 

- auth subsystem
- mount home directory
- munge key 
- slurm binaries
- networking

> The easiest option, if possible, is to install Connect on the slurm headnode. This way the above requirements are already in place. 

# Parallelization resources 

Michael's workshop: <https://luwidmer.github.io/fastR-website> and early attempt of building Connect app with remote submission to hpc cluster: <https://github.com/michaelmayer2/penguins-hpc> and in depth applied useage of clustermq: <https://michaelmayer.quarto.pub/clustermq/>

Roger's slides: <https://colorado.posit.co/rsc/parallel_thinking/Parallel_Thinking.html>

David's slides: <https://edavidaja.github.io/parallelooza/>
Slack with link to git:[https://positpbc.slack.com/archives/G02HSFX6BEF/p1700078096823639](https://positpbc.slack.com/archives/G02HSFX6BEF/p1700078096823639)
- [slides and example R code](https://github.com/edavidaja/parallelooza) using `future.batchtools` and `clustermq` are here (the `crew.cluster` code doesn't work yet)
- [if the example HPC diagram seems familiar](https://edavidaja.github.io/parallelooza/#/hpc-1) it's because it's from [@michael](https://positpbc.slack.com/team/U02H40QEC84)'s presentation at SE work week


Recommended packages:

- Clustermq: [clustermq - About](https://michaelmayer.quarto.pub/clustermq/) 
- batchtools: [A Future API for Parallel and Distributed Processing using batchtools](https://future.batchtools.futureverse.org/) 

Bias towards recommending clustermq as it has less overhead

# Mental model: 

- Set appropriate permissions, install requirements
- Run content on Connect
- Content calls clustermq for leveraging slurm resources
- Job is launched from Connect into slurm 
- When done the results are returned
- Use different parallelization tools: clustermq, future, batchtools, crew.cluster


# Set up Connect on Slurm head node 

## Setup

Log in to AWS
```
aws-assume eu-west-1
aws sso login
aws sts get-caller-identity
```

Python venv
```
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
python3 -m pip install --upgrade pip wheel setuptools
pip install -r requirements.txt
```

SSH into one of the slurm_head-node ec2 instances to configure further:

```
#connect using aws 
aws ssm start-session --target <instanceID>

#alternatively use the public dns address
ssh -i key.pem -o StrictHostKeyChecking=no ubuntu@$(public_dns)

#alternatively connect with pulumi
ssh -i key.pem -o StrictHostKeyChecking=no ubuntu@$(pulumi stack output slurm_head-node-1_public_dns)

#alternatively port forward into a Workbench node to access Workbench directly (without any proxy) with something like
ssh -i key.pem -L 8787:<public dns>:8787 ubuntu@<public dns>

#reference a key file in another location
ssh -i .ssh/ec2_1_keys.pem ubuntu@<ip address>
```

You can use passwordless `sudo -s` to become root and then `su - ubuntu` to become `ubuntu` - `ubuntu` is able to log into both head node and compute nodes. Workbench runs on the head node - config is in `/opt/rstudio/etc/rstudio`.


Exit the ssh session: `exit`






## Troubleshooting

Slurm 

- Show slurm node status: just server-slurm-sinfo
- Show slurm queue: just server-slurm-squeue
- There is a queue limit based on the resources on the server (in experience roughly 2 open sessions, but if session size is reduced more sessions can be opened) so close open sessions as needed to create new ones.

Python

- Check python version, make sure it is a supported version (for example, 3.10.8 worked as of 8/1/2023): python --version
- Check available python versions: ls -1d /opt/python/*
- (Optional) update the python alias to point towards the desired python version: alias python="/opt/python/3.10.8/bin/python3"
- Check python packages and their versions: pip list
- Leave a venv with: deactivate

Logs

- View status with rstudio-server status or rstudio-server status 2>&1 | tee status.txt
- View logs with sudo tail -n 50 /var/log/rstudio/rstudio-server/rserver.log
- View logs with sudo tail -n 50 /var/log/rstudio/launcher/rstudio-launcher.log
- For errors, it's also useful to cat /var/log/syslog in addition to the rstudio specific log files.

Restarting: After making a change manually to files on the server, bring the cluster back up with:

- Restart the Workbench service (run on both nodes): sudo systemctl restart rstudio-server
- Restart the Launcher service (run on both nodes): sudo systemctl restart rstudio-launcher
- Reset the cluster (run on any one node): sudo rstudio-server reset-cluster
- Debugging: sudo rstudio-server list-nodes

# R Examples 

## shiny-app 

## quarto-report 

# TODO

- Example that works on Workbench 
- Example that works with Connect deployed on the slurm head node 
- Example that works with Connect deployed on a separate server
- progress bar

