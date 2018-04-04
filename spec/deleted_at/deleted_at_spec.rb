require "spec_helper"

describe DeletedAt do

  after(:each) do
    DeletedAt.enable
  end

  it 'should enable' do
    DeletedAt.enable
    expect( DeletedAt.disabled? ).to eq(false)
  end

  it 'should disable' do
    DeletedAt.disable
    expect( DeletedAt.disabled? ).to eq(true)
  end

  it 'should warn when trying to use #install' do
    expect(DeletedAt.logger).to receive(:warn)
    DeletedAt.install(User)
  end

end
