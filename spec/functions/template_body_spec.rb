require 'spec_helper'

describe 'template_body' do
  it "should raise an error when called with a template that cannot be found" do
    expect { subject.call(['template_body/really_should_never_exist.erb']) }.to raise_error(Puppet::ParseError)
  end

  it "should return the body of template_body/test1.erb" do
    subject.call(['template_body/test1.erb']) == "Goodbye cruel world\n"
  end
end
