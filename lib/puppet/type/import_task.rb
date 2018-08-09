Puppet::Type.newtype(:import_task) do
  @doc = <<-EOT
    Import a windows scheduled task from an xml export
    https://docs.microsoft.com/en-us/windows/desktop/taskschd/schtasks
    Example Usage:
      import_task { 'DoSomething':
        ensure   => present,
        task     => '/path/to/task.xml',
      }.
    The namevar for this type is the task's Name
    task = path to the xml file on the client system.
  EOT

  ensurable

  def refresh
    begin
      provider.create
    rescue
      provider.destroy
      provider.create
      debug "Destroying and Recreating Task"
    end
  end

  newparam(:name, namevar: true)
  newparam(:task)
end
