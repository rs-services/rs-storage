#
# Cookbook Name:: rs-storage
# Recipe:: decommission
#
# Copyright (C) 2013 RightScale, Inc.
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

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

if node['rs-storage']['device']['destroy_on_decommission'] == true ||
  node['rs-storage']['device']['destroy_on_decommission'] == 'true'
  nickname = node['rs-storage']['device']['nickname']

  if is_lvm_used?(node['rs-storage']['device']['mount_point'])
    # Remove any characters other than alphanumeric and dashes and replace with dashes
    sanitized_nickname = nickname.downcase.gsub(/[^-a-z0-9]/, '-')

    # Construct the logical volume from the name of the volume group and the name of the logical volume similat to how the
    # lvm cookbook constructs the name during the creation of the logical volume
    logical_volume_device = "/dev/mapper/#{to_dm_name("#{sanitized_nickname}-vg")}-#{to_dm_name("#{sanitized_nickname}-lv")}"

    log "Unmounting #{node['rs-storage']['device']['mount_point']}"
    mount node['rs-storage']['device']['mount_point'] do
      device logical_volume_device
      action [:umount, :disable]
    end

    log "LVM is used on the device(s). Cleaning up the LVM."
    # Clean up the LVM conditionally
    ruby_block 'clean up LVM' do
      block do
        remove_lvm("#{sanitized_nickname}-vg")
      end
    end

    1.upto(node['rs-storage']['device']['stripe_count'].to_i) do |stripe_num|
      rightscale_volume "#{nickname}_#{stripe_num}" do
        action [:detach, :delete]
      end
    end
  else
    log "Unmounting #{node['rs-storage']['device']['mount_point']}"
    mount node['rs-storage']['device']['mount_point'] do
      device lazy { node['rightscale_volume'][nickname]['device'] }
      action [:umount, :disable]
    end

    log 'LVM was not used on the device, simply detaching the deleting the device.'
    rightscale_volume nickname do
      action [:detach, :delete]
    end
  end
else
  log "rs-storage/device/destroy_on_decommission is set to '#{node['rs-storage']['device']['destroy_on_decommission']}'" +
    " skipping..."
end
