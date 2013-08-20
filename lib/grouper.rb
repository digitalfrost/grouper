module Grouper

  #find a security group, create it if it does not exist
  #
  def find_or_create(ec2, group_name)
    if ec2.security_groups.map(&:name).include?(group_name)
      ec2.security_groups.filter('group-name', group_name).first
    else
      ec2.security_groups.create(group_name)
    end
  end

  #Takes an array of rules and applies them to a security froup
  #if the security group has rules that are not part of the rules array being applied these are revoked
  #
  def apply_rules(group, rules)
    remove_old_rules(group, rules)
    rules.each do |rule|
      add_rule(group, rule)
    end
  end

  #revoke old rules that are not part of the rules array
  #
  def remove_old_rules(group, rules)
    group.ingress_ip_permissions.each do |p|
      p.revoke if !is_rule?(p, rules)
    end
    group.egress_ip_permissions.each do |p|
      p.revoke if !is_rule?(p, rules)
    end
  end

  #checks to see if an EC2 IP permission is in array of rules
  #
  def is_rule?(permission, rules)
    rules.each do |rule|
      return true if match?(permission, rule)
    end
    false
  end

  #checks to see if an EC2 IP permission matches a rule
  #AWS doesn't do clever recombination of rules in the background so we do simple comparaisons to keep things simples
  #
  def match?(permission, rule)
    if rule.direction == :in
      (permission.port_range == rule.ports) and (permission.ip_ranges == rule.sources) and (permission.protocol == rule.protocol) and (!permission.egress)
    elsif rule.direction == :out
      (permission.port_range == rule.ports) and (permission.ip_ranges == rule.sources) and (permission.protocol == rule.protocol) and (permission.egress)
    else #rule.direction == :both
      (permission.port_range == rule.ports) and (permission.ip_ranges == rule.sources) and (permission.protocol == rule.protocol)
    end
  end

  #add a rule to a security group
  #
  def add_rule(group, rule)
    begin
      case rule.direction
      when :in
	group.authorize_ingress(rule.protocol, rule.ports, *rule.sources)
      when :out
	group.authorize_egress(*rule.sources, :protocol => rule.protocol, :ports => rule.ports)
      else
	group.authorize_ingress(rule.protocol, rule.ports, *rule.sources)
	group.authorize_egress(*rule.sources, :protocol => rule.protocol, :ports => rule.ports)
      end
    rescue AWS::EC2::Errors::InvalidPermission::Duplicate
    
    end
  end

  #remove rule from a security group
  #
  def revoke_rule(group, rule)
    case rule.direction
    when :in
      group.revoke_ingress(rule.protocol, rule.ports, *rule.sources)
    when :out
      group.revoke_egress(*rule.sources, :protocol => rule.protocol, :ports => rule.ports)
    else
      group.revoke_ingress(rule.protocol, rule.ports, *rule.sources)
      group.revoke_egress(*rule.sources, :protocol => rule.protocol, :ports => rule.ports)
    end
  end

  class Rule < Struct.new(:protocol, :ports, :sources, :direction)
  end

  #syntactic sugar to allow pinging a server
  #allows Echo Request and Echo Reply
  #
  def ping(ips)
    [Rule.new(:icmp, 8..-1, ips, :in), 
     Rule.new(:icmp, 0..-1, ips, :out)]
  end

end
