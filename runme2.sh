#!/bin/bash


# build base and OS-rolls
cd base
# bootstrap base and build os-rolls
./bootstrap.sh 2>&1 | tee /tmp/bootstrap-base-roll.out
# enable os rolls
rocks add roll /tmp/OSROLL/*.iso
rocks enable roll CentOS
rocks enable roll Updates-CentOS-7.9.2009
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# build base roll, needs librocks
yum install -y librocks
make roll 2>&1 | tee /tmp/make-base-roll.out
# enable base roll
rocks add roll base-7.2.0-UCR.x86_64.disk1.iso 
rocks enable roll base
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# upload
scp /tmp/OSROLL/*.iso root@ip85-215-76-79.pbiaas.com:/root
scp base-7.2.0-UCR.x86_64.disk1.iso root@ip85-215-76-79.pbiaas.com:/root
cd ..


# build core roll, bootstrap already done
cd core
make roll 2>&1 | tee /tmp/make-core-roll.out
# enable core roll
rocks add roll core-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll core
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# upload
scp core-7.2.0-UCR.x86_64.disk1.iso root@ip85-215-76-79.pbiaas.com:/root
cd ..


# build kernl roll
cd kernel
./bootstrap.sh 2>&1 | tee /tmp/bootstrap-kernel.out
make roll 2>&1 | tee /tmp/make-kernel-roll.out
rocks add roll kernel-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll kernel
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# upload
scp kernel-7.2.0-UCR.x86_64.disk1.iso root@ip85-215-76-79.pbiaas.com:/root
cd ..


# ganglia roll
cd ganglia
./bootstrap.sh 2>&1 | tee /tmp/bootstrap-ganglia.out
make roll 2>&1 | tee /tmp/make-ganglia-roll.out
rocks add roll ganglia-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll ganglia
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# upload
scp ganglia-7.2.0-UCR.x86_64.disk1.iso root@ip85-215-76-79.pbiaas.com:/root
cd ..


# sge roll
cd sge
./bootstrap.sh 2>&1 | tee /tmp/bootstrap-sge.out
make roll 2>&1 | tee /tmp/make-sge-roll.out
rocks add roll sge-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll sge
pushd /export/rocks/install
rocks create distro
popd
yum clean all
# upload
scp sge-7.2.0-UCR.x86_64.disk1.iso root@ip85-215-76-79.pbiaas.com:/root
cd ..
