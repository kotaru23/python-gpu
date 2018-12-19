FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 as builder
MAINTAINER kotaru23

ENV PYTHON_VERSION 3.6.7

# install library
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar xf Python-${PYTHON_VERSION}.tar.xz && \
    rm Python-${PYTHON_VERSION}.tar.xz
WORKDIR /usr/local/src/Python-${PYTHON_VERSION}
RUN ./configure --with-ensurepip --enable-optimizations --prefix=/usr/local/python && \
    make && \
    make install && \
    rm -rf /usr/local/src/Python-${PYTHON_VERSION}


FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
MAINTAINER kotaru23

COPY --from=builder /usr/local/python /usr/local/

# install library
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

CMD ['python3']
