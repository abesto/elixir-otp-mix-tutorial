defmodule KV.Bucket do
  @moduledoc "Simple key-value storage"
  use Agent, restart: :temporary

  @spec start_link(any) :: {:ok, Pid} | {:error, any}
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @spec get(Pid, any) :: any
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @spec put(Pid, any, any) :: no_return
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @spec delete(Pid, any) :: any
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
