result_count = 0
define_method(:report) do |result_set|
  result_count += result_set.count
  super(result_set)
end

at_exit do
  puts "Total: #{result_count}"
end
