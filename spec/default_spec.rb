require 'spec_helper'

describe 'teaching_chef_cookbooks::default' do
  let(:chef_run) { runner.converge 'teaching_chef_cookbooks::default' }

  it "does something" do
    pending "I pity the fool who doesn't write specs!"
  end
end
