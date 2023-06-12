# Actividad 5.2 Programación paralela y concurrente

Andrea Alexandra Barrón Córdova, A01783126

Rodrigo Núñez Magallanes, A01028310

2023-06-09

## Tiempos de ejecución

### 1. Secuencial: 28.23s

```elixir
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
```

### 2. Paralelo: se corrieron tres distintas pruebas, con 2, 4 y 8 threads respectivamente. Los resultados fueron los siguientes:

### - 2 threads (número de núcleos de la computadora en cuestión): 22.16s

### - 4 threads: 18.03s

### - 8 threads: 12.73s

Esta versión toma el límite y el número de threads a utilizar. Con base en esto, crea una lista de tuplas con determinado intervalo para que cada proceso calcule la suma de primos en ese intervalo. Después, se suman los resultados. IMPORTANTE: la división del límite entre el número de threads debe ser exacta, de lo contrario, el resultado no será correcto.

```elixir
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
```

### Speedup

Reemplazando los datos en la fórmula: $S_p = T_1 / T_p$
se obtiene el _Speed up_ para cada uno de los casos:

-  2 threads: 28.23s / 22.16s = 1.27s
-  4 threads: 28.23s / 18.03s = 1.56s
-  8 threads: 28.23s / 12.73s = 2.21s

Como se observa, a mayor número de hilos fue menor el tiempo de ejecución. No obstante, si se excede el número de hilos puede ser incluso contraproducente, ya que esto depende de los recursos del sistema.
