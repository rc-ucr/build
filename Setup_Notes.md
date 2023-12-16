# Setup Notes

Cluster setup notes and useful snippets.

Last updated: 2023-12-16

## Install Aftermath

Common tasks and little tweaks directly after cluster install.

### SGE and Ganglia Daemons

For whatever reason SGE and Ganglia are not activated after first reboot during cluster install. Replace `<hostname>` with the actual frontend name in the following commands to fix this:

```bash
systemctl restart sgemaster.<hostname>.service
systemctl status sgemaster.<hostname>.service
systemctl restart gmetad.service
systemctl status gmetad.service
```

Now you should be able to access the cluster's Ganglia homepage locally via `http://<hostname>/ganglia`. Note that firewall rules are not yet set up. Don't expect the website to come up if you try to access it remotely.

### Ganglia GUI

SGE has a graphical user interface called `qmon`, which lacks some rerequisites on the frontend node. Installing some additional packages will fix this.

```bash
yum -y install xorg-x11-*
```

### Add Users

```bash
useradd -g users -c "John Doe" john.doe
passwd john.doe
rocks sync users
```

### Preparations before Compute Node Deployment 

The default compute node disk partitioning is somewhat weird. In addition, once partitioned it is [tricky to remove](http://central-7-0-x86-64.rocksclusters.org/roll-documentation/base/7.0/customization-partitioning.html) an existing partition scheme from an existing compute node. Therefore, it is recommended to adjust the desired node disk partitioning, before the first compute node is deployed. 

```bash
pushd /export/rocks/install/site-profiles/7.2.0/nodes
cp skeleton.xml replace-partition.xml
```

Add to `<pre> </pre>` section:

```xml
        <!-- assuming /dev/sda harddrive here 
        Create 16 GB for swap, remainder of 
        harddrive for /. No extra space for
        /tmp, as a compute-node is a disposable
        device.-->
echo "clearpart --all --initlabel --drives=sda
part swap --size 16384 --ondisk sda
part / --size 1 --grow --ondisk sda" &gt; /tmp/user_partition_info
```

**Note:** you should know in advance, how the naming scheme of hard drives in your compute nodes is. Create distribution with:

```bash
popd
pushd /export/rocks/install
rocks create distro
popd
yum clean all
```

## Compute Node Deployment and Re-Install

Set the BIOS boot order of compute nodes to:

1. PXE network boot
2. Hard disk

Follow the instruction in http://central-7-0-x86-64.rocksclusters.org/roll-documentation/base/7.0/install-compute-nodes.html for deployment of compute nodes.

## Common Administrative Tasks

An unsorted collection.

### Missing cluster-kickstart-pxe

SInce Rocks 7.0 `/boot/kickstart/cluster-kickstart-pxe` no longer exists. Therefore something like...

```
tentakel -g compute /boot/kickstart/cluster-kickstart-pxe
```

... in order to kickstart all compute-nodes in one step is no longer possible. Use the following commands instead:

```
rocks set host boot compute action=install
rocks run host compute reboot
```

**Notice:** This procedure only works if boot sequence on compute-node shows `PXE` at first place.

Source: https://lists.sdsc.edu/pipermail/npaci-rocks-discussion/2018-September/072183.html

### NVIDIA Kernel Module via DKMS

This topic is covered elsewhere: https://github.com/KritzelKratzel/rocksclusters-recipes/blob/master/general/README.md
