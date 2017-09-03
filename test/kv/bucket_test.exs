defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = start_supervised(KV.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "delete returns the current value if exists, or none", %{bucket: bucket} do
    assert KV.Bucket.delete(bucket, "foo") == nil

    KV.Bucket.put(bucket, "foo", 40)
    assert KV.Bucket.delete(bucket, "foo") == 40
    assert KV.Bucket.delete(bucket, "foo") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end