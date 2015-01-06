defmodule Transpose do

  def init([h|t]) do
    combine(h,t)
  end
  def combine([], [h|t] = _next) do 
    log(1, [], h, t)
    combine(h, t)
  end
  def combine([], []) do 
    log(2, [], [], [])
    []
  end
  def combine([head|tail], next) when is_list head do
    log(3, head, tail, next)
    if length(List.flatten head) > length(List.flatten next) do
      combine(head, combine(tail, next))
    else
      combine(head, combine(next, tail))
    end
  end
  def combine([head|tail], next) do 
    log(4, head, tail, next)
    [head | combine(next, tail)]
  end
  def combine(head, []) do 
    log(5, head, "", [])
    head
  end
  def combine(head, [tail]) do 
    log(6, head, [], tail)
    [head, tail]
  end
  def combine(head, tail) do
    log(7, head, [], tail)
    combine(head, [tail])
  end
  defp log(f, h, t, n) do
    IO.puts "#{f}:"
    IO.puts "head = #{inspect h}"
    IO.puts "tail = #{inspect t}"
    IO.puts "next = #{inspect n}"
  end
end
