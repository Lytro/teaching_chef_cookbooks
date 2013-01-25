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

!SLIDE left

## My cookbooks have a couple of additions:

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
