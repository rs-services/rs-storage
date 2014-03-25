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
    extend Chef::Mixin::ShellOut

    # Given a mount point this method will inspect if an LVM is used for the device mounted at the mount point.
    #
    # @param mount_point [String] the mount point of the device
    #
    # @return [Boolean] whether LVM is used in the device at the mount point
    #
    def self.is_lvm_used?(mount_point)
      mount = shell_out!('mount')
      mount.stdout.each_line do |line|
        if line =~ /^(.+)\s+on\s+#{mount_point}\s+/
          return !!($1 =~ /^\/dev\/mapper/)
        end
      end
      false
    end

    # Given a mount point this method will inspect if an LVM is used for the device mounted at the mount point.
    #
    # @param mount_point [String] the mount point of the device
    #
    # @return [Boolean] whether LVM is used in the device at the mount point
    #
    # @see .is_lvm_used?
    #
    def is_lvm_used?(mount_point)
      RsStorage::Helper.is_lvm_used?(mount_point)
    end

    # Removes the LVM conditionally. It only accepts the name of the volume group and performs the following:
    # 1. Removes the logical volumes in the volume group
    # 2. Removes the volume group itself
    # 3. Removes the physical volumes used to create the volume group
    #
    # This method is also idempotent -- it simply exits if the volume group is already removed.
    #
    # @param volume_group_name [String] the name of the volume group
    #
    def self.remove_lvm(volume_group_name)
      require 'lvm'
      lvm = LVM::LVM.new
      volume_group = lvm.volume_groups[volume_group_name]
      if volume_group.nil?
        Chef::Log.info "Volume group '#{volume_group_name}' is not found"
      else
        logical_volume_names = volume_group.logical_volumes.map { |logical_volume| logical_volume.name }
        physical_volume_names = volume_group.physical_volumes.map { |physical_volume| physical_volume.name }

        # Remove the logical volumes
        logical_volume_names.each do |logical_volume_name|
          Chef::Log.info "Removing logical volume '#{logical_volume_name}'"
          command = "lvremove /dev/mapper/#{to_dm_name(volume_group_name)}-#{to_dm_name(logical_volume_name)} --force"
          Chef::Log.debug "Running command: '#{command}'"
          output = lvm.raw(command)
          Chef::Log.debug "Command output: #{output}"
        end

        # Remove the volume group
        Chef::Log.info "Removing volume group '#{volume_group_name}'"
        command = "vgremove #{volume_group_name}"
        Chef::Log.debug "Running command: #{command}"
        output = lvm.raw(command)
        Chef::Log.debug "Command output: #{output}"

        physical_volume_names.each do |physical_volume_name|
          Chef::Log.info "Removing physical volume '#{physical_volume_name}'"
          command = "pvremove #{physical_volume_name}"
          Chef::Log.debug "Running command: #{command}"
          output = lvm.raw(command)
          Chef::Log.debug "Command output: #{output}"
        end
      end
    end

    # Removes the LVM conditionally. It only accepts the name of the volume group and performs the following:
    # 1. Removes the logical volumes in the volume group
    # 2. Removes the volume group itself
    # 3. Removes the physical volumes used to create the volume group
    #
    # This method is also idempotent -- it simply exits if the volume group is already removed.
    #
    # @param volume_group_name [String] the name of the volume group
    #
    # @see .remove_lvm
    #
    def remove_lvm(volume_group_name)
      RsStorage::Helper.remove_lvm(volume_group_name)
    end

    # Replaces dashes (-) with double dashes (--) to mimic the behavior of the LVM cookbook's naming convention of
    # naming logical volume names.
    #
    # @param name [String] the name to be converted
    #
    # @return [String] the converted name
    #
    def self.to_dm_name(name)
      name.gsub(/-/, '--')
    end

    # Replaces dashes (-) with double dashes (--) to mimic the behavior of the LVM cookbook's naming convention of
    # naming logical volume names.
    #
    # @param name [String] the name to be converted
    #
    # @return [String] the converted name
    #
    # @see .to_dm_name
    #
    def to_dm_name(name)
      RsStorage::Helper.to_dm_name(name)
    end
  end
end

# Include this helper to recipes
::Chef::Recipe.send(:include, RsStorage::Helper)
::Chef::Resource::RubyBlock.send(:include, RsStorage::Helper)
