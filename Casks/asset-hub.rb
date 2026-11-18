cask "asset-hub" do
  version "2.3.0"
  sha256 "ac9729b440f9a5691f5512fa7c0c6a9dda86f89aeffeb7c8606f179e6cc0a85a"

  url "https://github.com/SCVN-Zee/asset-hub/releases/download/v#{version}/Asset.Hub.app.tar.gz"
  name "Asset Hub"
  desc "Browse Unity projects on GitHub and export assets as .unitypackage"
  homepage "https://github.com/SCVN-Zee/asset-hub"

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Asset Hub.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Asset Hub.app"],
        writable_paths: ["Asset Hub.app"],
        writable_base:  :appdir,
        must_succeed:   false
  end

  uninstall quit: "vn.supercent.assethub"

  zap trash: [
    "~/Library/Application Support/vn.supercent.assethub",
    "~/Library/Caches/vn.supercent.assethub",
    "~/Library/Preferences/vn.supercent.assethub.plist",
    "~/Library/Saved Application State/vn.supercent.assethub.savedState",
    "~/Library/WebKit/vn.supercent.assethub",
  ]
end
