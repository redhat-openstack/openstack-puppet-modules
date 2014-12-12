metadata    :name        => "SimpleRPC Agent For Libvirt Management",
            :description => "Agent To Manage Libvirt",
            :author      => "Ken Barber",
            :license     => "ASLv2",
            :version     => "0.0.1",
            :url         => "http://github.com/puppetlabs/puppetlabs-libvirt",
            :timeout     => 180

action "domain_list", :description => "List domains" do
  display :always

  output :domain_list,
         :description => "Hash with small amount of information per domain",
         :display_as => "Domain List"

  output :status,
         :description => "Status of action",
         :display_as => "Status"
end

action "domain_detail", :description => "List domains" do
  display :always

  input :uuid,
        :prompt => "UUID of domain",
        :description => "UUID of domain",
        :type => :string,
        :validation => '.',
        :optional => false,
        :maxlength => 250

  output :domain_detail,
         :description => "Hash with detailed information on a domain",
         :display_as => "Domain Detail"

  output :status,
         :description => "Status of action",
         :display_as => "Status"
end

action "domain_shutdown", :description => "Shutdown domain" do
  display :always

  input :uuid,
        :prompt => "UUID of domain",
        :description => "UUID of domain",
        :type => :string,
        :validation => '.',
        :optional => false,
        :maxlength => 250

  output :status,
         :description => "Status of action",
         :display_as => "Status"
end

action "domain_destroy", :description => "Destroy domain" do
  display :always

  input :uuid,
        :prompt => "UUID of domain",
        :description => "UUID of domain",
        :type => :string,
        :validation => '.',
        :optional => false,
        :maxlength => 250

  output :status,
         :description => "Status of action",
         :display_as => "Status"
end

action "domain_create", :description => "Create domain" do
  display :always

  input :name,
        :prompt => "Name of domain",
        :description => "Name of domain",
        :type => :string,
        :validation => '.',
        :optional => false,
        :maxlength => 100

  output :status,
         :description => "Status of action",
         :display_as => "Status"
end
