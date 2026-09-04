defmodule EqualishTest do
  use ExUnit.Case
  import Equalish
  @lax 0.1
  @strict 0.000000000000001
  doctest Equalish

  def foo(a, b) when is_eq_ish(a, b, @lax) do
    true
  end
  def foo(_, _), do: false

  describe "Guards" do
    test "eq should be a valid guard" do
      foo(0.1, 0.1000001)
    end
  end

  describe "Determine when two floats are almost equal" do
    test "Respect tolerance level" do
      a = 0.1234
      b = 0.1235
      assert is_eq_ish(a, b, @lax)
      refute is_eq_ish(a, b, @strict)
    end
  end


end
