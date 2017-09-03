defmodule KV.Registry do
  @moduledoc """
  Registry of KV.Buckets
  """
  @typep name :: any
  use GenServer


  # Client API

  @spec start_link(any) :: {:ok, pid} | {:error, any}
  @doc "Starts the registry."
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, name, opts)
  end

  @spec stop(pid) :: :ok
  @doc "Stops the registry."
  def stop(server) do
    GenServer.stop(server)
  end

  @spec lookup(term, name) :: {:ok, pid} | :error
  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @spec create(pid, name) :: {:ok, pid} | :error
  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  # Server implementation

  def init(server_name) do
    buckets_by_name = :ets.new(server_name, [:named_table, read_concurrency: true])
    names_by_ref = %{}
    {:ok, {buckets_by_name, names_by_ref}}
  end

  @typep state :: {Ets.Tid, %{required(reference) => name}}
  @spec handle_call({atom, name}, {pid, any}, state) :: {:reply, pid, state}

  def handle_call({:create, name}, _from, {buckets_by_name, names_by_ref} = state) do
    case lookup(buckets_by_name, name) do
      {:ok, bucket} -> {:reply, bucket, state}
      :error ->
        {:ok, bucket} = KV.BucketSupervisor.start_bucket()
        ref = Process.monitor(bucket)
        names_by_ref = Map.put(names_by_ref, ref, name)
        :ets.insert(buckets_by_name, {name, bucket})
        {:reply, bucket, {buckets_by_name, names_by_ref}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {buckets_by_name, names_by_ref}) do
    {name, names_by_ref} = Map.pop(names_by_ref, ref)
    :ets.delete(buckets_by_name, name)
    {:noreply, {buckets_by_name, names_by_ref}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
