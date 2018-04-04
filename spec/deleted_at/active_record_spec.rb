require "spec_helper"

describe DeletedAt::ActiveRecord do

  it 'should let other missing consts through' do
    expect{ Admin::Blarg }.to raise_error(NameError)
  end

end
