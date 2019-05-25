require "spec_helper"

describe DeletedAt::Core do

  context 'models with dependent: :destroy' do
    it 'should also destroy dependents' do
      user = User.create(name: 'bob')

      4.times do
        Post.create(user: user)
      end

      expect{user.destroy}.to_not raise_exception
    end
  end

  context "models using deleted_at" do

    it "#destroy should set deleted_at" do
      User.create(name: 'bob')
      User.create(name: 'john')
      User.create(name: 'sally')

      User.first.destroy

      expect(User.count).to eq(2)
      expect(User::All.count).to eq(3)
      expect(User::Deleted.count).to eq(1)
    end

    it "#delete! should set deleted_at" do
      User.create(name: 'bob')
      User.create(name: 'john')
      User.create(name: 'sally')

      User.first.delete!

      expect(User.count).to eq(2)
      expect(User::All.count).to eq(3)
      expect(User::Deleted.count).to eq(1)
    end

    it "#destroy! should set deleted_at" do
      User.create(name: 'bob')
      User.create(name: 'john')
      User.create(name: 'sally')

      User.first.destroy!

      expect(User.count).to eq(2)
      expect(User::All.count).to eq(3)
      expect(User::Deleted.count).to eq(1)
    end

    it "#delete should set deleted_at" do
      User.create(name: 'bob')
      User.create(name: 'john')
      User.create(name: 'sally')

      User.first.delete

      expect(User.count).to eq(2)
      expect(User::All.count).to eq(3)
      expect(User::Deleted.count).to eq(1)
    end

    it "#destroy twice should set deleted_at and not fail" do
      User.create(name: 'bob')
      User.create(name: 'john')
      User.create(name: 'sally')

      u = User.first
      u.destroy!
      u.destroy!

      expect(User.count).to eq(2)
      expect(User::All.count).to eq(3)
      expect(User::Deleted.count).to eq(1)
    end

    context '#destroy_all' do
      it "should set deleted_at" do
        User.create(name: 'bob')
        User.create(name: 'john')
        User.create(name: 'sally')

        User.all.destroy_all

        expect(User.count).to eq(0)
        expect(User::All.count).to eq(3)
        expect(User::Deleted.count).to eq(3)
      end

      it "with conditions should set deleted_at" do
        User.create(name: 'bob')
        User.create(name: 'john')
        User.create(name: 'sally')

        User.where(name: 'bob').destroy_all


        expect(User.count).to eq(2)
        expect(User::All.count).to eq(3)
        expect(User::Deleted.count).to eq(1)
      end
    end

    context '#delete_all' do
      it "should set deleted_at" do
        User.create(name: 'bob')
        User.create(name: 'john')
        User.create(name: 'sally')

        # conditions should not matter
        User.all.delete_all(name: 'bob')

        expect(User.count).to eq(0)
        expect(User::All.count).to eq(3)
        expect(User::Deleted.count).to eq(3)
      end

      it "with conditions should set deleted_at" do
        User.create(name: 'bob')
        User.create(name: 'john')
        User.create(name: 'sally')

        User.where(name: 'bob').delete_all

        expect(User.count).to eq(2)
        expect(User::All.count).to eq(3)
        expect(User::Deleted.count).to eq(1)
      end
    end

  end

  context "models not using deleted_at" do

    it "#destroy should actually delete the record" do
      Comment.create(title: 'Agree')
      Comment.create(title: 'Disagree')
      Comment.create(title: 'Defer')

      Comment.first.destroy

      expect(Comment.count).to eq(2)
    end

    it "#delete should actually delete the record" do
      Comment.create(title: 'Agree')
      Comment.create(title: 'Disagree')
      Comment.create(title: 'Defer')

      Comment.first.delete

      expect(Comment.count).to eq(2)
    end

    context '#destroy_all' do
      it "should actually delete records" do
        Comment.create(title: 'Agree')
        Comment.create(title: 'Disagree')
        Comment.create(title: 'Defer')

        Comment.all.destroy_all

        expect(Comment.count).to eq(0)
      end

      it "with conditions should actually delete records" do
        Comment.create(title: 'Agree')
        Comment.create(title: 'Disagree')
        Comment.create(title: 'Defer')

        Comment.where(title: 'Disagree').destroy_all

        expect(Comment.count).to eq(2)
      end
    end

    context '#delete_all' do
      it "should actually delete records" do
        Comment.create(title: 'Agree')
        Comment.create(title: 'Disagree')
        Comment.create(title: 'Defer')

        Comment.all.delete_all

        expect(Comment.count).to eq(0)
      end

      it "with conditions should actually delete records" do
        Comment.create(title: 'Agree')
        Comment.create(title: 'Disagree')
        Comment.create(title: 'Defer')

        Comment.where(title: 'Agree').delete_all

        expect(Comment.count).to eq(2)
      end
    end

  end

end
