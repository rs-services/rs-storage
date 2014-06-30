#
# Cookbook Name:: rs-storage
# Recipe:: decommission
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

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

# Check for the safety attribute first
if node['rs-storage']['device']['destroy_on_decommission'] != true &&
  node['rs-storage']['device']['destroy_on_decommission'] != 'true'
  log "rs-storage/device/destroy_on_decommission is set to '#{node['rs-storage']['device']['destroy_on_decommission']}'" +
    " skipping..."
# Check 'rs_run_state' and skip if the instance is rebooting or entering the stop state
elsif ['shutting-down:reboot', 'shutting-down:stop', 'shutting-down:unknown'].include?(get_rs_run_state)
  log 'Skipping deletion of volumes as the instance is either rebooting or entering the stop state...'
# Detach and delete the volumes if the above safety conditions are satisfied
else
  device_nickname = node['rs-storage']['device']['nickname']

  # If LVM is used, we will have one or more devices with the device nickname appended with the device number. Destroy
  # the LVM conditionally and then detach and delete all the volumes.
  if is_lvm_used?(node['rs-storage']['device']['mount_point'])
    # Remove any characters other than alphanumeric and dashes and replace with dashes
    sanitized_nickname = device_nickname.downcase.gsub(/[^-a-z0-9]/, '-')

    # Construct the logical volume from the name of the volume group and the name of the logical volume similar to how the
    # lvm cookbook constructs the name during the creation of the logical volume
    logical_volume_device = "/dev/mapper/#{to_dm_name("#{sanitized_nickname}-vg")}-#{to_dm_name("#{sanitized_nickname}-lv")}"

    log "Unmounting #{node['rs-storage']['device']['mount_point']}"
    # There might still be some open files from the mount. Just ignore failure for now.
    mount node['rs-storage']['device']['mount_point'] do
      device logical_volume_device
      ignore_failure true
      action [:umount, :disable]
    end

    log "LVM is used on the device(s). Cleaning up the LVM."
    # Clean up the LVM conditionally
    ruby_block 'clean up LVM' do
      block do
        remove_lvm("#{sanitized_nickname}-vg")
      end
    end

    # Detach and delete all attached volumes
    1.upto(node['rs-storage']['device']['count'].to_i) do |device_num|
      rightscale_volume "#{device_nickname}_#{device_num}" do
        action [:detach, :delete]
      end
    end
  # If LVM is not used, we only have a single device. In this case, unmount, detach and delete the volume.
  else
    # Unmount the volume
    log "Unmounting #{node['rs-storage']['device']['mount_point']}"
    # Thre might still be some open files from the mount point. Just ignore the failure for now.
    mount node['rs-storage']['device']['mount_point'] do
      device lazy { node['rightscale_volume'][device_nickname]['device'] }
      ignore_failure true
      action [:umount, :disable]
      only_if { node.attribute?('rightscale_volume') && node['rightscale_volume'].attribute?(device_nickname) }
    end

    # Detach and delete the volume
    log 'LVM was not used on the device, simply detaching the deleting the device.'
    rightscale_volume device_nickname do
      action [:detach, :delete]
    end
  end
end
