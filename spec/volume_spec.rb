require_relative 'spec_helper'

describe 'rs-storage::volume' do
  context 'rs-storage/restore/lineage is not set' do
    let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
    let(:nickname) { chef_run.node['rs-storage']['device']['nickname'] }

    it 'creates a new volume and attaches it' do
      expect(chef_run).to create_rightscale_volume(nickname).with(
        size: 10,
        options: {},
      )
      expect(chef_run).to attach_rightscale_volume(nickname)
    end

    it 'formats the volume and mounts it' do
      expect(chef_run).to create_filesystem(nickname).with(
        fstype: 'ext4',
        mkfs_options: '-F',
        mount: '/mnt/storage',
      )
      expect(chef_run).to enable_filesystem(nickname)
      expect(chef_run).to mount_filesystem(nickname)
    end

    context 'iops is set to 100' do
      let(:chef_run) do
        ChefSpec::Runner.new do |node|
          node.set['rs-storage']['device']['iops'] = 100
        end.converge(described_recipe)
      end

      it 'creates a new volume with iops set to 100 and attaches it' do
        expect(chef_run).to create_rightscale_volume(nickname).with(
          size: 10,
          options: {iops: 100},
        )
        expect(chef_run).to attach_rightscale_volume(nickname)
      end
    end
  end

  context 'rs-storage/restore/lineage is set' do
    let(:chef_runner) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['restore']['lineage'] = 'testing'
        node.set['rightscale_volume']['data_storage']['device'] = '/dev/sda'
        node.set['rightscale_backup']['data_storage']['devices'] = ['/dev/sda']
      end
    end
    let(:chef_run) do
      chef_runner.converge(described_recipe)
    end
    let(:nickname) { chef_run.node['rs-storage']['device']['nickname'] }
    let(:device) { chef_run.node['rightscale_volume'][nickname]['device'] }

    it 'creates a volume from the backup' do
      expect(chef_run).to restore_rightscale_backup(nickname).with(
        lineage: 'testing',
        timestamp: nil,
        size: 10,
        options: {},
      )
    end

    it 'mounts and enables the restored volume' do
      expect(chef_run).to mount_mount(device).with(
        fstype: 'ext4',
      )
      expect(chef_run).to enable_mount(device)
    end

    context 'iops is set to 100' do
      let(:chef_run) do
        chef_runner.node.set['rs-storage']['device']['iops'] = 100
        chef_runner.converge(described_recipe)
      end

      it 'creates a volume from the backup with iops' do
        expect(chef_run).to restore_rightscale_backup(nickname).with(
          lineage: 'testing',
          timestamp: nil,
          size: 10,
          options: {iops: 100},
        )
      end
    end

    context 'timestamp is set' do
      let(:timestamp) { Time.now }
      let(:chef_run) do
        chef_runner.node.set['rs-storage']['restore']['timestamp'] = timestamp
        chef_runner.converge(described_recipe)
      end

      it 'creates a volume from the backup with the timestamp' do
        expect(chef_run).to restore_rightscale_backup(nickname).with(
          lineage: 'testing',
          timestamp: timestamp,
          size: 10,
          options: {},
        )
      end
    end
  end
end
