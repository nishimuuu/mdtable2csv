require "mdtable2csv/version"
require 'pathname'

$:.unshift Pathname.new(__FILE__).dirname.join.expand_path.to_s

require 'mdtable2csv/mdtable2csv_command'
module Mdtable2csv
  # Your code goes here...
end
