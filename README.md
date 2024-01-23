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

# R Examples 

## shiny-app 

## quarto-report 

# TODO

- Example that works on Workbench 
- Example that works with Connect deployed on the slurm head node 
- Example that works with Connect deployed on a separate server
- progress bar

