require_relative 'spec_helper.rb'

describe 'rs-storage::schedule' do
  context 'rs-storage/backup/schedule/enable is true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['backup']['schedule']['enable'] = true
        node.set['rs-storage']['backup']['lineage'] = 'mydb'
        node.set['rs-storage']['backup']['schedule']['hour'] = '10'
        node.set['rs-storage']['backup']['schedule']['minute'] = '30'
      end.converge(described_recipe)
    end
    let(:lineage) { chef_run.node['rs-storage']['backup']['lineage'] }

    it 'creates a crontab entry' do
      expect(chef_run).to create_cron("backup_schedule_#{lineage}").with(
        minute: chef_run.node['rs-storage']['backup']['schedule']['minute'],
        hour: chef_run.node['rs-storage']['backup']['schedule']['hour'],
        command: "rs_run_recipe --policy 'rs-storage::backup' --name 'rs-storage::backup'"
      )
    end
  end

  context 'rs-storage/backup/schedule/enable is false' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['backup']['schedule']['enable'] = false
        node.set['rs-storage']['backup']['lineage'] = 'mydb'
        node.set['rs-storage']['backup']['schedule']['hour'] = '10'
        node.set['rs-storage']['backup']['schedule']['minute'] = '30'
      end.converge(described_recipe)
    end
    let(:lineage) { chef_run.node['rs-storage']['backup']['lineage'] }

    it 'deletess a crontab entry' do
      expect(chef_run).to delete_cron("backup_schedule_#{lineage}")
    end
  end

  context 'rs-storage/backup/schedule/hour or rs-storage/backup/schedule/minute missing' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['backup']['lineage'] = 'mydb'
        node.set['rs-storage']['backup']['schedule']['hour'] = '10'
      end.converge(described_recipe)
    end
    let(:lineage) { chef_run.node['rs-storage']['backup']['lineage'] }

    it 'raises an error' do
      expect { chef_run }.to raise_error(
        RuntimeError,
        'rs-storage/backup/schedule/hour and rs-storage/backup/schedule/minute inputs should be set'
      )
    end
  end
end
