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

RUN apt install -y texinfo texlive-fonts-extra texlive libcairo2-dev freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev libglfw3-dev libgles2-mesa-dev libopenblas-dev liblapack-dev libopencv-dev build-essential git gcc cmake

RUN cd / && git clone --recursive https://github.com/apache/incubator-mxnet.git
RUN cd /incubator-mxnet && mkdir build && cd build && cmake -DUSE_CUDA=OFF -DUSE_MKL_IF_AVAILABLE=ON -DUSE_MKLDNN=OFF -DUSE_OPENMP=ON -DUSE_OPENCV=ON .. && make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas && make install && cp -a . .. && cp -a . ../lib && pwd

RUN cd /incubator-mxnet/build/ && make rpkg

COPY vignettes/setup.R /

RUN Rscript /setup.R
