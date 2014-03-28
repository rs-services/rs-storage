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

## Restoring a volume from a backup

## Creating stripe of volumes

## Restoring stripe of volumes from a backup

## Backing up volume(s) & Cleaning up backups

## Scheduling automated backups of volume(s)

## Deleting volume(s) during the termination of the server

# Attributes

# Recipes

## `rs-storage::default`

Simply includes the `rightscale_volume::default` and `rightscale_backup::default` recipes to meet the requirements of
using the resources in these cookbooks.

## `rs-storage::volume`

Creates a new volume from from scratch of from an existing backup based on the value provided in
`rs-storage/restore/lineage` attribute. If this attribute is set, the volume will be restored from a backup matching
this lineage else a new volume will be created from scratch. This recipe will also format the volume using the
filesystem specified in `rs-storage/device/filesystem` and mount the volume on the location specified in
`rs-storage/device/mount_point`.

## `rs-storage::stripe`

## `rs-storage::backup`

## `rs-storage::schedule`

## `rs-storage::decommission`

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
