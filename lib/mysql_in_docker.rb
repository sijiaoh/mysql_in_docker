# frozen_string_literal: true

require_relative "mysql_in_docker/version"
require_relative "./commands"

module MysqlInDocker
  class Error < StandardError; end

  Commands.start(ARGV) unless ENV["ENV"] == "test"
end
