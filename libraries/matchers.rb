if defined?(ChefSpec)
  def create_letsencrypt_selfsigned(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:letsencrypt_selfsigned, :create, resource_name)
  end

  def create_letsencrypt_certificate(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:letsencrypt_certificate, :create, resource_name)
  end
end
