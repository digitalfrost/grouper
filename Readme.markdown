#Simple AWS Security Group Management

Grouper makes it easy to manage AWS Security Groups programatically, 

It aims to be simple and to overcome some of the limitations and pain of managing security groups via the AWS management console.
* It makes it easy to understand what a rule or group of rules does
* It makes easy to reuse rules across security rules
* It makes applying a set of rules to a new security group much faster


##Installation

```
gem install 'grouper'
```

You will need a yml file containing your AWS credentials in the form

```
access_key_id: ACCESS_KEY_ID
secret_access_key: SECRET_ACCESS_KEY_ID
```


## Examples

You want your new intranet server hosted on EC2 to be monitored by worm.ly, connect to github and receive ubuntu updates....

See example.rb and example-vpc.rb


```ruby
#example.rb
require 'aws-sdk'
require 'grouper'
include Grouper 

AWS.config(YAML.load(File.read('path/to/credentials/aws.yml'))) #your AWS credentials

wormly_ips = ['178.79.181.14/32', '103.1.185.241/32', '184.72.226.23/32', '66.246.75.38/32', '74.82.3.54/32', '74.207.230.51/32', '69.164.195.159/32', '184.73.218.144/32']

github_ips = ['207.97.227.224/27', '173.203.140.192/27', '204.232.175.64/27', '72.4.117.96/27']

wormly = [Rule.new(:tcp, 443, wormly_ips, :in)]

github = [ Rule.new(:tcp, 22, github_ips, :in),
           Rule.new(:tcp, 80, github_ips, :in),
           Rule.new(:tcp, 443, github_ips, :in)]
           

ec2 = AWS::EC2.new(:ec2_endpoint => "ec2.eu-west-1.amazonaws.com")
intranet_server = find_or_create(ec2, 'intranet_server')
rules = wormly + github
apply_rules(intranet_server, rules)

```

Now simply add the "intranet_server" security group to your EC2 instance(s)

### Port range for echo requests

When defining rules for echo requests the value for :ports should be in the format 0..-1 where 0 is the ICMP code type.

E.g.

```
  #Allow echo requests from Wormly
  Rule.new(:icmp, 8..-1, wormly_ips, :in)
```

## Updating rules

Make changes to your grouper script and rerun it - rules that are no longer defined in the rules array passed to apply_rules() will be be removed.

## License

Grouper is released under the MIT license:

* http://www.opensource.org/licenses/MIT
