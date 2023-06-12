# Calculating the sum of all prime numbers until 5 million
# Using sequuential programming (one process)
# And parallel programming (several processes)
#
# Rodrigo Nunez Magallanes, A01028310
# Andrea Alexandra Barrón Córdova, A01783126
# 2023-06-09

defmodule Hw.Primes do
  # 1. sum of prime numbers to the limit using sequential programming
  def sum_primes(limit), do: do_sum_primes(2, limit, 0)

  defp do_sum_primes(i, limit, sum) when i > limit, do: sum
  # couldnt do proper pattern matching because Elixir did not let me
  # use the is_prime function in the "when" guard
  defp do_sum_primes(i, limit, sum) do
    if is_prime(i) do
      do_sum_primes(i + 1, limit, sum + i)
    else
      do_sum_primes(i + 1, limit, sum)
    end
  end

  # 2. sum of prime numbers to the limit using parallel programming
  def sum_primes_parallel(limit, threads) do
    interval = div(limit, threads)
    create_tuples(interval, threads)
    |> Enum.map(&Task.async(fn -> sum_primes_range(&1) end))
    |> IO.inspect()
    # given more timeout than 5 seconds to each of them, because it was breaking
    |> Enum.map(&Task.await(&1, 20000))
    |> IO.inspect()
    |> Enum.sum()
  end

  # helper function to check if a number is prime
  def is_prime(number) do
    if number < 2 do
      false
    else
      do_is_prime(number, 2, :math.sqrt(number))
    end
  end

  defp do_is_prime(n, i, limit) do
    if i > limit do
      true
    else
      if rem(n, i) == 0 do
        false
      else
        do_is_prime(n, i + 1, limit)
      end
    end
  end

  # helper func to calculate the sum of prime numbers in a range
  defp sum_primes_range({start, finish}), do: do_sum_primes(start, finish, 0)

  # helper function to create the tuples so each thread can use them
  defp create_tuples(interval, threads), do: do_create_tuples(interval, 0, threads, [])
  defp do_create_tuples(_interval, _current, amount, res) when length(res) == amount, do: Enum.reverse(res)
  # handle the starting case because it has to start from 0
  defp do_create_tuples(interval, 0, amount, res), do:  do_create_tuples(interval, interval + 1, amount, [{0, interval} | res])
  defp do_create_tuples(interval, current, amount, res), do:  do_create_tuples(interval, current + interval, amount, [{current, current + interval - 1} | res])
end
