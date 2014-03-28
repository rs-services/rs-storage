require_relative 'spec_helper'

describe 'rs-storage::default' do
  let(:chef_run) { ChefSpec::Runner.new(log_level: :error).converge(described_recipe) }

  it 'includes rightscale_volume::default recipe' do
    expect(chef_run).to include_recipe('rightscale_volume::default')
  end

  it 'includes rightscale_backup::default recipe' do
    expect(chef_run).to include_recipe('rightscale_backup::default')
  end
end
