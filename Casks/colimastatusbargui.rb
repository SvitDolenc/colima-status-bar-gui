cask "colimastatusbargui" do
  version "0.0.1"
  sha256 "938e98a5c0aa8527439fc447771173778e07c7f57d135fa59a54a0ce7e8e0954"

  url "https://github.com/SvitDolenc/colima-status-bar-gui/archive/refs/tags/0.0.1.zip"
  name "ColimaStatusBarGUI"
  desc "GUI for Colima"
  homepage "https://github.com/SvitDolenc/colima-status-bar-gui"

  depends_on macos: ">= :mojave"

  app "ColimaGUI.app"

  zap trash: "~/Library/Preferences/com.svitdolenc.ColimaGUI.plist"
end
