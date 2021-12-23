# frozen_string_literal: true

Dir.glob(ARGV[0] ? "./#{ARGV[0]}" : "./test/**/*.rb").each do |file|
  require file
end
