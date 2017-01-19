defmodule DfParseTest do
  use ExUnit.Case
  doctest DfParse

  @linux_example """
  Filesystem     1K-blocks     Used Available Use% Mounted on
  udev             1015032        0   1015032   0% /dev
  tmpfs             204828    21164    183664  11% /run
  /dev/vda1       40593708 19123904  21453420  48% /
  tmpfs            1024136        0   1024136   0% /dev/shm
  tmpfs               5120        0      5120   0% /run/lock
  tmpfs            1024136        0   1024136   0% /sys/fs/cgroup
  tmpfs             204828        0    204828   0% /run/user/0
  """

  @darwin_example """
  Filesystem    512-blocks      Used Available Capacity  iused    ifree %iused  Mounted on
  /dev/disk1     487849984 380048360 107289624    78% 47570043 13411203   78%   /
  devfs                374       374         0   100%      648        0  100%   /dev
  map -hosts             0         0         0   100%        0        0  100%   /net
  map auto_home          0         0         0   100%        0        0  100%   /home
  """

  test "df_parser can parse linux" do
    result = DfParse.parse(@linux_example)
    assert length(result) == 7
    first = result |> hd
    assert first.filesystem == "udev"
    assert first.blocks_type == 1024
    assert first.blocks == 1015032
    assert first.used == 0
    assert first.available == 1015032
    assert first.percent_capacity == 0
    assert first.percent_iused == 0
    assert first.mounted_on == "/dev"

  end

  test "df_parser can parse darwin" do
    result = DfParse.parse(@darwin_example)
    assert length(result) == 4
    first = result |> hd
    assert first.filesystem == "/dev/disk1"
    assert first.blocks_type == 512
    assert first.blocks == 487849984
    assert first.used == 380048360
    assert first.available == 107289624
    assert first.percent_capacity == 78
    assert first.percent_iused == 78
    assert first.mounted_on == "/"
  end
end
