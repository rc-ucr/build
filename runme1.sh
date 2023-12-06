#!/bin/bash

# download stuff
cd /root
git clone git@github.com:rc-ucr/core.git
git clone git@github.com:rc-ucr/base.git
git clone git@github.com:rc-ucr/kernel.git
git clone git@github.com:rc-ucr/ganglia.git
git clone git@github.com:rc-ucr/sge.git

# bootstrap0 for rpm-devel
cd core
./bootstrap0.sh < /dev/null 2>&1 | tee /tmp/bootstrap0-core.out
./bootstrap.sh 2>&1 | tee /tmp/bootstrap-core.out
cd ..

echo
echo "Reopen terminal and continue with runme2.sh."
echo

