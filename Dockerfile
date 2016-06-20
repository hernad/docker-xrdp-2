FROM hernad/xrdp-syncthing

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    git \
                    wget \
                    curl openssl ca-certificates \
                    libgtk2.0-0 \
                    libxtst6 \
                    libnss3 \
                    libgconf-2-4 \
                    libasound2 \
                    fakeroot \
                    gconf2 \
                    gconf-service \
                    libcap2 \
                    libnotify4 \
                    libxtst6 \
                    libnss3 \
                    gvfs-bin \
                    xdg-utils \
                    build-essential \
                    ack-grep \
                    exuberant-ctags \
                    g++ \
                    openjdk-7-jdk maven \
                    vim-gtk \
                    libpq-dev \
                    postgresql-client \
                    libx11-xcb-dev \
                    libxcb1-dev \
                    uncrustify \
                    wmname xcompmgr \
                    software-properties-common \
                    xclip tmux tree jq &&\
                    apt-get remove -y vim-tiny &&\
                    apt-get clean -y


ENV JAVA8_UPD 66
ENV JAVA8_BUILD 17
ENV JAVA_HOME /opt/java

RUN     cd /tmp \
        && wget -qO jdk8.tar.gz \
         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
         http://download.oracle.com/otn-pub/java/jdk/8u${JAVA8_UPD}-b${JAVA8_BUILD}/jdk-8u${JAVA8_UPD}-linux-x64.tar.gz \
        && tar xzf jdk8.tar.gz -C /opt \
        && mv /opt/jdk* /opt/java \
        && rm /tmp/jdk8.tar.gz \
        && update-alternatives --install /usr/bin/java java /opt/java/bin/java 100 \
        && update-alternatives --install /usr/bin/javac javac /opt/java/bin/javac 100 \
        && update-alternatives --install /usr/bin/jar jar /opt/java/bin/jar 100 \
        && update-alternatives --set java /opt/java/bin/java \
        && update-alternatives --set jar /opt/java/bin/jar


ENV HOME_BRC /home/dockerx/.bashrc
RUN echo "export GOROOT=/usr/local/go" >> $HOME_BRC &&\
    echo "export GOPATH=/home/dockerx/go" >> $HOME_BRC &&\
    echo "export PATH=\$PATH:\$GOROOT/bin" >> $HOME_BRC &&\
    echo "export JAVA_HOME=/opt/java" >> $HOME_BRC &&\
    echo "java -version " >> $HOME_BRC


EXPOSE 3389

ENV ROOT_BRC /root/.bashrc
RUN echo "export GOROOT=/usr/local/go" >> $ROOT_BRC &&\
    echo "export GOPATH=/home/dockerx/go" >> $ROOT_BRC &&\
    echo "export PATH=\$PATH:\$GOROOT/bin" >> $HOME_BRC &&\
    echo "java -version " >> $ROOT_BRC &&\
    echo "go version" >> $ROOT_BRC &&\
    echo "node --version" >> $ROOT_BRC &&\
    echo "erl -noshell -eval 'io:fwrite(\"~s\\n\", [erlang:system_info(otp_release)]).' -s erlang halt" >> $ROOT_BRC &&\
    echo "[ -z "$DISPLAY" ] && export TERM=linux" >> $ROOT_BRC

ADD ratpoisonrc /home/dockerx/.ratpoisonrc

#ADD firefox_override.ini /usr/lib/firefox/override.ini
#RUN sed -i -e 's/EnableProfileMigrator=1/EnableProfileMigrator=0/g' /usr/lib/firefox/application.ini

#RUN dpkg --add-architecture i386 &&\
#    apt-get dist-upgrade -y &&\
#    add-apt-repository -y ppa:ubuntu-wine/ppa &&\ 
#    apt-get update && apt-get install -y wine1.7 &&\
#    apt-get clean

WORKDIR /

RUN apt-get install -y devscripts dh-make dpkg-dev checkinstall apt-transport-https

# dput-webdav

RUN echo "deb http://dl.bintray.com/jhermann/deb /" \
       > /etc/apt/sources.list.d/bintray-jhermann.list \
       && apt-get update \
       && apt-get install -y -o "APT::Get::AllowUnauthenticated=yes" dput-webdav
 
ADD start.sh /
RUN echo "deb http://dl.bintray.com/hernad/deb /" \
       > /etc/apt/sources.list.d/bintray-hernad.list \
       && apt-get update \
       && apt-get install -y -o "APT::Get::AllowUnauthenticated=yes" harbour

# postgresql repository
ENV PSQL_VER 9.5
RUN  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list &&\
     wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add  - &&\
     apt-get update -y &&\
     apt-get install -y postgresql-$PSQL_VER pgadmin3

# harbour dependencies 
RUN apt-get install -y libmysqlclient-dev libpq-dev libx11-dev

# ag - silver search
RUN  apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev &&\
     mkdir -p /usr/src && cd /usr/src/ ; git clone https://github.com/ggreer/the_silver_searcher.git &&\
     cd the_silver_searcher && export LDFLAGS="-static" && ./build.sh &&\
     make install

# --- aws cli
RUN apt-get install -y python-virtualenv &&\
    cd /opt &&\
    virtualenv --python=/usr/bin/python aws &&\
    cd /opt/aws &&\
    . bin/activate && pip install --upgrade pip &&\
    pip install awscli


RUN echo "===> Adding Ansible's PPA..."  && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee /etc/apt/sources.list.d/ansible.list           && \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/ansible.list    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible..."  && \
    apt-get install -y ansible  && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    echo '[local]\nlocalhost\n' > /etc/ansible/hosts

# --- ansible
# RUN cd /opt &&\
#    virtualenv --python=/usr/bin/python ansible &&\
#    cd /opt/ansible &&\
#    . bin/activate && pip install --upgrade pip &&\
#    pip install ansible

RUN apt-get install -y exuberant-ctags p7zip-full cabextract


RUN apt-get install -y libpng-dev

#RUN apt-get install -y --no-install-recommends \
#        byobu \
#        ca-certificates \
#        command-not-found \
#        dbus \
#        fuse \
#        language-pack-en-base \
#        less \
#        mr \
#        paprefs \
#        pulseaudio-utils \
#        sudo \
#        supervisor \
#        tango-icon-theme \
#        vcsh \
#        vim-nox \
#        wget \
#        xfonts-base \
#        xubuntu-artwork \
#        xfce4-session \
#        xterm \
#        zsh \
#    && apt-get clean

RUN apt-get install -y xfonts-base fuse xfonts-terminus
USER dockerx

RUN echo "[ -f /syncthing/data/configs/\`hostname\`/bash_config.sh ] && source /syncthing/data/configs/\`hostname\`/bash_config.sh " >> $HOME_BRC &&\
    echo "[ \$SYNCTHING_API_KEY ] &&  echo -n 'syncthing version:' && curl --silent -X GET -H \"X-API-Key: \$SYNCTHING_API_KEY\" http://localhost:8384/rest/system/version | jq .version" >> $HOME_BRC
ENV echo "PATH=\$PATH:/usr/local/Qt/bin:/opt/aws/bin" >> $HOME_BRC


USER root
RUN apt-get install -y evince
ADD F18 /home/dockerx/F18
ADD F18 /home/xrdp/F18


ADD ratpoisonrc /home/dockerx/.ratpoisonrc
ADD xinitrc /home/dockerx/.xinitrc
RUN adduser dockerx sudo
RUN adduser dockerx fuse

RUN useradd -m -d /home/docker2 -p docker2 docker2
RUN echo 'docker2:docker2' |chpasswd
RUN chsh -s /bin/bash docker2
RUN adduser docker2 sudo
RUN adduser docker2 fuse
ADD ratpoisonrc /home/docker2/.ratpoisonrc
ADD xinitrc /home/docker2/.xinitrc

RUN add-apt-repository ppa:libreoffice/ppa &&\
    apt-get update -y &&\
    apt-get install -y libreoffice libreoffice-script-provider-python uno-libs3 python3-uno python3
 

CMD ["bash", "-c", "/etc/init.d/dbus start ; /etc/init.d/cups start; /start.sh ; /usr/bin/supervisord"]

