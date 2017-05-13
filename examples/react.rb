def ignore_methods
  super + %w(react_component)
end

def ignore_keys
  super + %w(tag)
end
