require 'json'

Puppet::Type.type(:import_task).provide :windows do
  desc 'Import a scheduled task from an xml export.'

  confine operatingsystem: :windows

  defaultfor operatingsystem: :windows

  commands schtaskcmd: 'C:\Windows\System32\schtasks.exe'

  def create
    schtaskcmd('/Create', '/TN', resource[:name], '/XML', resource[:task])
    writereceipt
  end

  def destroy
    schtaskcmd('/Delete', '/F', '/TN', resource[:name])
  end

  def exists?
    state = getinstalledstate
    if state['present'] != true
      return false
    else
      return true
    end
  end

  def getreceipts
    begin
      file = File.read(Puppet[:vardir] + '/scheduledtasks/receipts.json')
      receipts = JSON.parse(file)
    rescue IOError, Errno::ENOENT
      receipts = {}
    end
    receipts
  end

  def writereceipt
    path = Puppet[:vardir] + '/scheduledtasks/receipts.json'
    receipts = getreceipts

    receipts[resource[:name]] = { 'install_time' => Time.now.to_i }

    File.open(path, 'w') do |f|
      f.write(receipts.to_json)
    end
  end

  # TODO get the install state is a more reliable way.
  # Right now if the task isn't found the exec errors,
  # and we assume its not present.
  def getinstalledstate
    state = {}
    begin
      output = Puppet::Util::Execution.execute(['C:\Windows\System32\schtasks.exe', '/Query', '/TN', resource[:name]])

      lines = output.split("\n")

      lines.each do |line|
        if line.include?(resource[:name])
          state['present'] = true
        else
          state['present'] = false
        end
      end
    rescue
      state['present'] = false
    end
    state
  end
end
