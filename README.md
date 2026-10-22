# Equalish

Comparison operators for floats that are *almost* equal.

## The problem this solves

Smooths out rounding errors and floating point precision issues.

```elixir
    iex> 0.1 + 0.2 
    0.30000000000000004
    iex> 0.1 + 0.2 == 0.3
    false
    iex> import Equalish
    iex> is_eq_ish(0.1 + 0.2, 0.3)
    true
```

## Guards

```elixir
import Equalish

# As a macro
assert is_eq_ish(0.5, 0.50000001)

# As a guard
def foo(a, b) when is_eq_ish(a, b) do
  ...
end
```

All 6 of the usual comparison operators are present:

* `is_eq_ish`: roughly `==`
* `is_not_eq_ish`: NOT roughly `==`
* `is_gt_ish`: `>` but must be enough of a difference to NOT be roughly equal.
* `is_gte_ish`: roughly `==` OR `>`
* `is_lt_ish`: `<` but must be enough of a difference to NOT be roughly equal.
* `is_lte_ish`: roughly `==` OR `<`

```elixir
assert is_gt_ish(0.5, 0.2)
refute is_gt_ish(0.5, 0.49999999999999)
```

There is also `is_zero_ish`, for the common "is this basically zero?" check:

```elixir
assert is_zero_ish(0.1 + 0.2 - 0.3)
```

## Very large or very small numbers

`is_close` allows a difference that grows with the size of the numbers (like Python's
`math.isclose`), so it works at any scale:

```elixir
is_close(1.0e12 + 0.1 + 0.2, 1.0e12 + 0.3) #=> true  (is_eq_ish says false)
is_close(1.0e-9, 9.0e-6)                   #=> false (is_eq_ish says true)
is_close(100.0, 101.0, 0.01)               #=> true  (within 1%)
```

By default it allows a difference of `1.0e-9` times the larger number. A percentage of zero is
zero, so use `is_zero_ish`, or pass an absolute tolerance as the 4th argument, when comparing
to zero.

## Test assertions

`Equalish.Assertions` gives clearer failure messages than `assert is_eq_ish(...)`:

```elixir
import Equalish.Assertions

assert_eq_ish(0.1 + 0.2, 0.31)
# Expected numbers to be equal-ish
# difference: 0.009999999999999953
# tolerance:  1.0e-5
# code:  assert_eq_ish(0.1 + 0.2, 0.31)
# left:  0.30000000000000004
# right: 0.31

refute_eq_ish(0.1 + 0.2, 0.4)
```

## Tolerance

You can pass in a custom tolerance threshold, or add it to your config:

```elixir
config :equalish, tolerance: 0.00001
```

The config value is read at **compile time** (guards cannot read config at runtime), so set it in
`config/config.exs` rather than `config/runtime.exs`. A different value in `runtime.exs` is ignored
by `mix run`, and makes a release fail to boot.

The tolerance is a fixed amount, not a percentage, so it suits numbers of everyday size best.
For very large numbers (e.g. `1.0e12`) rounding errors can exceed it, and for very small numbers
(e.g. `1.0e-9`) it can hide real differences. Use `is_close` for those.

## Installation

This package can be installed by adding `equalish` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:equalish, "~> 1.1"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/equalish>, and the list of changes in
[CHANGELOG.md](CHANGELOG.md).
