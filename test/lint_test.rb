require "test_helper"
require "open3"

class LintTest < ActiveSupport::TestCase
  it "has no RuboCop offenses" do
    output, status = Open3.capture2e("bin/rubocop", "--format", "simple")
    assert status.success?, output
  end

  it "has no Brakeman warnings" do
    output, status = Open3.capture2e("bin/brakeman", "--quiet", "--no-pager", "--exit-on-warn")
    assert status.success?, output
  end
end
