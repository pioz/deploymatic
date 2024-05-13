require 'test_helper'

class TestDeploymatic < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Deploymatic::VERSION
  end
end
