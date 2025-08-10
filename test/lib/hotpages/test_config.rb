require "test_helper"

class TestConfig < Minitest::Test
  Config = Hotpages::Config

  def setup
    @defaults = {
      foo: "foo",
      hash_value: { key: "value" },
      nested: Config.new(
        bar: "bar"
      )
    }
    @config = Hotpages::Config.new(@defaults)
  end

  def test_singleton_methods
    assert_respond_to @config, :foo
    assert_equal "foo", @config.foo
    assert_respond_to @config, :foo=
    @config.foo = "bar"
    assert_equal "bar", @config.foo

    assert_equal({ key: "value" }, @config.hash_value)

    assert_respond_to @config, :nested
    assert_equal "bar", @config.nested.bar
    @config.nested.bar = "baz"
    assert_equal "baz", @config.nested.bar
  end
end
