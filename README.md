# Slurmathon 2024-01-23:24

## Goal 

> Build a HPC cluster and Connect to explore the Connect <--> HPC integration, cf.

> Other material that may be helpful here is GitHub - michaelmayer2/penguins-hpc: Penguins glm goes HPC R/Shiny Apps with HPC , clustermq – example [Asynchronous Shiny apps](https://cran.r-project.org/web/packages/crew/vignettes/shiny.html)  (the latter could be enriched with crew.cluster

## TODO

- [x] Test example, show works on Workbench 
- [x] Deploy Connect on slurm head node, integrated auth
- [x] Test example that works with Connect deployed on the slurm head node 
- [] Deploy external Connect server
- [] Test example that works with Connect deployed on a separate server
- [] Example declaring a specific singularity container to use
- [] Add ALL the progress bars! (What even is a progress bar when parallelized??)

## Requirements

Make sure Connect server can submit to slurm cluster, at a minimum these are needed: 

- auth subsystem
- mount home directory
- munge key 
- slurm binaries
- networking

> The easiest option, if possible, is to install Connect on the slurm headnode. This way the above requirements are already in place. 

## Parallelization resources 

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

## Mental model: 

- Set appropriate permissions, install requirements
- Run content on Connect
- Content calls clustermq for leveraging slurm resources
- Job is launched from Connect into slurm 
- When done the results are returned
- Use different parallelization tools: clustermq, future, batchtools, crew.cluster


## Set up Connect on Slurm head node 

### Setup

Log in to AWS
```
aws-assume eu-west-1
aws sso login
aws sts get-caller-identity
```

(optional) Python venv
```
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
python3 -m pip install --upgrade pip wheel setuptools
pip install -r requirements.txt
```

SSH into one of the slurm_head-node ec2 instances to configure further:

```
#connect using aws - this is the best option
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


(optional) Exit the ssh session: `exit`

### Installation 

Get your operating system version: 

```bash
lsb_release -a
cat /etc/os-release
```

Check that R is installed: 

```bash
ls -ld /opt/R/*
```

Check that Python is installed: 

```bash
ls -ld /opt/python/*
```

Check for prior installations of the products: 

```bash
#Connect
/opt/rstudio-connect/bin/connect --version
#Workbench
rstudio-server version
#Package Manager
rspm --version
```

Install Connect 

```bash
sudo apt-get install gdebi-core
curl -O https://cdn.posit.co/connect/2023.12/rstudio-connect_2023.12.0~ubuntu20_amd64.deb
sudo gdebi rstudio-connect_2023.12.0~ubuntu20_amd64.deb
```

Consider installing system dependencies: <https://docs.posit.co/connect/admin/getting-started/local-install/manual-install/#system-dependencies-for-r-packages> 

For example on Ubuntu 20.02

```bash
apt install -y tcl tk tk-dev tk-table default-jdk libxml2-dev libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev git make libfontconfig1-dev cmake libsodium-dev libcairo2-dev libpng-dev libjpeg-dev libmysqlclient-dev unixodbc-dev libicu-dev libtiff-dev zlib1g-dev libcurl4-openssl-dev libssh2-1-dev libudunits2-dev perl libgdal-dev gdal-bin libproj-dev python3 imagemagick libmagick++-dev gsfonts libgeos-dev libsqlite3-dev libglu1-mesa-dev libgl1-mesa-dev libnode-dev libglpk-dev libgmp3-dev
```

Check for a license activation: 

```bash
sudo /opt/rstudio-connect/bin/license-manager status
```

Activate the license 

```bash
sudo /opt/rstudio-connect/bin/license-manager activate <LICENSE-KEY>
```

Configure: 

`sudo nano /etc/rstudio-connect/rstudio-connect.gcfg`

```
# /etc/rstudio-connect/rstudio-connect.gcfg

[Server]
Address = http://{{rsc_ip_address}}:3939
; Address = http://localhost:3939
EmailProvider = "SMTP"
SenderEmail = "from@example.com"

[SMTP]
Host = "smtp.mailtrap.io"
Port = 587
User = {{mail_trap_user}}
Password = {{mail_trap_password}}

[HTTP]
Listen = ":3939"
NoWarning = true

[Authentication]
; Provider = "password"
Provider = "pam"

[PAM]
RegisterOnFirstLogin = true
; These default values should be adjusted
; accord to the level of PAM support desired:
;Service = "rstudio-connect"
;UseSession = false
;ForwardPassword = false
; When troubleshooting a PAM authentication problem, more verbose
; logging is produced by uncommenting the following line:
;Logging = true


; [Application]
; RunAsCurrentUser = true

;[Default Users]
;[Authorization]

[RPackageRepository "CRAN"]
URL = "https://packagemanager.rstudio.com/cran/__linux__/focal/latest"

[RPackageRepository "RSPM"]
URL = "https://packagemanager.rstudio.com/cran/__linux__/focal/latest"
```

Optionally for PAM: PAM.AuthenticatedSessionService: The PAM service used for running processes as the currently logged-in user with the user’s password. Requires PAM.UseSession, PAM.ForwardPassword, and Applications.RunAsCurrentUser to be enabled. This is useful in Kerberos configurations to allow the running content to access authenticated resources as the visiting user. (refer to: <https://docs.posit.co/connect/admin/authentication/pam-based/pam/>)

```bash
sudo cp /etc/pam.d/login /etc/pam.d/rstudio-connect
```

Restart the server: 

```bash
sudo systemctl stop rstudio-connect
sudo systemctl start rstudio-connect
```

Verify the installation 

```bash
sudo systemctl status rstudio-connect 2>&1 | tee status.txt
```

Access your Connect instance at: `<your ip address>:3939`

### Troubleshooting

Slurm 

- Show slurm node status: just server-slurm-sinfo
- Show slurm queue: just server-slurm-squeue
- There is a queue limit based on the resources on the server (in experience roughly 2 open sessions, but if session size is reduced more sessions can be opened) so close open sessions as needed to create new ones.
- Reference: <https://mschubert.github.io/clustermq/articles/userguide.html#debugging-workers> 

Python

- Check python version, make sure it is a supported version (for example, 3.10.8 worked as of 8/1/2023): python --version
- Check available python versions: ls -1d /opt/python/*
- (Optional) update the python alias to point towards the desired python version: alias python="/opt/python/3.10.8/bin/python3"
- Check python packages and their versions: pip list
- Leave a venv with: deactivate

Connect Logs

- View status with `sudo rstudio-connect status 2>&1 | tee status.txt`
- Similarly, view errors with `sudo tail -n 50 /var/log/rstudio/rstudio-connect/rstudio-connect.log | grep error*`

Restarting Connect: 

```
sudo systemctl stop rstudio-connect
sudo systemctl start rstudio-connect
sudo systemctl status rstudio-connect
```

Workbench Logs

- View status with rstudio-server status or rstudio-server status 2>&1 | tee status.txt
- View logs with sudo tail -n 50 /var/log/rstudio/rstudio-server/rserver.log
- View logs with sudo tail -n 50 /var/log/rstudio/launcher/rstudio-launcher.log
- For errors, it's also useful to cat /var/log/syslog in addition to the rstudio specific log files.

Restarting Workbench: After making a change manually to files on the server, bring the cluster back up with:

- Restart the Workbench service (run on both nodes): sudo systemctl restart rstudio-server
- Restart the Launcher service (run on both nodes): sudo systemctl restart rstudio-launcher
- Reset the cluster (run on any one node): sudo rstudio-server reset-cluster
- Debugging: sudo rstudio-server list-nodes


## Slurm interaction 

Show slurm node status: `just server-slurm-sinfo`

Show slurm queue: `just server-slurm-squeue`

There is a queue limit based on the resources on the server (in experience roughly 2 open sessions, but if session size is reduced more sessions can be opened) so close open sessions as needed to create new ones.

Active processes:

```
ps -ufxa 
```

```
Scontrol show job 38 
```

Kill job as rstudio user or slurm admin

```
Sudo -s 
sudo -u rstudio scancel 33
Sudo -s 
su - rstudio
scancel 34 (jobid)
Exit
Exit # -> brings back to ubuntu 
```

From workbench: 

```
env | grep SINGU
```

## What happens when a piece of Connect content is interrupted? 

## Progress bars

Unhelpful posts from similar users:

- <https://community.rstudio.com/t/capture-progress-from-foreach-dopar-in-a-shiny-app/6859> (no response)
- <https://stackoverflow.com/questions/66734433/how-to-make-shiny-progress-bar-work-when-using-foreach> (no responses) 
- <https://stackoverflow.com/questions/51213293/is-it-possible-to-get-a-progress-bar-with-foreach-and-a-multicore-kind-of-back?rq=4> (proposed band aid solution)
- <https://stackoverflow.com/questions/54532486/using-standard-r-shiny-progress-bar-in-parallel-foreach-calculations?rq=4> 
- <https://stackoverflow.com/questions/51158214/r-shiny-async-with-progress-bar?rq=4> (futures)
- <https://stackoverflow.com/questions/5423760/how-do-you-create-a-progress-bar-when-using-the-foreach-function-in-r?rq=4> (dosnow, not shiny)
- <https://www.r-bloggers.com/2015/03/creating-progress-bars-with-foreach-parallel-processing/> (old article from Andrie)
- <https://github.com/r-lib/progress/issues/97> 
- <https://github.com/r-lib/progress/issues/39> ("In general this is not possible currently, I believe. You might get lucky if the parallel processes use the same terminal as the main process, but in general we would need support from parallel to implement this.")
- <https://mastering-shiny.org/action-feedback.html#progress-bars> (mastering shiny on progress bars, doesn't include foreach)
- <https://stackoverflow.com/questions/30474538/possible-to-show-console-messages-written-with-message-in-a-shiny-ui> (capture console messages)


