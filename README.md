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

This will restore the volume from the backup instead of creating a new one. By default, the backup with the latest
timestamp will be restored. To restore backup from a specific timestamp, set the following attribute:

- `rs-storage/restore/timestamp` - the timestamp of the backup to restore from

## Creating stripe of volumes

To create a new stripe of volumes, run the `rs-storage::stripe` recipe with the following attributes set:

- `rs-storage/device/nickname` - the nickname to use as prefix for the stripe of volumes
- `rs-storage/device/stripe_count` - number of volumes to create in the stripe
- `rs-storage/device/volume_size` - the total size of the stripe
- `rs-storage/device/filesystem` - the filesystem to use on the volume
- `rs-storage/device/mount_point` - the location to the mount the logical volume of the LVM stripe

This will create the number of volumes specified in `rs-storage/device/stripe_count`. Each volume created will have a
nickname of `"#{nickname}-#{stripe_number}"`. A volume group will be created with name `"#{nickname}-vg"` and a
logical volume will be created in this volume group with name `"#{nickname}-lv"`. This logical volume will formatted
with the filesystem specified and mounted on the location specified.

This recipe can also be used with a stripe count of `1`. This allows creating LVM on a single volume.

## Restoring stripe of volumes from a backup

To restore a stripe of volumes from the backup, run the `rs-storage::stripe` recipe with the same set of attributes
mentioned in the [previous section](#creating-stripe-of-volumes) along with the following attribute:

- `rs-storage/restore/lineage` - the lineage to restore the backup from

This will restore the stripe of volumes from the backup matching the lineage. By default, the backup with the latest
timestamp will be restored. To restore backup from a specific timestamp, set the following attribute:

- `rs-storage/restore/timestamp` - the timestamp of the backup to restore from

## Backing up volume(s) & Cleaning up backups

To create a backup of all volumes attached to the server, run the `rs-storage::backup` recipe with the following
attributes set:

- `rs-storage/backup/lineage` - the lineage to be used for the backup

The backup process will create a snapshot of all volumes attached to the server (except the boot disk if there is one).
The backup recipe also handles the cleanup of old volume snapshots and accepts the following attributes:

- `rs-storage/backup/keep/keep_last` - number of last backups to keep from deleting
- `rs-storage/backup/keep/dailies` - number of daily backups to keep
- `rs-storage/backup/keep/weeklies` - number of weekly backups to keep
- `rs-storage/backup/keep/monthlies` - number of monthly backups to keep
- `rs-storage/backup/keep/yearlies` - number of yearly backups to keep

This will cleanup the old snapshots on the cloud based on the criteria specified.

## Scheduling automated backups of volume(s)

To schedule automated backups, run the `rs-storage::schedule` recipe with the following attributes set:

- `rs-storage/schedule/enable` - to enable/disable automated backups
- `rs-storage/schedule/hour` - the hour to take the backup on
- `rs-storage/schedule/minute` - the minute to take the backup on
- `rs-storage/backup/lineage` - the lineage name to be used for the backup

This will create a crontab entry to run the `rs-storage::backup` recipe periodically at the given minute and hour. To
disable the automated backups, simply set `rs-storage/schedule/enable` to `false` and rerun the `rs-storage::schedule`
recipe and this will remove the crontab entry.

## Deleting volume(s)

This operation will be part of the decomission bundle in a RightScale ServerTemplate where the volumes attached to
the server are detached and deleted from the cloud but this can also be used as an operational recipe. This recipe will
do nothing in the following conditions:

- when the server enters a stop state
- when server reboots

This recipe also has a safety attribute `rs-storage/device/destroy_on_decommission`. This attribute will be set to
`true` by default and should be overridden and set to `true` in order for the devices to be detached and deleted. If an
LVM is found (with multiple stripe using `rs-storage::stripe`), the LVM will be conditionally removed before detaching
the volume.

# Attributes

- `rs-storage/device/nickname` - The nickname for the device or stripe of devices. Default is `'data_storage'`.
- `rs-storage/device/mount_point` - The moint point for the device. Default is `'/mnt/storage'`.
- `rs-storage/device/volume_size` - The size of volume to be created. If stripe of devices is used, this will be the
  total size of the stripe. Default is `10`.
- `rs-storage/device/stripe_count` - The number of stripes to be created. Default is `1`.
- `rs-storage/device/iops` - The IOPS value to be used for EC2 Provisioned IOPS. This attribute should only be used
  with Amazon EC2. Default is `nil`.
- `rs-storage/device/filesystem` - The filesystem to be used on the device. Default is `'ext4'`.
- `rs-storage/device/destroy_on_decommission` - Whether to destroy the device during the decommission of the server.
  Default is `false`.
- `rs-storage/device/mkfs_options` - Additional mkfs options for formatting the device. Default is `'-F'`. This is
  required to avoid warnings about formatting the whole device when LVM is not used.
- `rs-storage/device/stripe_size` - The stripe size to use on LVM. Default is `512`.
- `rs-storage/backup/lineage` - The backup lineage. Default is `nil`.
- `rs-storage/backup/keep/keep_last` - Maximum snapshots to keep. Default is `60`.
- `rs-storage/backup/keep/dailies` - Number of daily backups to keep. Default is `14`.
- `rs-storage/backup/keep/weeklies` - Number of weekly backups to keep. Default is `6`.
- `rs-storage/backup/keep/monthlies` - Number of monthly backups to keep. Default is `12`.
- `rs-storage/backup/keep/yearlies` - Number of yearly backups to keep. Default is `2`.
- `rs-storage/restore/lineage` - The name of the lineage to restore the backups from. Default is `nil`.
- `rs-storage/restore/timestamp` - The timestamp to restore backup taken on or before the timestamp in the same
  lineage. Default is `nil`.
- `rs-storage/schedule/enable` - Enable/disable automated backups. Default is `false`.
- `rs-storage/schedule/hour` - The backup schedule hour. Default is `nil`.
- `rs-storage/schedule/minute` - The backup schedule minute. Default is `nil`.


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
`rs-storage/restore/lineage` attribute. If this attribute is set, the volumes will be restored from a backup matching
this lineage else a new stripe of volumes will be created from scratch. This recipe will create an LVM stripe on the
volumes and formats the logical volume using the filesystem specified in `rs-storage/device/filesystem`. This will
also mount the volume on the location specified in `rs-storage/device/mount_point`.

## `rs-storage::backup`

Takes a backup of all volumes attached to the server (except boot disks if there were any) with the lineage specified
in the `rs-storage/backup/lineage` attribute. During the backup process, the filesystem will be frozen. The filesystem
will be unfrozen even if the backup process fails with the help of a chef exception handler. This recipe will also
cleanup the volume snapshots based on the criteria specified in the `rs-storage/backup/keep/*` attributes.

## `rs-storage::schedule`

Adds/removes the crontab entry for taking backups periodically at the minute and hour provided via
`rs-storage/schedule/minute` and `rs-storage/schedule/hour` attributes.

## `rs-storage::decommission`

This recipe detaches and deletes the volumes attached to the server if the `rs-storage/device/destroy_on_decommission`
attribute is set to true. This operation will be skipped if the server is entering the stop state or rebooting.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
