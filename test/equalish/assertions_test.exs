defmodule Equalish.AssertionsTest do
  use ExUnit.Case, async: true
  import Equalish.Assertions
  doctest Equalish.Assertions

  # Runs a failing assertion and returns the error it raised.
  defmacrop failure(assertion) do
    quote do
      assert_raise ExUnit.AssertionError, fn -> unquote(assertion) end
    end
  end

  describe "assert_eq_ish" do
    test "passes and returns true for equal-ish numbers" do
      assert assert_eq_ish(1, 1.000001) == true
      assert assert_eq_ish(0.5, 0.55, 0.1) == true
    end

    test "fails with the values, difference, tolerance and code" do
      error = failure(assert_eq_ish(0.1 + 0.2, 0.31))

      assert error.left == 0.30000000000000004
      assert error.right == 0.31
      assert error.message =~ "Expected numbers to be equal-ish"
      assert error.message =~ "difference: 0.0099999999999999"
      assert error.message =~ "tolerance:  1.0e-5"
      assert Macro.to_string(error.expr) == "assert_eq_ish(0.1 + 0.2, 0.31)"
    end

    test "uses a custom tolerance" do
      error = failure(assert_eq_ish(1, 2, 0.5))
      assert error.message =~ "tolerance:  0.5"
    end

    test "fails on non-numbers instead of raising ArithmeticError" do
      error = failure(assert_eq_ish("1", 1))
      assert error.message =~ ~s(Expected numbers, got: "1", 1)
    end

    test "evaluates each argument only once" do
      assert_eq_ish(
        (
          send(self(), :left)
          1
        ),
        (
          send(self(), :right)
          1
        )
      )

      assert_received :left
      assert_received :right
      refute_received _
    end
  end

  describe "numbers too far apart to subtract" do
    test "assert_eq_ish fails cleanly" do
      error = failure(assert_eq_ish(1.7e308, -1.7e308))
      assert error.message =~ "difference: too large to represent"
    end

    test "assert_eq_ish fails cleanly for huge integers mixed with floats" do
      error = failure(assert_eq_ish(10 ** 400, 1.0))
      assert error.message =~ "difference: too large to represent"
    end

    test "refute_eq_ish passes" do
      assert refute_eq_ish(1.7e308, -1.7e308)
      assert refute_eq_ish(10 ** 400, 1.0)
    end
  end

  describe "refute_eq_ish" do
    test "passes and returns true for numbers that are not equal-ish" do
      assert refute_eq_ish(1, 2) == true
    end

    test "fails for equal-ish numbers" do
      error = failure(refute_eq_ish(0.1 + 0.2, 0.3))
      assert error.message =~ "Expected numbers NOT to be equal-ish"
      assert Macro.to_string(error.expr) == "refute_eq_ish(0.1 + 0.2, 0.3)"
    end

    test "fails on non-numbers" do
      error = failure(refute_eq_ish(nil, 1))
      assert error.message =~ "Expected numbers"
    end
  end
end
