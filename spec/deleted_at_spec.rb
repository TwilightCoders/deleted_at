require "spec_helper"

describe DeletedAt do
  describe '#install for simple model' do
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

  describe '#uninstall for simple model' do
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

  describe '#install for model with customized table_name' do
    after(:each) do
      DeletedAt.uninstall(Book)
    end

    it 'should not raise error' do
      expect{ DeletedAt.install(Book) }.to_not raise_error()
    end

    it 'should rename the models table' do
      DeletedAt.install(Book)
      expect(ActiveRecord::Base.connection.table_exists?('documents/all')).to be_truthy
    end

    it 'should have a view for all non-deleted books' do
      DeletedAt.install(Book)
      expect(ActiveRecord::Base.connection.table_exists?('documents')).to be_truthy
    end

    it 'should have a view for all deleted books' do
      DeletedAt.install(Book)
      expect(ActiveRecord::Base.connection.table_exists?('documents/deleted')).to be_truthy
    end

    it 'creates the ALL class' do
      DeletedAt.install(Book)
      expect(Book.const_defined?(:All)).to be_truthy
      expect(Book.const_defined?(:Deleted)).to be_truthy
    end
  end

  describe '#uninstall for model with customized table_name' do
    before(:each) do
      DeletedAt.install(Book)
    end

    it 'should not raise error' do
      expect{ DeletedAt.uninstall(Book) }.to_not raise_error()
    end

    it 'should remove model extensions' do
      DeletedAt.uninstall(Book)
      expect(Book.const_defined?(:All)).to be_falsy
      expect(Book.const_defined?(:Deleted)).to be_falsy
    end
  end

end
