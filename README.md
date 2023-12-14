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

### Build Sequence

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
