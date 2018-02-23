resource_name :acme_persistence

property :cn,        String, name_property: true
property :alt_names, Array
property :key,       String, required: true
property :crt,       String
property :chain,     String
property :fullchain, String

property :master, [TrueClass, FalseClass], default: false

property :data_bag_name, String, required: true
property :encrypt, [TrueClass, FalseClass], default: true
property :secret, String

property :owner,     String, default: 'root'
property :group,     String, default: 'root'

action :save do
  unless master
    Chef::Log.warn "master property not set, will not save #{cn} certificates"
    return
  end

  data = {
    'id'         => cn,
    'alt_names'  => alt_names,
    'created_by' => node['fqdn'],
    'created_at' => Time.now
  }

  # 'key', 'cert', 'chain' are also used in the data bag format used by
  # https://github.com/atomic-penguin/cookbook-certificate/blob/master/providers/manage.rb
  data['key']       = ::File.read(new_resource.key)       if new_resource.key
  data['cert']      = ::File.read(new_resource.crt)       if new_resource.crt
  data['chain']     = ::File.read(new_resource.chain)     if new_resource.chain

  data['fullchain'] = ::File.read(new_resource.fullchain) if new_resource.fullchain

  chef_data_bag_item "#{data_bag_name}/#{cn}" do
    raw_data data
    if new_resource.encrypt && (new_resource.secret || default_data_bag_secret)
      encrypt true
      encryption_version 2
      secret new_resource.secret || default_data_bag_secret
    end
  end
end

# Matrix:
#
# +------------------------+-----------------+--------------------------------------+
# |  file                  |  data bag item  |  action                              |
# | ---------------------- | --------------- | ------------------------------------ |
# |  does not exist        |  exists         |  create from data bag item           |
# |  does not exist        |  does not exist |  nothing (-> acme_selfsigned)        |
# |  exists (self-signed)  |  exists         |  create from data bag item           |
# |  exists (self-signed)  |  does not exist |  nothing (~> renew acme_certificate) |
# |  exists (valid)        |  is newer       |  create from data bag item           |
# |  exists (valid)        |  is older       |  nothing (~> renew acme_certificate) |
# |  exists (expired)      |  is newer       |  create from data bag item           |
# |  exists (expired)      |  does not exist |  nothing (~> renew acme_certificate  |
# +------------------------+-----------------+--------------------------------------+
#
action :load do
  begin
    existing_cert = ::OpenSSL::X509::Certificate.new(::File.read(crt || fullchain))
  rescue Errno::ENOENT => e
    Chef::Log.warn("certificate file #{crt || fullchain} does not exist yet: #{e}")
  rescue OpenSSL::X509::CertificateError => e
    Chef::Log.error("certificate file #{crt || fullchain} exists but is broken: #{e}")
  end

  item = load_data_bag_item(data_bag_name, 'id:' + cn, secret)
  return unless item

  render_to_files(item) if !existing_cert ||
                           self_signed?(existing_cert) ||
                           item_newer?(item, existing_cert)
end

action_class do
  def load_data_bag_item(data_bag_name, _data_bag_item, secret = nil)
    item = search(data_bag_name, 'id:' + cn).first
    item = ::Chef::EncryptedDataBagItem.new(item, secret) if item && secret
    item
  end

  def self_signed?(cert)
    cert.issuer == cert.subject
  end

  def item_newer?(item, existing_cert)
    item_cert   = ::OpenSSL::X509::Certificate.new item['cert'] if item['cert']
    item_cert ||= ::OpenSSL::X509::Certificate.new item['fullchain'] if item['fullchain']
    item_cert.not_before > existing_cert.not_before
  rescue OpenSSL::X509::CertificateError => e
    Chef::Log.error("data bag item #{new_resource.data_bag_name}/#{item['id']} is broken: #{e}")
  end

  def render_to_files(item)
    file "acme_store: #{new_resource.cn} SSL key" do
      path      new_resource.key
      owner     new_resource.owner
      group     new_resource.group
      mode      00400
      content   item['key']
      sensitive true
      action    :create
    end

    file "acme_store: #{new_resource.cn} SSL crt" do
      path      new_resource.crt
      owner     new_resource.owner
      group     new_resource.group
      mode      00644
      content   item['cert']
      action    :create

      only_if { !!item['cert'] }
    end

    file "acme_store: #{new_resource.cn} SSL fullchain" do
      path      new_resource.fullchain
      owner     new_resource.owner
      group     new_resource.group
      mode      00644
      content   item['fullchain']
      action    :create

      only_if { !!item['fullchain'] }
    end

    file "acme_store: #{new_resource.cn} SSL chain" do
      path      new_resource.chain
      owner     new_resource.owner
      group     new_resource.group
      mode      00644
      content   item['chain']
      action    :create

      only_if { !!item['chain'] }
    end
  end

  def default_data_bag_secret
    Chef::EncryptedDataBagItem.load_secret(Chef::Config[:encrypted_data_bag_secret])
  rescue => e
    Chef::Log.error "property 'secret' is not provided and the default encrypted_data_bag_secret file does not exist: #{e}"
  end
end
