# Building RC-UCR

Some remarks on how to build RC-UCR. Very brief and work-in-progress.

## Release 7-2-0-UCR

This is the current release based on CentOS 7.9.2009 und available updates. It uses Linux kernel `3.10.0-1160.105.1.el7.x86_64`.

### Prepare Build Host

Use net install image `CentOS-7-x86_64-NetInstall-2009.iso` and choose a mirror near to you. In my case  I've chosen `https://mirror1.hs-esslingen.de/Mirrors/centos/7.9.2009/os/x86_64/`. Use "*Base Environment: Development and Creative Workstation*" and select the following "A*dd-Ons for Selected Environment*":

- Additional Development
- Development Tools
- Emacs
- Platform Development
- System Administration Tools

This is my personal choice. You may add more, but if you add less then some of the build prerequisites may be missing and the build might fail. In any case, every RC-UCR build is significantly invasive to your build environment. Lots of RPMs will be installed and weird stuff is being executed. I recommend to use a virtualized build host (e.g. on VMware) and to create a snapshot after complete preparation of the build host.

### Automated Build Sequence

This recipe largely follows the original [README](https://github.com/rc-ucr/rocks/blob/master/README) with some simplifications for building on pristine CentOS hosts. The resulting build inherits the Linux kernel version from the build host. Therefore, the newer the build host OS, the newer the RC-UCR kernel version. Log into the build host as `root`, clone the master repository and execute some shell commands:

```bash
cd /root
git clone https://github.com/rc-ucr/rocks.git && cd rocks
```

Download the source tree of currently available rolls:

```bash
./init.sh  --release 7.2.0-UCR-maintenance
```

`7.2.0-UCR-maintenance` is the maintenance branch for Release 7-2-0-UCR. This release corresponds to CentOS 7.9.2009. Roll repositories are cloned into subdirectory  `src/roll`. Now bootstrap the core roll with:

```bash
pushd src/roll/core
./bootstrap0.sh < /dev/null 2>&1 | tee /tmp/bootstrap0.sh.out
popd
```

Log out. Log back in, to make sure that newly installed `/etc/profile` scripts have been sourced. Closing and reopening the terminal is also sufficient. Kick of the build process with:

```bash
./builder.sh < /dev/null 2>&1 | tee /tmp/builder.sh.out
```

Comprehensive log files will be created in `/tmp` which are all worth an inspection. If the build fails for whatever reason, have a look into these files.

```bash
[root@buildhost tmp]# ll *.out
-rw-r--r-- 1 root root 10107682 Dec  7 21:22 bootstrap0.sh.out
-rw-r--r-- 1 root root     3106 Dec  8 00:53 build-base.out
-rw-r--r-- 1 root root     2420 Dec  7 22:15 build-core.out
-rw-r--r-- 1 root root   156323 Dec  8 01:41 builder.sh.out
-rw-r--r-- 1 root root     1119 Dec  8 01:40 build-kernel.out
-rw-r--r-- 1 root root    77986 Dec  7 22:15 clean-base.out
-rw-r--r-- 1 root root    48496 Dec  7 21:39 clean-core.out
-rw-r--r-- 1 root root    32563 Dec  8 00:53 clean-kernel.out
-rw-r--r-- 1 root root  5234046 Dec  8 00:47 make-base-bootstrap.out
-rw-r--r-- 1 root root   966252 Dec  8 00:53 make-base-roll.out
-rw-r--r-- 1 root root   688474 Dec  7 21:42 make-core-bootstrap.out
-rw-r--r-- 1 root root 10997622 Dec  7 22:15 make-core-roll.out
-rw-r--r-- 1 root root   123881 Dec  8 06:49 make-ganglia-bootstrap.out
-rw-r--r-- 1 root root   418894 Dec  8 06:51 make-ganglia-roll.out
-rw-r--r-- 1 root root  1005911 Dec  8 01:06 make-kernel-bootstrap.out
-rw-r--r-- 1 root root 10202844 Dec  8 01:40 make-kernel-roll.out
-rw-r--r-- 1 root root    26560 Dec  8 06:54 make-sge-bootstrap.out
-rw-r--r-- 1 root root   945870 Dec  8 06:58 make-sge-roll.out
[root@buildhost tmp]#
```

Currently only the following rolls are supported: `core`, `base`, `kernel`, `ganglia` and `sge`. More may follow soon. After completion of the build the resulting iso-images can be found in their respective directories within `/root/rocks/src/roll`. Notice that both os rolls `CentOS` and `Updates-CentOS-7.9.2009` are located in `/tmp/OSROLL`. The additional roll `rocks-installer-7-2.iso` in the `kernel` subdirectory is of no use in this context.

### Manual Build Sequence

This build sequence is essentially the same as the automated sequence but gives more control over each single build step. The following commands create the build environment and also set up a little fake cluster head node, including the MySQL database.

```bash
cd /root
git clone https://github.com/rc-ucr/rocks.git && cd rocks
./init.sh  --release 7.2.0-UCR-maintenance
pushd src/roll/core
./bootstrap0.sh < /dev/null 2>&1 | tee /tmp/bootstrap0.sh.out
popd
```

Log out. Log back in, to make sure that newly installed `/etc/profile` scripts have been sourced. Closing and reopening the terminal is also sufficient. The next step creates and installs the `rocks-level` package.

```bash
/usr/sbin/setenforce 0
pushd src/roll/rocksbuild
make buildrpms 
popd
. /etc/profile.d/rocks-devel.sh
```

In the following steps the rolls `core`, `base`, and `kernel` are build, exactly in this order. Change to directory `/root/rocks/src/roll` and execute the following commands.

```bash
cd core
./bootstrap.sh 2>&1 | tee /tmp/make-core-bootstrap.out
make roll 2>&1 | tee /tmp/make-core-roll.out
rocks add roll core-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll core
cd ..
```

You may inspect via `rocks list roll` that the core roll is available and enabled. The next roll to be build is  `base`, which is somewhat special because it also creates the `CentOS-7.9.2009` and `Updates-CentOS-7.9.2009` rolls in `/tmp` directory.

```bash
cd base
./bootstrap.sh 2>&1 | tee /tmp/make-base-bootstrap.out
rocks add roll /tmp/OSROLL/CentOS-7.9.2009-*.iso
rocks add roll /tmp/OSROLL/Updates-CentOS-7.9.2009-*.iso
rocks enable roll CentOS Updates-CentOS-7.9.2009
```

Contintue with creating the base roll.

```bash
make roll 2>&1 | tee /tmp/make-base-roll.out
rocks add roll base-7.2.0-UCR.x86_64.disk1.iso 
rocks enable roll base
cd ..
```

The third essential roll is `kernel`.

```bash
cd kernel
./bootstrap.sh 2>&1 | tee /tmp/make-kernel-bootstrap.out
make roll 2>&1 | tee /tmp/make-kernel-roll.out
rocks add roll kernel-7.2.0-UCR.x86_64.disk1.iso
rocks enable roll kernel
```

After this step the essential rolls are completed and its time to create a first Rocks distribution.

```bash
pushd /export/rocks/install
rocks create distro
popd
source /etc/profile.d/rocks-binaries.sh
source /etc/profile.d/java.sh
source /etc/profile.d/modules.sh
```

Continue with all other optional rolls (currently `ganglia` and `sge`). The sequence is essentially the same for each roll. Replace `<rollname>` in the following command sequence with `ganglia` and `sge`, in a roll by roll manner.

```bash
cd <rollname>
./bootstrap.sh 2>&1 | tee /tmp/make-<rollname>-bootstrap.out
make roll 2>&1 | tee /tmp/make-<rollname>-roll.out
rocks add roll <rollname>-*.iso
rocks enable roll <rollname>
cd ..
```

After this step all roll iso files are built and ready for upload to a roll server.

### Create Roll Server

Set up a roll server following the instruction given at https://github.com/rocksclusters/roll-server. If not already done, setup up an Apache web server (here on CentOS 7) as described in https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-7:

```
yum update httpd
yum install httpd
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
systemctl start httpd
systemctl enable httpd.service
```
