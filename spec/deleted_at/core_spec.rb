require "spec_helper"

describe DeletedAt::Core do

  context "model missing deleted_at column" do

    it "raises exception when using with_deleted_at" do
      expected_stderr = "Missing `deleted_at` in `Comment` when trying to employ `deleted_at`"
      allow(Comment).to receive(:has_deleted_at_views?).and_return(true)
      expect{ Comment.with_deleted_at }.to raise_exception(DeletedAt::MissingColumn)
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

  it 'works with complex eager loading' do
    bob = User.create(name: 'bob')
    (1..5).each do |i|
      post = Post.create(title: "Post #{i}", user: bob)
      (1..5).each do |j|
        comment = Comment.create(title: "Comment #{j}", post: post, user: bob)
      end
    end

    expect(User.eager_load(posts: :comments).find_by(name: 'bob')).to eq(bob)
  end

  context 'with default_scope' do
    it 'should have the default scope in the subquery' do
      Admin.create(name: 'bob', kind: 1)
      Admin.create(name: 'john', kind: 1)
      Admin.create(name: 'sally', kind: 0)

      Admin.first.destroy

      User.first

      # SELECT "users".* FROM (SELECT "users".* FROM "users" WHERE "users"."kind" = $1 AND "users"."deleted_at" IS NULL) "users" WHERE "users"."kind" = 1
      expect(Admin::Deleted.first.class).to eq(Admin)
    end
  end

end
