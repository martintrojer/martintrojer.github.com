---
categories:
- software
date: "2015-02-22T00:00:00Z"
description: ""
tags:
- docker
- devops
title: Moving my devboxes to Docker
---
I've been quite vocal about my opinions on development environments and automating the creation of them [on this blog]({{< ref "2014-12-04-developing-clojure-in-the-cloud.md" >}}) and [elsewhere](https://skillsmatter.com/skillscasts/6056-developing-clojure-in-the-cloud). Boiling it down to the 2 points I feel most strongly about it would be;

1. Always develop in a production-like environment
2. Automate the creation of these environments

<!--more-->

By production-like I mean developing in the same OS distribution and version as production, using the same database versions, the same message broker, as similar settings as possible, etc. Automation allows these environments to be disposable speeding up teams working on the project and also enables 'developing in the cloud' as described in my previous post (see above). Development environments shouldn't be a precious resource that you spend hours setting up (following outdated Wiki pages).

Up-to now production-like meant (for me atleast) VMs. However, the uprising of Docker has now lead me to believe that future deployments I'd encounter will involve containers. I have personally moved all of my 'hobby projects' over the Docker.

Is it possible to do your work inside containers similar to they way you can do in VMs? The answer is yes, and you will be able to enjoy the benefits Docker brings while adhering to my 2 laws of devboxes. I've created 2 basic container setups to cater for my devbox needs;

## The hybrid devbox

You typically run one service per container so a development setup would be a handful of containers with your database, message broker etc. Then you create another container with [links](https://docs.docker.com/userguide/dockerlinks/) (by using [Fig](http://www.fig.sh/) for instance) where you put your app's runtime (the JVM, golang toolchain etc). If the dev container is running locally (which is most convenient for this setup) you will also use a [shared folder](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume) to mount you source into the container.

If you are writing Clojure its trivial to connect to nREPL running in the dev container, and if you are using something like golang you'd run a shell in this container where you build, run and debug your code. One caveat is that some emacs/vim modes and IDEs shell-out to the language toolchain in order to analyze the code for navigation etc. With the hybrid setup you might therefore need to have a local install of the toolchain aswell as the one inside the container. This works out quite well in my experience, especially since the source folder is shared.

This setup satisfies the 2 laws listed above, the container you are developing is production-like since you are using the same base image (and most of the Dockerfile hopefully) as the deployment image. The creation of this container is also completely automated and the container can be pushed to a registry and shared with team members.

## The all-in devbox

In this scenario you want to move your entire development environment into the container (including you editor, dotfiles etc). One compelling argument for doing this is to enable remote devboxes, i.e. 'developing in the cloud'. This is handy for remote (and local) pairing sessions with shared screens (tmux attach) or when the network characteristics of the remote container is important for your task/analysis at hand. For instance running ETL/migrations jobs from an AWS instance can be orders of magnitude faster than from your local machine.

In this scenario the provisioning becomes more expensive, since you have to check out all the repos, run sshd etc on the containers. But if you do it correctly, and set up all users on the containers this price can be paid once and then shared by all the devs on the team.

## Example

I've created a repo on github with examples of both types of devboxes, [see here](https://github.com/martintrojer/devbox-docker).
