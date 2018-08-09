Puppet::Type.newtype(:import_task) do
  @doc = <<-EOT
    Import a windows scheduled task from an xml export
    https://docs.microsoft.com/en-us/windows/desktop/taskschd/schtasks    Example Usage:
      import_task { 'DoSomething':
        ensure   => present,
        task  => '/path/to/task.xml',
      }.
    The namevar for this type is the task's Name
    Task = path to the xml file on the client system.
  EOT

  ensurable

  def refresh
    provider.create
  end

  newparam(:name, namevar: true)
  newparam(:task)
end
