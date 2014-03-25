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

nickname = node['rs-storage']['device']['nickname']

#lvm_used = nil # TODO: Detect by inspecting the system

#if is_lvm_used?(node['rs-storage']['device']['mount_point'])
# TODO: Destroy LVM conditionally
# 1. Unmount the logical volume
# 2. Remove the logical volume
# 3. Remove the volume group
# 4. Remove the phyisical volume(s)
  1.upto(node['rs-storage']['device']['stripe_count'].to_i) do |stripe_num|
    rightscale_volume "#{nickname}_#{stripe_num}" do
      action [:detach, :delete]
    end
  end
#else
#  rightscale_volume nickname do
#    action [:detach, :delete]
#  end
#end
