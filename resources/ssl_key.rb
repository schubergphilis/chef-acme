actions [:create, :create_if_missing, :destroy]
default_action :create_if_missing

property :path, 				String,  :name_attribute => true
property :length,				Integer, :default => 2048
property :output_format,        Symbol,  :equal_to => [:pem, :der, :text], :default => :pem
property :type,					Symbol,  :equal_to => [:rsa, :dsa], :default => :rsa

def load
  klass = OpenSSL::PKey.const_get(type.upcase)
  klass.new(::File.read(path)) if ::File.exist?(path)
end
