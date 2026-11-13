cask "zak-desktop" do
  version "0.4.0"
  sha256 "c7f8efd1e933aaef6be256f49d1bff4f835e3ba9f8216b12d677dba3be98ed97"

  url "https://github.com/zeemrx0/zak-app/releases/download/v#{version}/zak-desktop-#{version}-arm64.zip"
  name "zAgentKit"
  desc "Desktop app for managing agent kit installs with the zak CLI"
  homepage "https://github.com/zeemrx0/zak-app"

  depends_on arch: :arm64
  depends_on :macos

  app "zAgentKit.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/zAgentKit.app"],
        writable_paths: ["zAgentKit.app"],
        writable_base:  :appdir,
        must_succeed:   false
  end

  uninstall quit: "dev.supercent.zak-desktop"

  zap trash: [
    "~/Library/Application Support/dev.supercent.zak-desktop",
    "~/Library/Caches/dev.supercent.zak-desktop",
    "~/Library/Preferences/dev.supercent.zak-desktop.plist",
    "~/Library/Saved Application State/dev.supercent.zak-desktop.savedState",
  ]
end
