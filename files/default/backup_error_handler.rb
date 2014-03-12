module Rightscale
  class BackupErrorHandler < Chef::Handler
    def report
      nickname = run_context.node['rs-storage']['device']['nickname']
      filesystem_resource = run_context.resource_collection.lookup("filesystem[#{nickname}]")
      filesystem_resource.run_action(:unfreeze) if filesystem_resource
    end
  end
end
