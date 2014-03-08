require_relative 'spec_helper.rb'

describe 'rs-storage::volume' do
  context 'rs-storage/device/restore is false' do
    let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
    let(:nickname) { chef_run.node['rs-storage']['device']['nickname'] }

    it 'creates a new volume and attaches it' do
      expect(chef_run).to create_rightscale_volume(nickname)
      expect(chef_run).to attach_rightscale_volume(nickname)
    end

    it 'formats the volume and mounts it' do
      expect(chef_run).to create_filesystem(nickname)
      expect(chef_run).to enable_filesystem(nickname)
      expect(chef_run).to mount_filesystem(nickname)
    end
  end

  context 'rs-storage/device/restore is true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['device']['restore'] = true
        node.set['rs-storage']['backup']['lineage'] = 'mydb'
        node.set['rightscale_volume']['data_storage']['device'] = '/dev/sda'
      end.converge(described_recipe)
    end
    let(:nickname) { chef_run.node['rs-storage']['device']['nickname'] }
    let(:device) { chef_run.node['rightscale_volume'][nickname]['device'] }


    it 'creates a volume from the backup' do
      expect(chef_run).to restore_rightscale_backup(nickname)
    end

    it 'mounts and enables the restored volume' do
      expect(chef_run).to mount_mount(device)
      expect(chef_run).to enable_mount(device)
    end
  end
end
