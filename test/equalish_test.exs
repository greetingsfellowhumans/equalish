defmodule EqualishTest do
  use ExUnit.Case
  use ExUnitProperties
  import Equalish
  @lax 0.1
  @strict 0.000000000000001
  doctest Equalish

  # Bounded so that `a - b` can never overflow.
  @bound 1.0e12

  def foo(a, b) when is_eq_ish(a, b, @lax), do: true
  def foo(_, _), do: false

  # Runs every comparison as a guard in a function head, returning the results as a map.
  defp guard_results(a, b, tol) do
    %{
      eq: guard_eq(a, b, tol),
      not_eq: guard_not_eq(a, b, tol),
      gt: guard_gt(a, b, tol),
      gte: guard_gte(a, b, tol),
      lt: guard_lt(a, b, tol),
      lte: guard_lte(a, b, tol),
      zero: guard_zero(a, tol),
      close: guard_close(a, b, tol, tol)
    }
  end

  # Same as guard_results/3, but calling the guards as ordinary expressions.
  defp expr_results(a, b, tol) do
    %{
      eq: is_eq_ish(a, b, tol),
      not_eq: is_not_eq_ish(a, b, tol),
      gt: is_gt_ish(a, b, tol),
      gte: is_gte_ish(a, b, tol),
      lt: is_lt_ish(a, b, tol),
      lte: is_lte_ish(a, b, tol),
      zero: is_zero_ish(a, tol),
      close: is_close(a, b, tol, tol)
    }
  end

  defp guard_eq(a, b, tol) when is_eq_ish(a, b, tol), do: true
  defp guard_eq(_, _, _), do: false
  defp guard_not_eq(a, b, tol) when is_not_eq_ish(a, b, tol), do: true
  defp guard_not_eq(_, _, _), do: false
  defp guard_gt(a, b, tol) when is_gt_ish(a, b, tol), do: true
  defp guard_gt(_, _, _), do: false
  defp guard_gte(a, b, tol) when is_gte_ish(a, b, tol), do: true
  defp guard_gte(_, _, _), do: false
  defp guard_lt(a, b, tol) when is_lt_ish(a, b, tol), do: true
  defp guard_lt(_, _, _), do: false
  defp guard_lte(a, b, tol) when is_lte_ish(a, b, tol), do: true
  defp guard_lte(_, _, _), do: false
  defp guard_zero(a, tol) when is_zero_ish(a, tol), do: true
  defp guard_zero(_, _), do: false
  defp guard_close(a, b, rel, abs) when is_close(a, b, rel, abs), do: true
  defp guard_close(_, _, _, _), do: false

  defp num, do: one_of([float(min: -@bound, max: @bound), integer()])
  defp tolerance, do: float(min: 0.0, max: 1.0)

  describe "Guards" do
    test "eq should be a valid guard" do
      assert foo(0.1, 0.1000001)
      refute foo(0.1, 0.5)
    end
  end

  describe "Determine when two floats are almost equal" do
    test "Respect tolerance level" do
      a = 0.1234
      b = 0.1235
      assert is_eq_ish(a, b, @lax)
      refute is_eq_ish(a, b, @strict)
    end

    test "a difference exactly equal to the tolerance counts as equal" do
      assert is_eq_ish(0, 1, 1)
      refute is_not_eq_ish(0, 1, 1)
      refute is_gt_ish(1, 0, 1)
      refute is_lt_ish(0, 1, 1)
    end

    test "negative numbers" do
      assert is_eq_ish(-0.5, -0.50000001)
      assert is_lt_ish(-0.6, -0.5)
      assert is_gt_ish(-0.5, -0.6)
      refute is_eq_ish(-0.5, 0.5)
    end

    test "mixed integers and floats" do
      assert is_eq_ish(1, 1.000001)
      assert is_gt_ish(2, 1.5)
      assert is_lte_ish(1.0, 1)
    end

    test "default tolerance boundaries" do
      assert is_eq_ish(1.0, 1.0 + 0.9e-5)
      refute is_eq_ish(1.0, 1.0 + 1.1e-5)
    end

    test "the README example" do
      assert is_eq_ish(0.1 + 0.2, 0.3)
    end
  end

  describe "is_zero_ish" do
    test "uses the default tolerance" do
      assert is_zero_ish(0)
      assert is_zero_ish(-0.0)
      assert is_zero_ish(0.9e-5)
      refute is_zero_ish(1.1e-5)
    end

    test "a value exactly at the tolerance counts as zero" do
      assert is_zero_ish(-1, 1)
      refute is_zero_ish(2, 1)
    end
  end

  describe "is_close" do
    test "scales with the size of the numbers" do
      assert is_close(1.0e20, 1.0e20 * (1 + 1.0e-12))
      refute is_close(1.0e20, 1.0e20 * (1 + 1.0e-8))
      refute is_close(1.0e-9, 1.1e-9)
      assert is_close(1.0e-9, 1.0e-9 * (1 + 1.0e-12))
    end

    test "only an absolute tolerance helps near zero" do
      refute is_close(0.0, 1.0e-300)
      assert is_close(0.0, 0.0)
      assert is_close(0.0, 1.0e-300, 1.0e-9, 1.0e-12)
    end

    test "a difference exactly equal to either tolerance counts as close" do
      assert is_close(100, 110, 0.1)
      assert is_close(0, 5, 0, 5)
      refute is_close(100, 112, 0.1, 10)
    end

    test "integers and negative numbers" do
      assert is_close(-1_000_000_000_000, -1_000_000_000_001)
      refute is_close(-1.0, 1.0, 0.5)
    end
  end

  describe "Properties" do
    property "guards and expressions agree" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert guard_results(a, b, tol) == expr_results(a, b, tol)
      end
    end

    property "exactly one of eq / not_eq holds" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_eq_ish(a, b, tol) != is_not_eq_ish(a, b, tol)
      end
    end

    property "gt is the opposite of lte, and lt is the opposite of gte" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_gt_ish(a, b, tol) == not is_lte_ish(a, b, tol)
        assert is_lt_ish(a, b, tol) == not is_gte_ish(a, b, tol)
      end
    end

    property "swapping arguments" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_gt_ish(a, b, tol) == is_lt_ish(b, a, tol)
        assert is_gte_ish(a, b, tol) == is_lte_ish(b, a, tol)
        assert is_eq_ish(a, b, tol) == is_eq_ish(b, a, tol)
      end
    end

    property "every number is equalish to itself" do
      check all(a <- num(), tol <- tolerance()) do
        assert is_eq_ish(a, a, tol)
        refute is_gt_ish(a, a, tol)
        refute is_lt_ish(a, a, tol)
      end
    end

    property "numbers well within the tolerance are equalish" do
      check all(
              a <- float(min: -1.0e6, max: 1.0e6),
              tol <- float(min: 1.0e-6, max: 1.0),
              ratio <- float(min: -0.5, max: 0.5)
            ) do
        assert is_eq_ish(a, a + ratio * tol, tol)
      end
    end

    property "is_zero_ish is is_eq_ish against zero" do
      check all(a <- num(), tol <- tolerance()) do
        assert is_zero_ish(a, tol) == is_eq_ish(a, 0, tol)
      end
    end

    property "is_close is symmetric and every number is close to itself" do
      check all(a <- num(), b <- num(), rel <- tolerance(), abs <- tolerance()) do
        assert is_close(a, b, rel, abs) == is_close(b, a, rel, abs)
        assert is_close(a, a, rel, abs)
      end
    end

    property "is_close with only a relative tolerance ignores scale" do
      # Multiplying by a power of two is exact, so the answer must not change.
      check all(
              a <- filter(num(), &(abs(&1) > 1.0e-200)),
              b <- filter(num(), &(abs(&1) > 1.0e-200)),
              rel <- tolerance(),
              power <- integer(0..60)
            ) do
        scale = :math.pow(2, power)
        assert is_close(a, b, rel) == is_close(a * scale, b * scale, rel)
      end
    end

    property "is_close accepts anything is_eq_ish accepts, given the same absolute tolerance" do
      check all(a <- num(), b <- num(), rel <- tolerance(), tol <- tolerance()) do
        if is_eq_ish(a, b, tol), do: assert(is_close(a, b, rel, tol))
      end
    end
  end
end
