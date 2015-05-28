FROM ubuntu:trusty

RUN apt-get -y update
RUN apt-get -y install build-essential ruby-dev nodejs python
RUN gem install jekyll rake
RUN apt-get -y install tmux

WORKDIR /work
# --force_polling
CMD jekyll serve --host $(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')