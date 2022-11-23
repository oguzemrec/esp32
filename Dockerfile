FROM ubuntu:latest

RUN apt update
# Install build dependencies and ssh tools
RUN apt-get install -y gcc git wget make libncurses-dev flex bison gperf python3 python3-pip python3-setuptools python3-venv \
                          cmake ninja-build \
                          ccache \
                          vim openssh-server libusb-1.0-0 libhidapi-libusb0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Allow Root Login for SSH
RUN sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config
RUN sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config

RUN service ssh start
RUN  echo 'root:root' | chpasswd
EXPOSE 22

RUN mkdir $HOME/esp
WORKDIR $HOME/esp
RUN git clone -b release/v4.2 --recursive https://github.com/espressif/esp-idf.git

WORKDIR $HOME/esp/esp-idf
RUN ./install.sh esp32

WORKDIR $HOME/esp/esp-idf
RUN . ./export.sh

CMD ["/usr/sbin/sshd","-D"]
