#
#
# Cookbook Name:: rs-storage
# Recipe:: stripe
#
# Copyright (C) 2014 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

stripe_count = node['rs-storage']['device']['stripe_count'].to_i
nickname = node['rs-storage']['device']['nickname']
size = node['rs-storage']['device']['volume_size'].to_i

raise 'rs-storage/device/stripe_count should be at least 1' if stripe_count < 1

stripe_device_size = (size.to_f / stripe_count.to_f).ceil

Chef::Log.info "Total size is: #{size}"
Chef::Log.info "Stripe count is set to: #{stripe_count}"
Chef::Log.info "Each device in the stripe will created of size: #{stripe_device_size}"

device_nicknames = []

include_recipe 'lvm::default'

# rs-storage/restore/lineage is empty, creating new volume(s) and setting up LVM
if node['rs-storage']['restore']['lineage'].to_s.empty?
  1.upto(stripe_count) do |stripe_num|
    device_nicknames << "#{nickname}_#{stripe_num}"
    rightscale_volume "#{nickname}_#{stripe_num}" do
      size stripe_device_size
      action [:create, :attach]
    end
  end
# rs-storage/restore/lineage is set, restore from the backup
else
  rightscale_backup nickname do
    size stripe_device_size
    lineage node['rs-storage']['restore']['lineage']
    timestamp node['rs-storage']['restore']['timestamp'] if node['rs-storage']['restore']['timestamp']
    action :restore
  end
end

# Remove any characters other than alphanumeric and dashes and replace with dashes
sanitized_nickname = nickname.downcase.gsub(/[^-a-z0-9]/, '-')

lvm_volume_group "#{sanitized_nickname}-vg" do
  physical_volumes lazy { device_nicknames.map { |nickname| node['rightscale_volume'][nickname]['device'] } }

  logical_volume "#{sanitized_nickname}-lv" do
    size '100%VG'
    filesystem node['rs-storage']['device']['filesystem']
    mount_point node['rs-storage']['device']['mount_point']
    if stripe_count > 1
      stripes stripe_count
      stripe_size node['rs-storage']['device']['stripe_size']
    end
  end
end

