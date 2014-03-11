name             'rs-storage'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures rs-storage'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'marker'
depends 'rightscale_volume'
depends 'rightscale_backup'
depends 'filesystem'

recipe 'rs-storage::default', 'Sets up required dependencies for using this cookbook'
recipe 'rs-storage::volume', 'Creates a volume and attaches it to the server'
recipe 'rs-storage::stripe', 'Creates volume stripes and sets up LVM'
recipe 'rs-storage::backup', 'Creates a new backup'
recipe 'rs-storage::decommission', 'Destroys LVM conditionally, detaches and destroys volumes. This recipe should' +
  ' be used as a decommission recipe in a RightScale ServerTemplate.'
recipe 'rs-storage::schedule', 'Enable/disable periodic backups based on rs-storage/schedule/enable'

attribute 'rs-storage/device/restore',
  :display_name => 'Restore Device from a Backup',
  :description => 'If this option is set to true, rs-storage::volume and rs-storage::stripe recipes will restore' +
    ' device(s) from the backup instead of creating new device(s).',
  :default => 'false',
  :choice => ['true', 'false'],
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'optional'

attribute 'rs-storage/device/mount_point',
  :display_name => 'Device Mount Point',
  :description => 'The mount point to mount the device on. Example: /mnt/storage',
  :default => '/mnt/storage',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/device/nickname',
  :display_name => 'Device Nickname',
  :description => 'Nickname for the device. Example: data_storage',
  :default => 'data_storage',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/device/volume_size',
  :display_name => 'Device Volume Size',
  :description => 'Size of the volume to create. Example: 10',
  :default => '10',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/device/iops',
  :display_name => 'Device IOPS',
  :description => 'IO Operations Per Second to use for the device. Currently this value is only used on AWS clouds.' +
    ' Example: 100',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/device/filesystem',
  :display_name => 'Device Filesystem',
  :description => 'The filesystem to be used on the device. Example: ext4',
  :default => 'ext4',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/backup/lineage',
  :display_name => 'Backup Lineage',
  :description => 'The backup lineage. Example: production',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/backup/lineage_override',
  :display_name => 'Backup Lineage Override',
  :description => 'The lineage name to override to restore backups from a different lineage. Example: staging',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/backup/timestamp_override',
  :display_name => 'Backup Timestamp Override',
  :description => 'The timestamp to override to restore from a backup taken on or before the timestamp in the same' +
    ' lineage. Example: 1391473172',
  :recipes => ['rs-storage::volume'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/daily',
  :display_name => 'Backup Keep Daily',
  :description => 'Number of daily backups to keep. Example: 14',
  :default => '14',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/weekly',
  :display_name => 'Backup Keep Weekly',
  :description => 'Number of weekly backups to keep. Example: 6',
  :default => '6',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/monthly',
  :display_name => 'Backup Keep Monthly',
  :description => 'Number of monthly backups to keep. Example: 12',
  :default => '12',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/yearly',
  :display_name => 'Backup Keep Yearly',
  :description => 'Number of yearly backups to keep. Example: 2',
  :default => '2',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/max_snapshots',
  :display_name => 'Backup Keep Max Snapshots',
  :description => 'Number of maximum snapshots to keep. Example: 60',
  :default => '60',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'
