# presentation

!SLIDE left

# Test-driving Chef cookbooks
## Using ChefSpec and Librarian-Chef

abiyani@lytro.com
https://github.com/Lytro/teaching_chef_cookbooks

!SLIDE left

# What is Chef?

Chef treats infrastructure as code
* maintainable
* testable
* scalable
* a simple-ish DSL on top of Ruby

!SLIDE left

# So what's a cookbook?

Cookbooks are like libraries
* they contain code that accomplishes some specific goal, like installing Apache2 or Git.
* http://community.opscode.com/cookbooks

!SLIDE left

# Here's what's inside a stock cookbook:

```shell
  └── my_cookbook/
    ├── attributes/
    │   └── default.rb
    ├── definitions/
    ├── libraries/
    ├── providers/
    ├── recipes/
    │   └── default.rb
    ├── resources/
    ├── templates/
    ├── metadata.rb
    └── README.md
```

!SLIDE left

# My cookbooks have a couple of additions:

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

* Cheffile is a part of Librarian-Chef; it's very similar to a Gemfile
* specs are a part of ChefSpec (which is built on RSpec)

I have a template setup here: https://github.com/Lytro/chef_cookbook_template
