class Druid < Formula
  desc "Druid is an analytics data store designed for OLAP queries on event data."
  homepage "http://druid.io"
  url "http://static.druid.io/artifacts/releases/druid-0.7.3-bin.tar.gz"
  sha256 "2f30ea6f31f1f34450a23fda70efcbb02c991c7787049c4b250b84f625435c8f"

  depends_on :java
  depends_on "zookeeper"

  def install
    libexec.install Dir["*"]
    bin.write_exec_script "#{libexec}/run_example_server.sh"
    File.rename("#{bin}/run_example_server.sh", "#{bin}/druid")
  end

  def caveats; <<-EOS.undent
    Before starting Druid, ensure that ZooKeeper is running:
      zkServer start

    then start the Druid server with one of the example data sets:
      druid [wikipedia|twitter]

    To submit an example query, run:
      #{libexec}/run_example_client.sh [wikipedia|twitter]
    EOS
  end

  test do
    fork { exec "zkServer", "start-foreground" }
    sleep 10

    fork { exec bin/"druid", "wikipedia" }
    sleep 30

    begin
      system "curl", "-s", "-S", "-f", "-L", "http://localhost:8084/status"
    ensure
      system "pkill", "-g", "#{Process.getpgrp}"
      Process.wait
      sleep 3
    end
  end
end
