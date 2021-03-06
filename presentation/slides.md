# presentation

!SLIDE left

# Test-driving Chef cookbooks
## Using ChefSpec and Librarian-Chef

abiyani@lytro.com
https://github.com/Lytro/teaching_chef_cookbooks

!SLIDE left

## What is Chef?

Chef treats infrastructure as code
* maintainable
* testable
* scalable
* a simple-ish DSL on top of Ruby

!SLIDE left

## So what's a cookbook?

Cookbooks are like libraries
* they contain code that accomplishes some specific goal, like installing Apache2 or Git.
* http://community.opscode.com/cookbooks

!SLIDE left

## Here's what's inside a stock cookbook:

<figure>
```shell
  └── my_cookbook/
    ├── attributes/
    │   └── default.rb
    ├── definitions/
    ├── files/
    │   └── default/
    ├── libraries/
    ├── providers/
    ├── recipes/
    │   └── default.rb
    ├── resources/
    ├── templates/
    ├── metadata.rb
    └── README.md
```
</figure>

!SLIDE left

## My cookbooks have a couple of additions:

<figure>
```shell
  └── my_cookbook
    ├── spec/
    │   ├── spec_helper.rb
    │   └── default_spec.rb
    ├── Cheffile
    ├── Cheffile.lock
    ├── Gemfile
    └── Gemfile.lock
```
</figure>

* Cheffile is a part of Librarian-Chef; it's very similar to a Gemfile
* specs are a part of ChefSpec (which is built on RSpec)

I have a template setup here: https://github.com/Lytro/chef_cookbook_template

!SLIDE left

## What it all means
1. **Recipes** are the meat of a cookbook. They **contain the code that gets executed**.
2. **Attributes** contain **variables** that can get overridden by people using the cookbook, or that vary depending on the OS.
3. **Definitions** are basically contain **functions** that are used across recipes.
4. **Libraries** contain generic Ruby. **Classes or modules** can be defined in here and used across recipes/definitions/whatever.
5. **Providers** know how to accomplish certain goals for different OSes. An example of a "goal" **might be creating a directory or downloading a file** from the web.
6. **Resources** are simply **a specific provider**. For example, `directory` is a resource that creates a directory; it is implemented via providers.

!SLIDE left

## What it all means - continued
7. **Files** can be **copied to the target system**, and are sorted in subdirectories by OS
8. **Templates** are **files that use .erb** to inject ruby variables, usually from attributes.
9. **Metadata** simply **contains information about the cookbook** that Chef uses for information like dependencies and which OSes the cookbook supports.

* For the most part you can ignore `libraries`, `providers`, and `resources` (you'll rarely need them, and I won't be explaining them because I haven't used them).*
* I use `files` and `templates` frequently but not always.
* `recipes` are mandatory, and `attributes` are pretty much always necessary.

<sub>* http://wiki.opscode.com/display/chef/Introduction+to+Cookbooks+and+More</sub>

!SLIDE left

## Let's dive in: `metadata.rb`

<figure>
```ruby
name             "Cookbook Name" # Optional, if omitted then is inferred
                                 # from the name of the directory
maintainer       "Your Name"
maintainer_email "your@email.com"
license          "Apache 2.0"
description      "Installs/Configures cookbook_name"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends          "some_other_cookbook", "> 0.1.0"
depends          "another_cookbook", "> 0.1.5"
supports         "Ubuntu", "> 10.04.4"
```
</figure>

Librarian-Chef pulls in dependent cookbooks through the "depends" listing.
 * You cannot target a git repo through the metadata (instead, use the Cheffile).

<sub>http://wiki.opscode.com/display/chef/Metadata</sub>

!SLIDE left

## `attributes/default.rb`

<figure>
```ruby
default[:cookbook_name][:variable]
default["cookbook_name"]["variable"]

override[:something][:something_else]
```
</figure>

* Attributes are accessed with `node[:foo]` or `node["foo"]` or `node.foo`.
* They all exist in the global namespace, so you should add `[:cookbook_name]` to the beginning of all of your attributes.

Precedence, from low to high:
1. default attributes applied in an attributes file
2. default attributes applied in an environment
3. default attributes applied in a role
4. default attributes applied on a node directly in a recipe
5. normal or set attributes applied in an attributes file
6. normal or set attributes applied on a node directly in a recipe
7. [and more](http://wiki.opscode.com/display/chef/Attributes#Attributes-Precedence)

<sub>http://wiki.opscode.com/display/chef/Attributes</sub>

!SLIDE left

## `Cheffile`

<figure>
```ruby
#!/usr/bin/env ruby
#^syntax detection

site 'http://community.opscode.com/api/v1'

# cookbook 'chef-client'

# cookbook 'apache2', '>= 1.0.0'

# cookbook 'rvm',
#   :git => 'https://github.com/fnichol/chef-rvm'

# cookbook 'postgresql',
#   :git => 'https://github.com/findsyou/cookbooks',
#   :ref => 'postgresql-improvements'
```
</figure>

* `librarian-chef install` will install cookbooks to `cookbooks/`
* `librarian-chef update [cookbook]` will update the given cookbook. If no cookbook is passed, then it updates all cookbooks and dependencies.
* `.gitignore` should contain `cookbooks/` and `tmp/`

<sub>If a cookbook `foo` depends on cookbook `baz` and you want to pull `baz` from a Github repo, then specify it here. Otherwise, dependent cookbooks do not need to be mentioned in the Cheffile.</sub>

!SLIDE left

## Time for recipes. [apsoto/monit](https://github.com/apsoto/monit)
### apsoto::default

<figure>
```ruby
package "monit"

if platform?("ubuntu")
  cookbook_file "/etc/default/monit" do
    source "monit.default"
    owner "root"
    group "root"
    mode 0644
  end
end

service "monit" do
  action [:enable, :start]
  enabled true
  supports [:start, :restart, :stop]
end

directory "/etc/monit/conf.d/" do
  owner  'root'
  group 'root'
  mode 0755
  action :create
  recursive true
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :delayed
end
```
</figure>

!SLIDE left

## [apsoto/monit](https://github.com/apsoto/monit)
### `monit::postfix`

<figure>
```ruby
include_recipe "monit"

monitrc "postfix"
```
</figure>

### `definitions/monitrc`

<figure>
```ruby
# reload: Reload monit so it notices the new service.  :delayed (default) or :immediately.
# action: :enable To create the monitoring config (default), or :disable to remove it.
# variables: Hash of instance variables to pass to the ERB template
# template_cookbook: the cookbook in which the configuration resides
# template_source: filename of the ERB configuration template, defaults to <LWRP Name>.conf.erb

define :monitrc, :action => :enable, :reload => :delayed, :variables => {}, :template_cookbook => "monit", :template_source => nil do
  params[:template_source] ||= "#{params[:name]}.conf.erb"
  if params[:action] == :enable
    template "/etc/monit/conf.d/#{params[:name]}.conf" do
      owner "root"
      group "root"
      mode 0644

      source params[:template_source]
      cookbook params[:template_cookbook]
      variables params[:variables]

      notifies :restart, resources(:service => "monit"), params[:reload]
      action :create
    end
  else
    template "/etc/monit/conf.d/#{params[:name]}.conf" do
      action :delete
      notifies :restart, resources(:service => "monit"), params[:reload]
    end
  end
end
```
</figure>

!SLIDE left

## Time for [ChefSpec](https://github.com/acrmp/chefspec)

* ChefSpec does NOT actually install anything or mess with files or do whatever your recipe is meant to do.
  * In Chef-speak, ChefSpec does not "converge a node"
  * Instead, it tracks intended actions and lets you assert against them.
* It can test against definitions that are built-in, including variations based on environment and platform.
  * `chef_run.should create_file_with_content 'hello-world.txt', 'hello world'`
  * `chef_run.should install_package_at_version 'foo', '1.2.3'`
  * more [on the ChefSpec repo](https://github.com/acrmp/chefspec#making-assertions) and on the next slides
* Run it just like you would any other RSpec test
  * `bundle exec rspec [file]` where `file` is optional

<sub>You can only access the chef_environment attribute with `node.chef_environment` and not `node[:chef_environment]` or `node["chef_environment"]`. This is because it's actually method and not a variable.</sub>

!SLIDE left

## This is the `spec_helper.rb` that I've created.

<figure>
```ruby
require 'chefspec'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

def runner(attributes = {}, environment = 'test')
  cookbook_paths = %W(#{File.expand_path('..', Dir.pwd)} #{File.expand_path(Dir.pwd)}/cookbooks)

  # A workaround so that ChefSpec can work with Chef environments (from https://github.com/acrmp/chefspec/issues/54)
  @runner ||= ChefSpec::ChefRunner.new(cookbook_path: cookbook_paths, platform: 'ubuntu', version: '10.04') do |node|
    env = Chef::Environment.new
    env.name environment
    node.stub(:chef_environment).and_return env.name
    Chef::Environment.stub(:load).and_return env

    attributes.each_pair do |key, val|
      node.set[key] = val
    end
  end
end
```
</figure>

!SLIDE left

## Let's look at them side by side. [lytro/aws_developer_tools](https://github.com/Lytro/aws_developer_tools)

### `recipes/default.rb`

<figure>
```ruby
include_recipe 'aws_developer_tools::ami'
include_recipe 'aws_developer_tools::api'
include_recipe 'aws_developer_tools::auto_scaling'
include_recipe 'aws_developer_tools::cloudwatch'
```
</figure>

### `spec/default_spec.rb`

<figure>
```ruby
require 'spec_helper'

describe 'aws_developer_tools::default' do
  let(:chef_run) { runner.converge 'aws_developer_tools::default' }

  %w(ami api auto_scaling cloudwatch).each do |recipe|
    it "includes the #{recipe} recipe" do
      expect(chef_run).to include_recipe "aws_developer_tools::#{recipe}"
    end
  end
end
```
</figure>

!SLIDE left

### `recipes/api.rb`

<figure>
```ruby
cli_tools 'api' do
  source node['aws_developer_tools']['api']['source']
end

include_recipe 'java' do
  only_if { node['aws_developer_tools']['install_java?'] }
end

template '/etc/profile.d/aws_keys.sh' do
  source 'aws_keys.sh.erb'
  owner 'root'
  group 'root'
  mode 0755
  only_if { node['aws_developer_tools']['deploy_key?'] }
end
```
</figure>

### `spec/api_spec.rb`

<figure>
```ruby
require 'spec_helper'

describe 'aws_developer_tools::api' do
  let(:chef_run) { runner.converge 'aws_developer_tools::api' }

  it_behaves_like 'cli tools', 'api'
  it_behaves_like 'ec2 tools'

  it 'installs java' do
    expect(chef_run).to include_recipe 'java'
  end

  it 'exports the AWS_ACCESS_KEY and AWS_SECRET_KEY' do
    expect(chef_run).to create_file_with_content '/etc/profile.d/aws_keys.sh',
                                                 'export AWS_ACCESS_KEY=Your Access Key'
    expect(chef_run).to create_file_with_content '/etc/profile.d/aws_keys.sh',
                                                 'export AWS_SECRET_KEY=Your Secret Key'

    expect(chef_run.template('/etc/profile.d/aws_keys.sh')).to be_owned_by('root', 'root')
  end
end
```
</figure>

!SLIDE left

### `definitions/cli_tools.rb`

<figure>
```ruby
define :cli_tools, :extension => '.zip' do
  require 'fileutils'

  package 'unzip'

  remote_file "/tmp/#{params[:name] + params[:extension]}" do
    source params[:source]
  end

  execute 'cleanup old installs and extract the aws tool' do
    cwd '/tmp'
    command "rm -rf #{params[:name]} && mkdir #{params[:name]} && mv #{params[:name] + params[:extension]} #{params[:name]}/ && cd #{params[:name]} && unzip -o ./#{params[:name] + params[:extension]}"
  end

  ruby_block 'copy the tools to the target directory' do
    block do
      FileUtils.cd("/tmp/#{params[:name]}") do
        source = Dir['*'].detect { |file| File.directory? file }
        target = node['aws_developer_tools'][params[:name]]['install_target']

        Chef::Log.info "Checking for tools in #{source}"

        if source
          FileUtils.mkdir_p target

          FileUtils.cd(source) do
            Chef::Log.info "Attempting to copy files from #{FileUtils.pwd}"

            FileUtils.cp_r('.', target)
          end
        end
      end
    end
  end

  if AwsDeveloperTools.type?(params[:name]) == :ec2
    template '/etc/profile.d/ec2_tools.sh' do
      mode 0755
    end
  else
    template "#{node['aws_developer_tools']['aws_tools_target']}/credentials" do
      mode 0444
    end

    template "/etc/profile.d/#{params[:name]}.sh" do
      mode 0755
    end

    template '/etc/profile.d/aws_tools.sh' do
      mode 0755
    end
  end
end
```
</figure>

### `spec/support/ec2_cli_tools.rb`

<figure>
```ruby
shared_examples_for 'cli tools' do |tool_name|
  it 'installs unzip' do
    expect(chef_run).to install_package 'unzip'
  end

  it 'downloads the tools' do
    expect(chef_run).to create_remote_file "/tmp/#{tool_name}.zip"
  end

  it 'extracts the tools' do
    expect(chef_run).to execute_ruby_block 'copy the tools to the target directory'
  end
end
```
</figure>

!SLIDE left

# That's it for now.
## I know these tools are a little rough around the edges, but I think they have a good foundation and a lot of potential.

If you find something wrong or lacking with ChefSpec, fix/add it! The same should be true of any cookbook you work with, or Chef itself.

Happy cooking.
abiyani@lytro.com
https://github.com/Lytro/teaching_chef_cookbooks
https://github.com/anujbiyani/
