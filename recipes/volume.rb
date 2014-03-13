#
# Cookbook Name:: rs-storage
# Recipe:: volume
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

if node['rs-storage']['device']['restore'] == true || node['rs-storage']['device']['restore'] == 'true'
  lineage = node['rs-storage']['backup']['lineage']
  lineage_override = node['rs-storage']['backup']['lineage_override']
  timestamp_override = node['rs-storage']['backup']['timestamp_override']

  message = "Restoring volume '#{nickname}' from backup"
  if node['rs-storage']['backup']['lineage_override']
    message << " by overriding lineage to '#{lineage_override}'"
  else
    message << " using lineage '#{lineage}'"
  end
  message << " and overriding timestamp to '#{timestamp_override}'" if timestamp_override

  log message

  rightscale_backup nickname do
    if node['rs-storage']['backup']['lineage_override']
      lineage node['rs-strage']['backup']['lineage_override']
    else
      lineage node['rs-storage']['backup']['lineage']
    end
    timestamp node['rs-storage']['backup']['timestamp_override'] if node['rs-storage']['backup']['timestamp_override']
    size node['rs-storage']['device']['volume_size'].to_i
    action :restore
  end

  mount node['rs-storage']['device']['mount_point'] do
    fstype node['rs-storage']['device']['filesystem']
    device lazy { node['rightscale_volume'][nickname]['device'] }
    action [:mount, :enable]
  end
else

  log "Creating a new volume '#{nickname}' with size #{node['rs-storage']['device']['volume_size']}"
  rightscale_volume nickname do
    size node['rs-storage']['device']['volume_size'].to_i
    action [:create, :attach]
  end

  filesystem nickname do
    fstype node['rs-storage']['device']['filesystem']
    device lazy { node['rightscale_volume'][nickname]['device'] }
    mkfs_options node['rs-storage']['device']['mkfs_options']
    mount node['rs-storage']['device']['mount_point']
    action [:create, :enable, :mount]
  end
end
