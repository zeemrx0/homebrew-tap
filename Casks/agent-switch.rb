cask "agent-switch" do
  version "0.1.2"
  sha256 "e4aff4864fc84d05f4419abe72f6c9639a16944344ce4c1ec4f3c70a4dee924e"

  url "https://github.com/ZeeMRx0/agent-switch/archive/refs/tags/v#{version}.tar.gz"
  name "Agent Switch"
  desc "Switch Claude, ChatGPT and Antigravity accounts per surface"
  homepage "https://github.com/ZeeMRx0/agent-switch"

  depends_on formula: "rust"
  depends_on macos: :ventura

  app_path = "#{Dir.home}/Applications/Agent Switch.app"

  app "build/bundle/Agent Switch.app", target: "~/Applications/Agent Switch.app"
  # Install steps run in a sandbox that cannot reach Launch Services, so `open` cannot run there.
  # An installer script runs outside the sandbox, but before the app is moved into place.
  # It starts a detached helper that waits for the finished app, then opens it (it gives up after 60 seconds).
  installer script: {
    executable:   "/bin/sh",
    args:         [
      "-c",
      'app="$1"; ( n=0; ' \
      'while { [ ! -f "$app/Contents/_CodeSignature/CodeResources" ] || ' \
      '[ ! -f "$app/Contents/MacOS/agent-switch-menubar" ]; } && [ "$n" -lt 60 ]; ' \
      "do sleep 1; n=$((n + 1)); done; " \
      '[ -f "$app/Contents/MacOS/agent-switch-menubar" ] && sleep 1 && /usr/bin/open "$app" ) ' \
      ">/dev/null 2>&1 </dev/null &",
      "open-agent-switch",
      app_path,
    ],
    must_succeed: false,
  }
  binary "#{app_path}/Contents/MacOS/agent-switch"

  preflight_steps do
    # A signed script install keeps its logins in another vault. Stop before changing anything.
    if_path_exists ".local/bin/agent-switch-keychain", base: :home do
      run "/bin/sh",
          args: [
            "-c",
            'echo "A signed script install exists. It uses a different vault. ' \
            "Remove ~/.local/bin/agent-switch and ~/.local/bin/agent-switch-keychain " \
            'after saving your accounts, then run the command again." >&2; exit 1',
          ]
    end

    # The old Homebrew formula links the same command name. Stop before changing anything.
    run "/bin/sh",
        args: [
          "-c",
          'case "$(readlink "$1" 2>/dev/null)" in *Cellar/agent-switch/*) ' \
          'echo "The old agent-switch formula is installed. ' \
          'Run \`brew uninstall --formula agent-switch\`, then run this command again." >&2; exit 1;; esac',
          "check-formula",
          "{{HOMEBREW_PREFIX}}/bin/agent-switch",
        ]

    # Steps run in a sandbox that cannot send an Apple Event, so they cannot quit the old app.
    # Ask the user to quit it. An upgrade quits and reopens the new app through `uninstall quit:`.
    run "/bin/sh",
        args: [
          "-c",
          'if pgrep -f "[A]gentSwitch.app/Contents/MacOS/agent-switch-menubar" >/dev/null; then ' \
          'echo "The old AgentSwitch app is running. Quit it from its menu, ' \
          'then run the command again." >&2; exit 1; fi',
        ]

    # Homebrew runs these steps again from the old cask when it rolls back a failed upgrade. By then the
    # source folder is gone, so build and clean up only while it exists.
    if_path_exists "agent-switch-{{version}}/Cargo.toml", base: :staged_path do
      # Build the app and the CLI from source.
      run "/bin/bash",
          args:           ["scripts/bundle-app.sh"],
          chdir:          "{{staged_path}}/agent-switch-{{version}}",
          env:            {
            "PATH"             => "{{HOMEBREW_PREFIX}}/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "CARGO_HOME"       => "{{staged_path}}/cargo-home",
            "CARGO_TARGET_DIR" => "{{staged_path}}/build",
          },
          network_access: true

      # Remove the files of a script install, only after the build worked.
      remove "Applications/AgentSwitch.app", base: :home, recursive: true
      remove ".local/bin/agent-switch", base: :home
    end
  end

  postflight_steps do
    remove ["{{staged_path}}/build", "{{staged_path}}/cargo-home", "{{staged_path}}/agent-switch-{{version}}"],
           recursive: true
  end

  uninstall quit: "dev.agent-switch.menubar"
end
