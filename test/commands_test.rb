# frozen_string_literal: true

require "./test/test_helper"

Commands = MysqlInDocker::Commands

def start(commands)
  commands.start "test", "8", "3307", "test"
end

def containers
  `docker ps`
end

def volumes
  `docker volume ls`
end

describe Commands.name do
  it "should be work" do
    commands = Commands.new

    start commands
    assert_includes containers, commands.send(:get_container_name, "test")
    assert_includes volumes, commands.send(:get_container_name, "test")

    commands.stop "test"
    refute_includes containers, commands.send(:get_container_name, "test")
    assert_includes volumes, commands.send(:get_container_name, "test")

    start commands
    commands.remove "test"
    refute_includes containers, commands.send(:get_container_name, "test")
    refute_includes volumes, commands.send(:get_container_name, "test")
  end
end
