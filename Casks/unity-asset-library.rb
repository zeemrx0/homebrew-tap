cask "unity-asset-library" do
  version "1.0.5"
  sha256 "6a53de3a9f0f00ee38d8ff0b2f35076f6717e4260394356cd72b887548133b60"

  url "https://github.com/zeemrx0/unity-asset-library/releases/download/v#{version}/unity-asset-library-#{version}-arm64.zip"
  name "Unity Asset Library"
  desc "Desktop library for browsing and importing Unity assets"
  homepage "https://github.com/zeemrx0/unity-asset-library"

  auto_updates true
  depends_on arch: :arm64
  depends_on :macos

  app "Unity Asset Library.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Unity Asset Library.app"],
        writable_paths: ["Unity Asset Library.app"],
        writable_base:  :appdir,
        must_succeed:   false
  end

  uninstall quit: "com.unityassetlibrary.viewer"

  zap trash: [
    "~/Library/Application Support/Unity Asset Index",
    "~/Library/Caches/com.unityassetlibrary.viewer",
    "~/Library/Preferences/com.unityassetlibrary.viewer.plist",
    "~/Library/Saved Application State/com.unityassetlibrary.viewer.savedState",
  ]
end
