#!/bin/bash
# This script is meant to be called by the "install" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.

# License: 3-clause BSD

set -e


# Deactivate the travis-provided virtual environment and setup a
# conda-based environment instead
deactivate

# Use the miniconda installer for faster download / install of conda
# itself
wget http://repo.continuum.io/miniconda/Miniconda-3.9.1-Linux-x86_64.sh \
    -O miniconda.sh
chmod +x miniconda.sh && ./miniconda.sh -b
export PATH=/home/travis/miniconda/bin:$PATH
conda update --yes conda

# Configure the conda environment and put it in the path using the
# provided versions
if [[ "$LATEST" == "true" ]]; then
    conda create -n testenv --yes python=$PYTHON_VERSION pip nose psutil
else
    conda create -n testenv --yes python=$PYTHON_VERSION pip nose \
        psutil=$PSUTIL_VERSION
fi

source activate testenv

if [[ "$COVERAGE" == "true" ]]; then
    pip install coverage coveralls
fi

# Build pyprind in the install.sh script to collapse the verbose
# build output in the travis output when it succeeds.
python --version
python -c "import psutil; print('psutil%s' % psutil.__version__)"
python setup.py build_ext --inplace
