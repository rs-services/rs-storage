name             'rs-storage'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures rs-storage'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'chef_handler'
depends 'filesystem'
depends 'lvm', '~> 1.0.8'
depends 'marker'
depends 'rightscale_backup'
depends 'rightscale_volume'

recipe 'rs-storage::default', 'Sets up required dependencies for using this cookbook'
recipe 'rs-storage::volume', 'Creates a volume and attaches it to the server'
recipe 'rs-storage::stripe', 'Creates volumes, attaches them to the server, and sets up LVM stripe'
recipe 'rs-storage::backup', 'Creates a backup'
recipe 'rs-storage::decommission', 'Destroys LVM conditionally, detaches and destroys volumes. This recipe should' +
  ' be used as a decommission recipe in a RightScale ServerTemplate.'
recipe 'rs-storage::schedule', 'Enable/disable periodic backups based on rs-storage/schedule/enable'

attribute 'rs-storage/device/stripe_count',
  :display_name => 'Device Stripe Count',
  :description => 'The number of device stripes to create. If this value is set to more than 1, it will create the' +
    ' specified number of devices and create an LVM on the devices.',
  :default => '2',
  :recipes => ['rs-storage::stripe', 'rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/device/mount_point',
  :display_name => 'Device Mount Point',
  :description => 'The mount point to mount the device on. Example: /mnt/storage',
  :default => '/mnt/storage',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe', 'rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/device/nickname',
  :display_name => 'Device Nickname',
  :description => 'Nickname for the device. Example: data_storage',
  :default => 'data_storage',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe', 'rs-storage::decommission'],
  :required => 'recommended'

attribute 'rs-storage/device/volume_size',
  :display_name => 'Device Volume Size',
  :description => 'Size of the volume or logical volume to create. Example: 10',
  :default => '10',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'recommended'

attribute 'rs-storage/device/iops',
  :display_name => 'Device IOPS',
  :description => 'IO Operations Per Second to use for the device. Currently this value is only used on AWS clouds.' +
    ' Example: 100',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'optional'

attribute 'rs-storage/device/filesystem',
  :display_name => 'Device Filesystem',
  :description => 'The filesystem to be used on the device. Example: ext4',
  :default => 'ext4',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'optional'

attribute 'rs-storage/device/detach_timeout',
  :display_name => 'Detach Timeout',
  :description => 'Amount of time (in seconds) to wait for a volume to detach at decommission. Example: 300',
  :default => '300',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
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
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'recommended'

attribute 'rs-storage/restore/timestamp',
  :display_name => 'Restore Timestamp',
  :description => 'The timestamp to restore from a backup taken on or before the timestamp in the same lineage.' +
    ' Example: 1391473172',
  :recipes => ['rs-storage::volume', 'rs-storage::stripe'],
  :required => 'recommended'

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
  :description => "The hour to schedule the backup on. Use '*' for taking backups every hour. This value should' +
    ' abide by crontab crontab syntax. Example: 23",
  :recipes => ['rs-storage::schedule'],
  :required => 'required'

attribute 'rs-storage/schedule/minute',
  :display_name => 'Backup Schedule Minute',
  :description => 'The minute to schedule the backup on. This value should abide by crontab syntax. Example: 30',
  :recipes => ['rs-storage::schedule'],
  :required => 'required'
