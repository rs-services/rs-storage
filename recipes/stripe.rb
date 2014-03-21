#
# Cookbook Name:: rs-storage
# Recipe:: stripe
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

stripe_count = node['rs-storage']['device']['stripe_count'].to_i
nickname = node['rs-storage']['device']['nickname']
size = node['rs-storage']['device']['size']

raise 'rs-storage/device/stripe_count should be 1 or more.' if stripe_count < 1

stripe_device_size = (size.to_f / stripe_count.to_f).ceil
device_nicknames = []

if node['rs-storage']['restore']['lineage'].to_s.empty?
  stripe_count.times do |stripe_num|
    device_nicknames << "#{nickname}_#{stripe_num}"
    rightscale_volume "#{nickname}_#{stripe_num}" do
      size stripe_device_size
      action [:create, :attach]
    end
  end

  # TODO: sanitize the nickname before using them for naming volume groups and logical volumes

  lvm_volume_group "#{nickname}-vg" do
    physical_volumes lazy do
      device_nicknames.map { |nickname| node['rightscale_volume'][nickname]['device'] }
    end

    logical_volume "#{nickname}-lv" do
      size '100%VG'
      filesystem node['rs-storage']['device']['filesystem']
      mount_point node['rs-storage']['device']['mount_point']
      if stripe_count > 1
        stripes stripe_count
        stripe_size 512
      end
    end
  end
else
  #TODO: Restore
end
