require "spec_helper"

describe DeletedAt::ActiveRecord::Base do

  context "model missing deleted_at column" do

    it "warns when using with_deleted_at" do
      expected_stderr = "Missing `deleted_at` in `Comment` when trying to employ `deleted_at`"
      allow(Comment).to receive(:has_deleted_at_views?).and_return(true)
      expect(DeletedAt.logger).to receive(:warn).with(expected_stderr)
      Comment.with_deleted_at
    end

  end

  it 'should not have ::All as part of the class' do
    User.create(name: 'bob')
    User.create(name: 'john')
    User.create(name: 'sally')

    expect(User::All.first.class).to eq(User)
  end

  it 'should not have ::Deleted as part of the class' do
    User.create(name: 'bob')
    User.create(name: 'john')
    User.create(name: 'sally')

    User.first.destroy

    expect(User::Deleted.first.class).to eq(User)
  end

end
