defmodule DiscourseTest do
  use ExUnit.Case
  doctest Discourse

  test "greets the world" do
    assert Discourse.hello() == :world
  end
end
