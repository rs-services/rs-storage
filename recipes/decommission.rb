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

# Single device
if node['rs-storage']['device']['stripe_count'] == 1
  rightscale_volume nickname do
    action [:detach, :delete]
  end
# Multiple device stripes
else
  # TODO: Remove LVM conditionally using the lvm cookbook and detach and destroy all volumes
end
