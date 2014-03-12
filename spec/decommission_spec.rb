require_relative 'spec_helper.rb'

describe 'rs-storage::decommission' do
  context 'rs-storage/device/stripe_count is set to 1' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['rs-storage']['device']['stripe_count'] = 1
      end.converge(described_recipe)
    end
    let(:nickname) { chef_run.node['rs-storage']['device']['nickname'] }

    it 'detaches the volume from the instance' do
      expect(chef_run).to detach_rightscale_volume(nickname)
    end

    it 'deletes the volume from the cloud' do
      expect(chef_run).to delete_rightscale_volume(nickname)
    end
  end

  # TODO: Add tests for multiple stripes case
end
