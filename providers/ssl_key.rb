use_inline_resources

def do_action(file_action)
  klass = OpenSSL::PKey.const_get(new_resource.type.upcase)
  key = klass.new(new_resource.length)
  data = key.send("to_#{new_resource.output_format}".to_sym)

  file new_resource.path do
    owner     owner
    group     group
    mode      00400
    content   data
    sensitive true

    action file_action
  end
end

action :create do
	do_action(:create)
end

action :destroy do
	do_action(:destroy)
end

action :create_if_missing do
	do_action(:create_if_missing)
end
