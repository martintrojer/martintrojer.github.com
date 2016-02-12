FROM ubuntu:wily

RUN apt-get -y update
RUN apt-get -y install net-tools build-essential tmux ruby ruby-dev nodejs python
RUN gem install jekyll rake

WORKDIR /work
# --force_polling
CMD jekyll serve --watch --force_polling --incremental --drafts --host $(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
