#
# Cookbook Name:: rs-storage
# Library:: helper
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

require 'chef/mixin/shell_out'

module RsStorage
  module Helper
    include Chef::Mixin::ShellOut

    # Given a mount point this method will inspect if an LVM is used for the device mounted at the mount point.
    #
    # @param mount_point [String] the mount point of the device
    #
    # @return [Boolean] whether LVM is used in the device at the mount point
    #
    def is_lvm_used?(mount_point)
      mount = shell_out!('mount')
      mount.stdout.each_line do |line|
        if line =~ /^(.+)\s+on\s+#{mount_point}\s+/
          return !!($1 =~ /^\/dev\/mapper/)
        end
      end
      false
    end
  end
end

# Include this helper to recipes
::Chef::Recipe.send(:include, RsStorage::Helper)
