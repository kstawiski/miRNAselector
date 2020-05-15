FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV CRAN_URL https://cloud.r-project.org/
ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && apt update && apt dist-upgrade -y && apt-get install -y \
    apt-transport-https screen   \
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
    wget && add-apt-repository -y ppa:ubuntu-toolchain-r/test && apt update && apt install -y gfortran-9 && apt install -y build-essential libmagick++-dev libbz2-dev libpcre2-16-0 libpcre2-32-0 libpcre2-8-0 libpcre2-dev fort77 xorg-dev liblzma-dev  libblas-dev gfortran gcc-multilib gobjc++ libreadline-dev && apt install -y texinfo texlive-fonts-extra texlive libcairo2-dev freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev libglfw3-dev libgles2-mesa-dev libopenblas-dev liblapack-dev libopencv-dev build-essential git gcc cmake libcairo2-dev libxml2-dev && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -sc)-cran40/" && apt update && apt -y dist-upgrade && apt install -y r-base-core r-base-dev texlive-full texlive-xetex ttf-mscorefonts-installer r-recommended build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev default-jre default-jdk && Rscript -e "install.packages(c('remotes','devtools'))" && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add - && add-apt-repository -y "deb https://apt.kitware.com/ubuntu/ $(lsb_release -sc) main" && apt update && apt -y dist-upgrade 

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion gfortran-7 gcc-7 python3-pip python3-venv && \
    apt-get clean && \
    wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

COPY vignettes/setup.R /
COPY docker/register_jupyter.R /


RUN Rscript /setup.R && echo 'root:biostat' | chpasswd && conda update --all && conda install -c anaconda jupyter && Rscript /register_jupyter.R && jupyter notebook --generate-config && mkdir /miRNAselector/ && conda install nbconvert && conda install -c conda-forge bash_kernel && conda install -c conda-forge jupyter_contrib_nbextensions && apt-get -y install texlive-xetex texlive-fonts-recommended texlive-latex-recommended pandoc && R CMD javareconf && conda create -y -n tensorflow -c conda-forge -c anaconda tensorflow keras numpy scikit-learn pandas ipykernel && python -m ipykernel install --user --name=tensorflow

COPY docker/jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
COPY docker/logo.png /opt/conda/lib/python3.7/site-packages/notebook/static/base/images/logo.png
COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/update.R /update.R

RUN apt-get install -y --reinstall build-essential apt-utils && chmod +x /entrypoint.sh && add-apt-repository -y ppa:ondrej/php && apt update && apt -y dist-upgrade && conda install -c conda-forge jupytext && apt-get install -y nginx php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap nano

RUN conda clean --packages --tarballs -y && rm -rf /tmp/* && apt-get clean 

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/php.ini /etc/php/7.3/fpm/php.ini
COPY docker/default /etc/nginx/sites-available/default
COPY docker/www.conf /etc/php/7.3/fpm/pool.d/www.conf

EXPOSE 8888
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]