# win_scheduled_task

### why?

because the api that windows exposes for things like puppet to make scheduled tasks sucks.  it isn't full featured, not even the commands themselves can do everything that's in the gui.

its better, and you get more control, if you make the task in `Task Scheduler` the way you want it, and then export it.  `schtasks` is a pretty reliable way to import and manage the task from the xml export.

### Usage

```
class test {
  win_scheduled_task::manage { 'MyService':
    ensure => present,
    file_source => "puppet:///modules/test/MyService.xml"
  }
}
```

### TODO

probably should add a way to ensure the service is running.  right now you configure the service to be running, but if it stopped you would be in a bad spot.  maybe this could be solved by using another module that could ensure specific scheduled tasks are enabled.