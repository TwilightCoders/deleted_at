require "spec_helper"

describe DeletedAt do
  describe '#install' do
    after(:each) do
      DeletedAt.uninstall(User)
    end

    it 'should not raise error' do
      expect{ DeletedAt.install(User) }.to_not raise_error()
    end

    it 'should rename the models table' do
      DeletedAt.install(User)
      expect(ActiveRecord::Base.connection.table_exists?('users/all')).to be_truthy
    end

    it 'should have a view for all non-deleted users' do
      DeletedAt.install(User)
      expect(ActiveRecord::Base.connection.table_exists?('users')).to be_truthy
    end

    it 'should have a view for all deleted users' do
      DeletedAt.install(User)
      expect(ActiveRecord::Base.connection.table_exists?('users/deleted')).to be_truthy
    end

    it 'creates the ALL class' do
      DeletedAt.install(User)
      expect(User.const_defined?(:All)).to be_truthy
      expect(User.const_defined?(:Deleted)).to be_truthy
    end
  end

  describe '#uninstall' do
    before(:each) do
      DeletedAt.install(User)
    end

    it 'should not raise error' do
      expect{ DeletedAt.uninstall(User) }.to_not raise_error()
    end

    it 'should remove model extensions' do
      DeletedAt.uninstall(User)
      expect(User.const_defined?(:All)).to be_falsy
      expect(User.const_defined?(:Deleted)).to be_falsy
    end
  end

end
