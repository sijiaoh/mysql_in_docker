# frozen_string_literal: true

require "thor"
require "open3"

module MysqlInDocker
  class Commands < Thor
    def self.exit_on_failure?
      true
    end

    desc "start ID VERSION PORT MYSQL_ROOT_PASSWORD", "Prepare mysql in docker."
    def start(id, version, port, mysql_root_password)
      status = docker_command "start #{get_container_name(id)}"
      if status[:successed]
        p "#{get_container_name(id)} running on #{port}."
        return
      end

      command = up_command id, version, port, mysql_root_password
      status = docker_command(command)
      raise_if_status_failed status

      p "Created #{get_container_name(id)} on #{port}."
    end

    desc "stop ID", "Remove mysql container."
    def stop(id)
      status = docker_command "rm -f #{get_container_name(id)}"
      if status[:stderr].include? "No such container:"
        p "Container not found."
      else
        p "Removed container."
      end
    end

    desc "remove ID", "Remove mysql container and volume."
    def remove(id)
      stop id

      status = docker_command "volume rm #{get_container_name(id)}"
      if status[:stderr].include? "No such volume:"
        p "Volume not found."
      else
        p "Removed volume."
      end
    end

    private

    def raise_if_status_failed(status)
      raise Error, status[:stderr] unless status[:successed]
    end

    def docker_command(command)
      o, e, s = Open3.capture3("docker #{command}")
      { stdout: o, stderr: e, status: s, successed: s.success? }
    end

    def get_container_name(id)
      "mysql_in_docker_#{id}"
    end

    def up_command(id, version, port, mysql_root_password) # rubocop:disable Metrics/MethodLength
      [
        "run",
        "--name", get_container_name(id),
        "--env",
        "MYSQL_ROOT_PASSWORD=#{mysql_root_password}",
        "--publish",
        "#{port}:3306",
        "--volume",
        "#{get_container_name(id)}:/var/lib/mysql",
        "-d",
        "mysql:#{version}"
      ].join(" ")
    end
  end
end
