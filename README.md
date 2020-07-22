# pipeline-demo

## AWOOOGA! AWOOOGA! WORK IN PROGRESS!

This is a terraform repo with compontents for telling a variety of CI/CD focused Chef Habitat stories, using Jenkins as the pipeline of choice. 

I'll be looking to get this more fully documented shortly, but for my brave early adopters, here's a brief rundown of what's included:

* Jenkins server
  * Uses the `nrycar/jenkins` habitat package, which is a combination of the `core/habitat` config with some plugin and credentials management created by indellient and the Chef training team
  * Will automatically create credentials for your bldr depot token, and peer supervisor token (see tfvars)
  * No workers provisioned. Will do everything locally (linux only)
* Sample Node App
  * Dev Environment: 1 x Peer, 1 x App
  * Prod Environment: 1 x Peer, App instances defined by sn_prod_count var
  * Deployment Strategy: Canary
    * Deploys first to a single canary, then to 50% of the nodes, then to the rest. Make sure sn_prod_count is a minimum of 3.
* National Parks App
  * Dev Environment: 1 x Peer, 1 x mongodb, 1 x App, 1 x haproxy
  * Prod Environment: 1 x Peer, 1 x mongodb, 1 x Haproxy, App instances defined by np_prod_count var
  * Deployment Strategy: Blue/Green
    * Will use the supervisor API to set a deployment flag for blue, removing it from the LB, then deploys there. Will do the same in reverse for green next. Nodes are automatically divided into groups (np_prod_count / 2)

## Prerequisites:

This project was built off of some projects in Rycar's GitHub/Builder accounts, so you'll need to replicate some things before everything will work.

* For the infra/audit origin, you can make them 'nrycar' to just use my packages for Infra/InSpec. This is probably the easiest path there.
* You will need your own National Parks and Sample Node App packages. These are based off of the public apps of the same names. For both, you'll need to make sure:
  * They have a github repo associated with the Builder package
  * There is a github API token for access to the projects
  * Each project has a Jenkinsfile (see the versions in the ChefRycar github for examples)

When the project launches, assuming you've put in valid auth tokens for your Builder origin, you should be able to login to the Jenkins server with the credentials defined in tfvars. If you then go into BlueOcean, you should be able to create pipelines for your projects (it'll prompt you for your github auth token in the UI). So long as your github projects have proper Jenkinsfiles, the pipelines should **Just Work (tm)** so far as deploying/promoting is concerned.

For reference, my projects' Jenkinsfiles can be found at:
* Sample Node App: https://github.com/ChefRycar/sample-node-app/blob/master/Jenkinsfile
* National Parks: https://github.com/ChefRycar/national-parks/blob/master/Jenkinsfile
* Contoso University (WIP! Requires Windows Worker!): https://github.com/ChefRycar/contosouniversity/blob/master/Jenkinsfile

