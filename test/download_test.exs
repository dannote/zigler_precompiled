defmodule ZiglerPrecompiled.DownloadTest do
  use ExUnit.Case

  describe "download_nif_artifacts_with_checksums!/2" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "downloads and checksums artifacts", %{bypass: bypass} do
      body = "fake nif content"

      Bypass.expect(bypass, "GET", "/my_nif.so.tar.gz", fn conn ->
        Plug.Conn.resp(conn, 200, body)
      end)

      url = "http://localhost:#{bypass.port}/my_nif.so.tar.gz"
      nifs = [{"my_nif.so.tar.gz", {url, []}}]

      [result] = ZiglerPrecompiled.download_nif_artifacts_with_checksums!(nifs)

      assert result.checksum_algo == :sha256
      assert String.starts_with?(result.checksum, "sha256:")
      assert File.exists?(result.path)

      expected_hash =
        :crypto.hash(:sha256, body) |> Base.encode16(case: :lower)

      assert result.checksum == "sha256:#{expected_hash}"
    end

    test "raises on failure without ignore flag", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/missing.so.tar.gz", fn conn ->
        Plug.Conn.resp(conn, 404, "not found")
      end)

      url = "http://localhost:#{bypass.port}/missing.so.tar.gz"
      nifs = [{"missing.so.tar.gz", {url, []}}]

      assert_raise RuntimeError, ~r/failed to download/, fn ->
        ZiglerPrecompiled.download_nif_artifacts_with_checksums!(nifs)
      end
    end

    test "skips unavailable with ignore flag", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/missing.so.tar.gz", fn conn ->
        Plug.Conn.resp(conn, 404, "not found")
      end)

      url = "http://localhost:#{bypass.port}/missing.so.tar.gz"
      nifs = [{"missing.so.tar.gz", {url, []}}]

      assert [] ==
               ZiglerPrecompiled.download_nif_artifacts_with_checksums!(nifs,
                 ignore_unavailable: true
               )
    end
  end
end
