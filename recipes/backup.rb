#
# Cookbook Name:: rs-storage
# Recipe:: backup
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

marker 'recipe_start_rightscale' do
    template 'rightscale_audit_entry.erb'
end

include_recipe 'chef_handler::default'

cookbook_file "#{node['chef_handler']['handler_path']}/backup_error_handler.rb" do
  source 'backup_error_handler.rb'
  action :create
end

chef_handler 'Rightscale::BackupErrorHandler' do
  source "#{node['chef_handler']['handler_path']}/backup_error_handler.rb"
  action :enable
end

nickname = node['rs-storage']['device']['nickname']

filesystem nickname do
  mount node['rs-storage']['device']['mount_point']
  action :freeze
end

rightscale_backup nickname do
  lineage node['rs-storage']['backup']['lineage']
  action :create
end

filesystem nickname do
  mount node['rs-storage']['device']['mount_point']
  action :unfreeze
end
