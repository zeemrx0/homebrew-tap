class AgentSwitch < Formula
  desc "Switch Claude, ChatGPT and Antigravity accounts per surface"
  homepage "https://github.com/ZeeMRx0/agent-switch"
  url "https://github.com/ZeeMRx0/agent-switch/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "bd50ac167482313c39599f8cdad701f67aee824aaad2781b86ba88aa6dbec65a"
  license "MIT"

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cli")

    # The menu bar app, signed ad hoc: no certificate needed.
    ENV["CARGO_TARGET_DIR"] = buildpath/"target"
    system "scripts/bundle-app.sh"
    prefix.install "target/bundle/AgentSwitch.app"
  end

  def caveats
    <<~EOS
      Put the menu bar app in ~/Applications, then open it:
        mkdir -p ~/Applications
        ln -sfn #{opt_prefix}/AgentSwitch.app ~/Applications/AgentSwitch.app
        open ~/Applications/AgentSwitch.app

      Quit the app from its menu before `brew upgrade agent-switch`.
    EOS
  end

  test do
    assert_match "agent-switch", shell_output("#{bin}/agent-switch --help")
    assert_path_exists prefix/"AgentSwitch.app/Contents/MacOS/agent-switch-menubar"
  end
end
