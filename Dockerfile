FROM ubuntu:16.04 as download-python

ENV PYTHON_VERSION 3.6.7

# install library
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    build-essential \
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
    tar xf Python-${PYTHON_VERSION}.tar.xz
WORKDIR /usr/local/src/Python-${PYTHON_VERSION}
RUN ./configure --with-ensurepip --enable-optimizations && \
    make


FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
MAINTAINER geotaru

ENV PYTHON_VERSION 3.6.7
ENV DEBIAN_FRONTEND=noninteractive

# install library
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    graphviz \
    gfortran \
    libopenblas-dev \
    liblapack-dev  && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


COPY --from=download-python /usr/local/src/Python-${PYTHON_VERSION} /opt/python
WORKDIR /opt/python
RUN make install && \
    rm -rf /opt/python

# 欲しいライブラリをインストール
RUN pip3 --no-cache-dir install --upgrade pip && \
    pip3 --no-cache-dir install \
        numpy \
        scipy \
        pandas \
        h5py \
        joblib \
        cupy \
        scikit-learn \
        imbalanced-learn \
        nose \
        xgboost \
        tensorflow-gpu \
        keras \
        seaborn \
        matplotlib \
        plotly \
        jupyter \ 
        yapf \
        tqdm \
        cython \
        jupyter_contrib_nbextensions \
        bayesian-optimization \
        pydot \
        graphviz \
        pydot3 \
        pydot-ng \
        pillow \
        folium \
        autopep8 \
        line_profiler \
        memory_profiler \
        rise

# Jupyter NotebookのExtensionの設定
RUN jupyter contrib nbextension install --user && \
    : "Jupyter NotebookのキーバインドをVim風に設定" && \
    mkdir -p $(jupyter --data-dir)/nbextensions && \
    cd $(jupyter --data-dir)/nbextensions && \
    git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding &&  \
    jupyter nbextension enable vim_binding/vim_binding && \
    : "Jupyter Notebookでプレゼンをするためのライブラリ" && \
    jupyter-nbextension install rise --py --sys-prefix && \
    jupyter-nbextension enable rise --py --sys-prefix && \
    : "セルごとに実行時間を測定" && \
    jupyter-nbextension enable execute_time/ExecuteTime  && \
    jupyter nbextension enable move_selected_cells/main && \
    jupyter nbextension enable toggle_all_line_numbers/main && \
    jupyter nbextension enable code_prettify/code_prettify && \
    jupyter nbextension enable scratchpad/main

WORKDIR /notebooks
EXPOSE 8888
ENTRYPOINT ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
