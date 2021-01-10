FROM rootproject/root:latest

RUN apt update
RUN apt -y install python3-pip root
RUN python3 -m pip install --upgrade pip setuptools wheel

# After October 2020 errors can happen when installing or updating packages. Pip will change the way that it resolves dependency conflicts.
# recommend use --use-feature=2020-resolver to test your packages with the new resolver before it becomes the default.

RUN python3 -m pip --use-feature=2020-resolver install jupyter scipy uproot root-numpy matplotlib recordtype lmfit pandas jupyterhub
RUN python3 -m pip --use-feature=2020-resolver install numericalunits numba lz4 cython mpmath sympy astropy keras sklearn tables

RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    locales \
    python3-dev \
    python3-pip \
    python3-pycurl \
    && apt-get clean

RUN mkdir /etc/jupyterhub && jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py

# Install dependencies to run notebooks
RUN pip install --upgrade pip
RUN pip install jupyter \
                metakernel \
                zmq \
		numpy \
		matplotlib

# Create a user that does not have root privileges
ARG username=physicist
RUN userdel builder && useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

# Copy repository in user home
COPY . ${HOME}
RUN chown -R ${username} ${HOME}

# Switch to normal user
USER ${username}
WORKDIR ${HOME}

# Set ROOT environment
#ENV ROOTSYS         "/opt/root"
#ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
#ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
#ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

# Customize the local environement
RUN mkdir -p                                 $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN mkdir -p                                 $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static
