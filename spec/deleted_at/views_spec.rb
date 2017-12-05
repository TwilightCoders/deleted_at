require "spec_helper"

describe DeletedAt::Views do
  {
    User => "simple model",
    Post => "model with customized table_name",
    Animals::Dog => "namespaced model"
  }.each do |model, description|

    plural = model.name.pluralize
    table_name = model.table_name

    describe "#install for #{description}" do
      after(:each) do
        DeletedAt.uninstall(model)
      end

      it 'should not raise error' do
        expect{ DeletedAt.install(model) }.to_not raise_error()
      end

      it 'should rename the models table' do
        DeletedAt.install(model)
        expect(ActiveRecord::Base.connection.table_exists?("#{table_name}/all")).to be_truthy
      end

      it "should have a view for all non-deleted #{plural}" do
        DeletedAt.install(model)
        if Gem::Version.new(Rails.version) < Gem::Version.new("5.0")
          expect(ActiveRecord::Base.connection.table_exists?(table_name)).to be_truthy
        else
          expect(ActiveRecord::Base.connection.view_exists?(table_name)).to be_truthy
        end
      end

      it "should have a view for all deleted #{plural}" do
        DeletedAt.install(model)
        if Gem::Version.new(Rails.version) < Gem::Version.new("5.0")
          expect(ActiveRecord::Base.connection.table_exists?("#{table_name}/deleted")).to be_truthy
        else
          expect(ActiveRecord::Base.connection.view_exists?("#{table_name}/deleted")).to be_truthy
        end
      end

      it 'creates the DeletedAt class extensions' do
        DeletedAt.install(model)
        expect(model.const_defined?(:All)).to be_truthy
        expect(model.const_defined?(:Deleted)).to be_truthy
      end

      it 'sets the correct table name for modified class' do
        DeletedAt.install(model)
        expect(model.table_name).to eql(table_name)
        expect(model::All.table_name).to eql("#{table_name}/all")
        expect(model::Deleted.table_name).to eql("#{table_name}/deleted")
      end
    end

    describe "#uninstall for #{description}" do
      before(:each) do
        DeletedAt.install(model)
      end

      it 'should not raise error' do
        expect{ DeletedAt.uninstall(model) }.to_not raise_error()
      end

      it 'should remove model extensions' do
        DeletedAt.uninstall(model)
        expect(model.const_defined?(:All)).to be_falsy
        expect(model.const_defined?(:Deleted)).to be_falsy
      end
    end
  end

end
