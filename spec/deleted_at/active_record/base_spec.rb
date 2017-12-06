require "spec_helper"

describe DeletedAt::ActiveRecord::Base do

  context "model missing deleted_at column" do

    it "fails when trying to install" do
      expect(DeletedAt.install(Comment)).to eq(false)
      expect(DeletedAt.uninstall(Comment)).to eq(false)
    end

    it "warns when using with_deleted_at" do
      expected_stderr = "Missing `deleted_at` in `Comment` when trying to employ `deleted_at`"
      allow(Comment).to receive(:has_deleted_at_views?).and_return(true)
      expect(DeletedAt.logger).to receive(:warn).with(expected_stderr)
      Comment.with_deleted_at
    end

  end

end
