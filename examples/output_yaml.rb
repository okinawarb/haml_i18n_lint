require 'yaml'

def report(result_set)
  t = {}
  result_set.each_with_object(t['en'] = {}) do |result, t|
    keys = result.filename.gsub(%r{^app/views/}, '').gsub(/(\.html)?\.haml$/, '').split('/')
    t = keys.inject(t) { |t, key| t[key] ||= {} }
    key = "L#{result.node.line}"
    unless t.key?(key)
      t[key] = result.text
      next
    end
    key << "-1"
    key.next! while t.key?(key)
    t[key] = result.text
  end
  puts t.to_yaml
end
