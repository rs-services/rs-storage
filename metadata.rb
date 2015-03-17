name             'rs-storage'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Provides recipes for managing volumes on a Server in a RightScale supported cloud'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.4'

depends 'chef_handler', '~> 1.1.6'
depends 'filesystem', '~> 0.9.0'
depends 'lvm', '~> 1.1.0'
depends 'marker', '~> 1.0.1'
depends 'rightscale_backup', '~> 1.1.5'
depends 'rightscale_volume', '~> 1.2.4'

recipe 'rs-storage::default', 'Sets up required dependencies for using this cookbook'
recipe 'rs-storage::volume', 'Creates a volume and attaches it to the server'
recipe 'rs-storage::backup', :description => 'Creates a backup', :thread => 'storage_backup'
recipe 'rs-storage::decommission', 'Destroys LVM conditionally, detaches and destroys volumes. This recipe should' +
  ' be used as a decommission recipe in a RightScale ServerTemplate.'
recipe 'rs-storage::schedule', 'Enable/disable periodic backups based on rs-storage/schedule/enable'
recipe 'rs-storage::re-volume', 'Creates a volume and attaches it to the server'

attribute 'rs-storage/device/mount_point',
  :display_name => 'Device Mount Points',
  :description => 'Mount point(s) to mount the device(s) on. Comma separated list will attach that number of volumes.' +
    ' Size of each volume can be assigned with a colon after each mount point otherwise Default Device Volume size is used.' +
    ' Example: /mnt/storage1:10, /mnt/storage2:20, /mnt/storage3:30',
  :default => '/mnt/storage',
  :recipes => ['rs-storage::volume','rs-storage::re-volume', 'rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/device/nickname',
  :display_name => 'Device Nickname',
  :description => 'Nickname for the device. Multiple devices will have incremented number. Example: data_storage',
  :default => 'data_storage',
  :recipes => ['rs-storage::volume','rs-storage::re-volume','rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/device/volume_size',
  :display_name => 'Default Device Volume Size',
  :description => 'Default Size of the volume to create (in GB). Size can also be assigned at Device Mount Points. Example: 10',
  :default => '10',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'recommended'

attribute 'rs-storage/device/iops',
  :display_name => 'Device IOPS',
  :description => 'IO Operations Per Second to use for the device. Currently this value is only used on AWS clouds.' +
    ' Example: 100',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'optional'

attribute 'rs-storage/device/volume_type',
  :display_name => 'Volume Type',
  :description => 'Volume Type to use for creating volumes. Example: gp2',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'optional'

attribute 'rs-storage/device/filesystem',
  :display_name => 'Device Filesystem',
  :description => 'The filesystem to be used on the device. Example: ext4',
  :default => 'ext4',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'optional'

attribute 'rs-storage/device/detach_timeout',
  :display_name => 'Detach Timeout',
  :description => 'Amount of time (in seconds) to wait for a single volume to detach at decommission. Example: 300',
  :default => '300',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'optional'

attribute 'rs-storage/device/destroy_on_decommission',
  :display_name => 'Destroy on Decommission',
  :description => 'If set to true, the devices will be destroyed on decommission.',
  :default => 'false',
  :recipes => ['rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/backup/lineage',
  :display_name => 'Backup Lineage',
  :description => 'The backup lineage. Example: production',
  :recipes => ['rs-storage::backup'],
  :required => 'required'

attribute 'rs-storage/restore/lineage',
  :display_name => 'Restore Lineage',
  :description => 'The lineage name to restore backups. Example: staging',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'recommended'

attribute 'rs-storage/restore/timestamp',
  :display_name => 'Restore Timestamp',
  :description => 'The timestamp (in seconds since UNIX epoch) to select a backup to restore from.' +
    ' The backup selected will have been created on or before this timestamp. Example: 1391473172',
  :recipes => ['rs-storage::volume','rs-storage::re-volume'],
  :required => 'recommended'

attribute 'rs-storage/backup/keep/dailies',
  :display_name => 'Backup Keep Dailies',
  :description => 'Number of daily backups to keep. Example: 14',
  :default => '14',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/weeklies',
  :display_name => 'Backup Keep Weeklies',
  :description => 'Number of weekly backups to keep. Example: 6',
  :default => '6',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/monthlies',
  :display_name => 'Backup Keep Monthlies',
  :description => 'Number of monthly backups to keep. Example: 12',
  :default => '12',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/yearlies',
  :display_name => 'Backup Keep Yearlies',
  :description => 'Number of yearly backups to keep. Example: 2',
  :default => '2',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/backup/keep/keep_last',
  :display_name => 'Backup Keep Last Snapshots',
  :description => 'Number of snapshots to keep. Example: 60',
  :default => '60',
  :recipes => ['rs-storage::backup'],
  :required => 'optional'

attribute 'rs-storage/schedule/enable',
  :display_name => 'Backup Schedule Enable',
  :description => 'Enable or disable periodic backup schedule',
  :default => 'false',
  :choice => ['true', 'false'],
  :recipes => ['rs-storage::schedule'],
  :required => 'recommended'

attribute 'rs-storage/schedule/hour',
  :display_name => 'Backup Schedule Hour',
  :description => "The hour to schedule the backup on. This value should abide by crontab syntax. Use '*' for taking' +
    ' backups every hour. Example: 23",
  :recipes => ['rs-storage::schedule'],
  :required => 'required'

attribute 'rs-storage/schedule/minute',
  :display_name => 'Backup Schedule Minute',
  :description => 'The minute to schedule the backup on. This value should abide by crontab syntax. Example: 30',
  :recipes => ['rs-storage::schedule'],
  :required => 'required'

attribute 'rs-storage/backup/timeout',
  :display_name => 'Backup Timeout',
  :description => 'The time rs-storage::backup will wait to backup. Example: 15',
  :recipes => [ 'rs-storage::backup' ],
  :required => 'optional',
  :default => '15'

attribute 'rs-storage/restore/timeout',
  :display_name => 'Restore Timeout',
  :description => 'The time rs-storage::restore will wait to restore. Example: 15',
  :recipes => [ 'rs-storage::volume','rs-storage::re-volume' ],
  :required => 'optional',
  :default => '15'

attribute 'rs-storage/volume/timeout',
  :display_name => 'Volume Create Timeout',
  :description => 'The time rs-storage::volume will wait to volume. Example: 15',
  :recipes => [ 'rs-storage::volume','rs-storage::re-volume' ],
  :required => 'optional',
  :default => '15'
