# rs-storage cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/rs-storage.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/rs-storage)

Provides recipes for managing volumes on a Server in a RightScale supported cloud including the creation of single and
multi-stripe volumes, taking backups of the volumes, restoring from the backups, scheduling periodic backups, and
detaching and deleting the volumes when the server is decommissioned.

Github Repository: [https://github.com/rightscale-cookbooks/rs-storage](https://github.com/rightscale-cookbooks/rs-storage)

# Requirements

* Requires Chef 11 or higher
* Requires Ruby 1.9 of higher
* Platform
  * Ubuntu 12.04
  * CentOS 6
* Cookbooks
  * [chef_handler](http://community.opscode.com/cookbooks/chef_handler)
  * [filesystem](http://community.opscode.com/cookbooks/filesystem)
  * [lvm](http://community.opscode.com/cookbooks/lvm)
  * [marker](http://community.opscode.com/cookbooks/marker)
  * [rightscale_volume](http://community.opscode.com/cookbooks/rightscale_volume)
  * [rightscale_backup](http://community.opscode.com/cookbooks/rightscale_backup)

# Usage

## Creating a new volume

To create a new volume, run the `rs-storage::volume` recipe with the following attributes set:

- `rs-storage/device/nickname` - the nickname of the volume
- `rs-storage/device/volume_size` - the size of the volume to create
- `rs-storage/device/filesystem` - the filesystem to use on the volume
- `rs-storage/device/mount_point` - the location to mount the volume

This will create a new volume, attach it to the server, format it with the filesystem specified, and mount it on the
location specified.

### Provisioned IOPS on EC2

To create a volume with the IOPS on EC2, set the following attribute before running `rs-storage::volume` recipe:

- `rs-storage/device/iops` - the value of IOPS to use

## Restoring a volume from a backup

To restore a volume from backup, run the `rs-storage::volume` recipe with the same set of attributes mentioned in the
[previous section](#creating-a-new-volume) along with the following attribute:

- `rs-storage/restore/lineage` - the lineage to restore the backup from.

This will restore the volume from the backup instead of creating a new one. By default, the backup with the latest timestamp will be restored. To restore backup from a specific timestamp, set the following attribute:

- `rs-storage/restore/timestamp` - the timestamp of the backup to restore from

## Creating stripe of volumes

To create a new stripe of volumes, run the `rs-storage::stripe` recipe with the following attributes set:

- `rs-storage/device/nickname` - the nickname to use as prefix for the stripe of volumes
- `rs-storage/device/stripe_count` - number of volumes to create in the stripe
- `rs-storage/device/volume_size` - the total size of the stripe
- `rs-storage/device/filesystem` - the filesystem to use on the volume
- `rs-storage/device/mount_point` - the location to the mount the logical volume of the LVM stripe

This will create the number of volumes specified in `rs-storage/device/stripe_count`. Each volume created will have a nickname of `"#{nickname}-#{stripe_number}"`. A volume group will be created with name `"#{nickname}-vg"` and a logical volume will be created in this volume group with name `"#{nickname}-lv"`. This logical volume will formatted with the filesystem specified and mounted on the location specified.

This recipe can also be used with a stripe count of `1`. This allows creating LVM on a single volume.

## Restoring stripe of volumes from a backup

To restore a stripe of volumes from the backup, run the `rs-storage::stripe` recipe with the same set of attributes mentioned in the [previous section](#creating-stripe-of-volumes) along with the following attribute:

- `rs-storage/restore/lineage` - the lineage to restore the backup from

This will restore the stripe of volumes from the backup matching the lineage. By default, the backup with the latest timestamp will be restored. To restore backup from a specific timestamp, set the following attribute:

- `rs-storage/restore/timestamp` - the timestamp of the backup to restore from

## Backing up volume(s) & Cleaning up backups

## Scheduling automated backups of volume(s)

## Deleting volume(s) during the termination of the server

# Attributes

# Recipes

## `rs-storage::default`

Simply includes the `rightscale_volume::default` and `rightscale_backup::default` recipes to meet the requirements of
using the resources in these cookbooks.

## `rs-storage::volume`

Creates a new volume from scratch or from an existing backup based on the value provided in
`rs-storage/restore/lineage` attribute. If this attribute is set, the volume will be restored from a backup matching
this lineage else a new volume will be created from scratch. This recipe will also format the volume using the
filesystem specified in `rs-storage/device/filesystem` and mount the volume on the location specified in
`rs-storage/device/mount_point`.

## `rs-storage::stripe`

Creates a new stripe of volumes from scratch or from an existing backup based on the value provided in 
`rs-storage/restore/lineage` attribute. If this attribute is set, the volumes will be restored from a backup matching this lineage else a new stripe of volumes will be created from scratch. This recipe will create an LVM stripe on the volumes and formats the logical volume using the filesystem specified in `rs-storage/device/filesystem`. This will also mount the volume on the location specified in `rs-storage/device/mount_point`.

## `rs-storage::backup`

## `rs-storage::schedule`

## `rs-storage::decommission`

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
