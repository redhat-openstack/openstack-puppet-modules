require 'pp'

class MCollective::Application::Libvirt<MCollective::Application
  description "Libvirt Manager"
  usage "Usage: mc libvirt [options] action [args]"

  def post_option_parser(configuration)
    configuration[:action] = ARGV.shift
    configuration[:arguments] ||= []
    ARGV.each do |v|
      if v =~ /^(.+?)=(.+)$/
        configuration[:arguments] << v
      else
        STDERR.puts("Could not parse --arg #{v}")
      end
    end

    # convert arguments to symbols for keys to comply with simplerpc conventions
    args = configuration[:arguments].clone
    configuration[:arguments] = {}

    args.each do |v|
        if v =~ /^(.+?)=(.+)$/
            configuration[:arguments][$1.to_sym] = $2
        end
    end
  end

  def validate_configuration(configuration)
  end

  def main
    mc = rpcclient("libvirt", :options => options)

    action = configuration[:action]

    data = {}
    mc.send(action, configuration[:arguments]).each do |resp|
      if resp[:statuscode] == 0
        data[resp[:sender]] ||= {}
        case action 
        when "domain_list"
          data[resp[:sender]][:domain_list] = resp[:data]["domain_list"]
          data[resp[:sender]][:status] = resp[:data]["status"]
        when "domain_detail"
          data[resp[:sender]][:domain_detail] = resp[:data]["domain_detail"]
          data[resp[:sender]][:status] = resp[:data]["status"]
        else
          data[resp[:sender]][:status] = resp[:data]["status"]
        end
      else
         printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
      end
    end

    # summarize
    case action
    when "domain_list"
      puts sprintf("%-36s %-4s %-8s %-4s %-4s %-6s %-15s", "UUID", "ID", "NAME", "STATUS", "VCPU", "MEM", "NODE")
      data.each do |sender,value|
        value[:domain_list].each do |uuid,domain_info|
          # Basic conversion to megabytes - but probably should have a nicer way of doing
          # this for other unit sizes
          memory = (domain_info["memory"].to_i/1024).floor.to_s + "M"
          status = domain_info["status"].to_i ? "running" : "stopped"
          puts sprintf("%-36.36s %-4.4s %-8.8s %-6.6s %-4.4s %-6.6s %-15.15s", uuid, domain_info["id"], domain_info["name"], status, domain_info["num_vcpus"], memory, sender)
        end
      end
    else
      data.each do |sender,data|
        puts "#{sender}:"
        pp data
      end
    end
  end
end
# vi:tabstop=4:expandtab:ai
