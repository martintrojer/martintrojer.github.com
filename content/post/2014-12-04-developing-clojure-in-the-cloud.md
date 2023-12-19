---
categories:
- clojure
date: "2014-12-04T00:00:00Z"
description: ""
tags:
- clojure
- aws
- cloud
title: Developing Clojure in the Cloud
---
Recently I gave a talk at the [Clojure eXchange 2014](https://skillsmatter.com/conferences/1956-clojure-exchange-2014) titled 'Developing Clojure in the Cloud'. I described a way of creating and using (Clojure) development environments inside VMs, I've been developing like this for the last year (spanning 2 projects).

<!--more-->

[Download the slides here](/assets/images/devcloud/developing-clojure-in-the-cloud.pdf)

[Video recording here](https://skillsmatter.com/skillscasts/6056-developing-clojure-in-the-cloud)

The basic idea is to move your entire development environment into a VM and thus creating a controlled environment for all your dependencies (OS distribution, Java version, database version etc). You also provision this VM with your dotfiles and run your text editor inside it. In both projects I've been able to use the same provisioning scripts (in both cases puppet) to build my devboxes as was used to build the production environments. It's been a bit of revelation for myself to be able to practically 'develop in prod', and during this time I've never once uttered the dreaded words 'But it works on my machine!'.

I've created a [repository on github](https://github.com/martintrojer/devbox) which I used as starting point for my last project. One highlight of this example is that it supports multiple users and pairing out of the box. That reason alone is usually enough to adopt it.

### Pros

* No more WOMM!
* No more (outdated) Wikis/napkins describing how to setup the development environment. A devbox is fully built (users created with dotfiles applied, git repos cloned) by running one command from the command line.
* Local/remote transparency. Building a remote devbox (on AWS) or a local one (in Virtualbox) is identical, and when using them you can't tell the difference. Interestingly this fact makes the host machine much less relevant, people using OSX, Linux, Windows, ChromeOS can join the project on equal footing.
* Pairing, a killer feature with remote devboxes. Many users can log into the same VM and 'tmux attach'. This works great when people are pairing over Skype, and is surprisingly useful when sitting next to eachother aswell.
* Since the devboxes are 'disposable' (they can be destroyed and recreated over a cup of tea), they give you great freedom to experiment. Install what ever package you want, `sudo make install` etc. If it didn't work, create a new box and you're back in a clean and stable state.
* When working in a small team, without dedicated devops, I've noticed that by automating the creation of devboxes, you automatically get a way to grow these provisioning scripts into a production setup. This is great, because you no longer need to have a big scramble at the end when setting everything up for prod.
* Flipping between projects is as simple as switching VMs. If these project have conflicting versions of services, not a problem.

### Cons

You main interface to VMs are SSH, so this setup works best with editors that can work in terminal mode. Both Emacs and VIM handles this very well, but full blown IDEs less so. I have tried x-forwarding of Emacs/IntelliJ, which is usable for local VMs, but only just.

If you are working on remote devboxes you need a decent network connection that doesn't drop packets. I'd say this is less of an issue in practice but worth considering.

Finally if you are running local VMs, you need spare RAM on you local machine. Hardware spec wise, I'd say 8Gb minimum and 16Gb preferred.

### Hybrid setups

You might find this regimen a bit extreme, but as described above there are some pretty great benefits when moving your entire development environment into a VM.

There are other versions of the same theme, something you're probably familiar with is what I like to call 'Hybrid setups'. Basically you run editor and the software you are working on locally and connect it to databases etc in VMs (either local or remote). In this manner running full blown IDEs is possible, however the overlap between your development environment and deployment environment have now become smaller. In many cases this is a perfectly acceptable compromise, but Murphuys Law still holds and every tiny little difference can (and will!) cause you headaches in the long run. You are also potentially back in 'Wiki-hell' with long instructions on how to set everything up.

Another thing you are giving up is (remote) pairing support.

### Docker

'What about docker?' you might ask yourself. Doesn't it invalidate the approach outlined in this post? Well, yes and no. First of all, I think docker is great and the level of innovation in that container field is impressive.

Sticking to the docker mantra of one-service-per-container you will naturally build hybrid setups as described above (with the same drawbacks). You basically start on container for each service you want to use and connect to them as usual. It does make the setup extremely simple. Something like;

```sh
$ boot2docker start
$ docker run -d postgres
$ docker run -d dockerfile/elasticsearch
```

It is definitely better than lengthy wikis entries, but unless you know that containers will be used in production (and you control the containers) you are again exposing yourself environmental differences.

One of the reasons I've been holding back from pushing Docker to clients is that deployment options have been been spartan, but that is rapidly changing. Amazon just announced the [EC2 container service](http://aws.amazon.com/ecs/) and that takes care of many of my reservations.

Some reservations that do remain is that how to actually construct the more complicated containers (for databases etc) that you rely on. Dockerfiles are just not powerful enough, while [alternatives](http://ianmiell.github.io/shutit/) are being built I feel that these guys are reinventing Chef/puppet. How to handle secuirty updates is another problem area.

There is also a split in the Docker family currently unfolding; CoreOS just announced their Docker alternative [Rocket](https://coreos.com/blog/rocket/). It will be interesting to see where it will end up.

Finally, when talking about non-VM deployment options. One thing that has me really exited is unikernels or library OSes. [OSv](http://osv.io/) and [MirageOS](http://www.openmirage.org/) looks incredibly promising.
