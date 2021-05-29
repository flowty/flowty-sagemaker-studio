FROM python:3.7

#####################
# OVERVIEW
# 1. Creates the `sagemaker-user` user with UID/GID 1000/100
# 2. Ensures this user can `sudo` by default and compatible distributions
# 3. Installs flowty, or_datasets etc. using pip
# 4. Configures the kernel
# 5. Make the default shell `bash`. This enhances the experience inside a Jupyter terminal as otherwise Jupyter defaults to `sh`
#####################

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"

# Setup the "sagemaker-user" user with root privileges.
RUN \
    apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    # Prevent apt-get cache from being persisted to this layer.
    rm -rf /var/lib/apt/lists/*

# system library pre-requisites
RUN \
    apt-get update && \
    apt-get install -y \
    libgfortran5 \
    libtbb2 \
    gmodule-2.0 sudo && \
    rm -rf /var/lib/apt/lists/*


# Update Python with the required packages
RUN pip install --upgrade pip
# Install Flowty
RUN pip install flowty
# Install or_datasets
RUN pip install or_datasets
# Install networkx matplotlib
RUN pip install networkx matplotlib
# Install networkx boto3 sagemaker
RUN pip install boto3 sagemaker


# Configure the kernel
RUN pip install ipykernel && \
        python -m ipykernel install --sys-prefix

# Make the default shell bash (vs "sh") for a better Jupyter terminal UX
ENV SHELL=/bin/bash

USER $NB_UID