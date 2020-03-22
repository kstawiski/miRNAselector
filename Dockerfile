FROM rocker/r-devel

RUN apt update
RUN apt dist-upgrade -y

RUN apt-get install -y \
    apt-transport-https \
    build-essential libxml2-dev \
    ca-certificates \
    cmake \
    curl \
    git \
    libatlas-base-dev \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    liblapack-dev \
    libopenblas-dev \
    libopencv-dev \
    libzmq3-dev \
    ninja-build \
    software-properties-common \
    sudo \
    unzip \
    virtualenv \
    wget

RUN apt install -y build-essential libbz2-dev libpcre2-16-0 libpcre2-32-0 libpcre2-8-0 libpcre2-dev libpcre2-posix2 fort77 xorg-dev liblzma-dev  libblas-dev gfortran gcc-multilib gobjc++ libreadline-dev

RUN apt install -y texinfo texlive-fonts-extra texlive libcairo2-dev freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev libglfw3-dev libgles2-mesa-dev libopenblas-dev liblapack-dev libopencv-dev build-essential git gcc cmake r-base-dev r-cran-devtools libcairo2-dev libxml2-dev

RUN cd / && git clone --recursive https://github.com/apache/incubator-mxnet.git
RUN cd /incubator-mxnet && mkdir build && cd build && cmake -DUSE_CUDA=OFF -DUSE_MKL_IF_AVAILABLE=ON -DUSE_MKLDNN=OFF -DUSE_OPENMP=ON -DUSE_OPENCV=ON .. && make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas && make install && cp -a . .. && cp -a . ../lib && pwd

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion gfortran-7 gcc-7 && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

COPY vignettes/setup.R /

RUN Rscript /setup.R

RUN cd /incubator-mxnet/ && make -f R-package/Makefile rpkg

RUN echo 'root:biostat' | chpasswd

RUN conda update --all

RUN conda install -c anaconda jupyter

COPY docker/register_jupyter.R /

RUN Rscript /register_jupyter.R

EXPOSE 8888

RUN whereis jupyter

RUN jupyter notebook --generate-config

COPY docker/jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

RUN mkdir /root/miRNAselector/

RUN conda install nbconvert

RUN apt-get install texlive-xetex texlive-fonts-recommended texlive-generic-recommended pandoc

COPY docker/logo.png /opt/conda/lib/python3.7/site-packages/notebook/static/base/images/logo.png

COPY docker/entrypoint.sh /entrypoint.sh

COPY docker/update.R /update.R

RUN chmod +x /entrypoint.sh

RUN conda install -c conda-forge jupytext

RUN apt-get install -y nginx php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap nano

COPY docker/nginx.conf /etc/nginx/nginx.conf

COPY docker/php.ini /etc/php/7.3/fpm/php.ini

COPY docker/default /etc/nginx/sites-available/default

COPY docker/www.conf /etc/php/7.3/fpm/pool.d/www.conf

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]