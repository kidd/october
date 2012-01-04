class Update
  include October::Plugin

  match /selfupdate$/, method: :selfupdate
  match /seppuku$/, method: :seppuku
  match /spawn (.+)$/, method: :spawn
  match /kill (-9 )?(.+)$/, method: :kill
  match /running$/, method: :running

  $SPAWNS = []

  def selfupdate(m)
    m.reply "starting selfupdate..."
    `git fetch origin`
    `git reset --hard origin/master`
    m.reply "selfupdate completed!"
  end

  def seppuku(m)
    m.reply("bye... AGRG!! ahh...")
    sleep(1)
    exit(0)
  end

  def running(m)
    m.reply "running processes: #{$SPAWNS.join(", ")}"
  end

  def kill(m, kill, pid)
    pid = pid.to_i

    signal = kill ? 'KILL' : 'TERM'
    Process.kill(signal, pid)
    m.reply "sent #{signal} to process #{pid}"
  end

  def spawn(m, command)
    pid = Process.spawn(command)

    $SPAWNS.push pid
    m.reply "spawned command '#{command}' with pid #{pid}"

    Thread.new do
      Process.wait(pid)
      $SPAWNS.delete(pid)
      m.reply "process #{pid} exited with status #{$?.exitstatus}"
    end
  end

end
