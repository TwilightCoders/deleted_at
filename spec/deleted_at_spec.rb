require "spec_helper"

describe DeletedAt do

  def view_exists?(view_name)
    ActiveRecord::Base.connection.select_value <<-SQL
      SELECT EXISTS (
        SELECT 1
        FROM   information_schema.tables
        WHERE  table_name = '#{view_name}'
      ) as exists;
    SQL
  end

  describe '#install for simple model' do
    after(:each) do
      DeletedAt.uninstall(User)
    end

    it 'should not raise error' do
      expect{ DeletedAt.install(User) }.to_not raise_error()
    end

    it 'should rename the models table' do
      DeletedAt.install(User)
      ::DeletedAt::Views.all_table_exists?(User)
      expect(ActiveRecord::Base.connection.table_exists?('users/all')).to be_truthy
    end

    it 'should have a view for all non-deleted users' do
      DeletedAt.install(User)
      expect(view_exists?('users')).to be_truthy
    end

    it 'should have a view for all deleted users' do
      DeletedAt.install(User)
      expect(view_exists?('users/deleted')).to be_truthy
    end

    it 'creates the DeletedAt class extensions' do
      DeletedAt.install(User)
      expect(User.const_defined?(:All)).to be_truthy
      expect(User.const_defined?(:Deleted)).to be_truthy
    end

    it 'sets the correct table name for modified class' do
      DeletedAt.install(User)
      expect(User.table_name).to eql('users')
      expect(User::All.table_name).to eql('users/all')
      expect(User::Deleted.table_name).to eql('users/deleted')
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
      expect(view_exists?('documents')).to be_truthy
    end

    it 'should have a view for all deleted books' do
      DeletedAt.install(Book)
      expect(view_exists?('documents/deleted')).to be_truthy
    end

    it 'creates the DeletedAt class extensions' do
      DeletedAt.install(Book)
      expect(Book.const_defined?(:All)).to be_truthy
      expect(Book.const_defined?(:Deleted)).to be_truthy
    end

    it 'sets the correct table name for modified class' do
      DeletedAt.install(Book)
      expect(Book.table_name).to eql('documents')
      expect(Book::All.table_name).to eql('documents/all')
      expect(Book::Deleted.table_name).to eql('documents/deleted')
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

describe '#install for namespaced model' do
    after(:each) do
      DeletedAt.uninstall(Animals::Dog)
    end

    it 'should not raise error' do
      expect{ DeletedAt.install(Animals::Dog) }.to_not raise_error()
    end

    it 'should rename the models table' do
      DeletedAt.install(Animals::Dog)
      expect(ActiveRecord::Base.connection.table_exists?('dogs/all')).to be_truthy
    end

    it 'should have a view for all non-deleted books' do
      DeletedAt.install(Animals::Dog)
      expect(view_exists?('dogs')).to be_truthy
    end

    it 'should have a view for all deleted books' do
      DeletedAt.install(Animals::Dog)
      expect(view_exists?('dogs/deleted')).to be_truthy
    end

    it 'creates the DeletedAt class extensions' do
      DeletedAt.install(Animals::Dog)
      expect(Animals::Dog.const_defined?(:All)).to be_truthy
      expect(Animals::Dog.const_defined?(:Deleted)).to be_truthy
    end

    it 'sets the correct table name for modified class' do
      DeletedAt.install(Animals::Dog)
      expect(Animals::Dog.table_name).to eql('dogs')
      expect(Animals::Dog::All.table_name).to eql('dogs/all')
      expect(Animals::Dog::Deleted.table_name).to eql('dogs/deleted')
    end
  end

  describe '#uninstall for namespaced model' do
    before(:each) do
      DeletedAt.install(Animals::Dog)
    end

    it 'should not raise error' do
      expect{ DeletedAt.uninstall(Animals::Dog) }.to_not raise_error()
    end

    it 'should remove model extensions' do
      DeletedAt.uninstall(Animals::Dog)
      expect(Animals::Dog.const_defined?(:All)).to be_falsy
      expect(Animals::Dog.const_defined?(:Deleted)).to be_falsy
    end
  end

end
