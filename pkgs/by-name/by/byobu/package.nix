{ lib
, stdenvNoCC
, fetchFromGitHub
, autoreconfHook
, makeWrapper
, python3
, perl
, tmux
, gettext
, vim
, bc
, screen

, textual-window-manager ? tmux
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [ snack ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "byobu";
  version = "6.10";

  src = fetchFromGitHub {
    owner = "dustinkirkland";
    repo = "byobu";
    rev = finalAttrs.version;
    hash = "sha256-fRU47Mh6feurK3ht4Lfzv/zZk61CdDILX0Iq1oysSKE=";
  };

  doCheck = true;

  strictdeps = true;
  nativeBuildInputs = [ autoreconfHook makeWrapper gettext ];
  buildInputs = [ perl ]; # perl is needed for `lib/byobu/include/*` scripts
  propagatedBuildInputs = [ textual-window-manager screen ];

  postPatch = ''
    substituteInPlace usr/bin/byobu-export.in \
      --replace "gettext" "${gettext}/bin/gettext"
    substituteInPlace usr/lib/byobu/menu \
      --replace "gettext" "${gettext}/bin/gettext"
  '';

  postInstall = ''
    # Byobu does not compile its po files for some reason
    for po in po/*.po; do
      lang=''${po#po/}
      lang=''${lang%.po}
      # Path where byobu looks for translations as observed in the source code and strace
      mkdir -p $out/share/byobu/po/$lang/LC_MESSAGES/
      msgfmt $po -o $out/share/byobu/po/$lang/LC_MESSAGES/byobu.mo
    done

    # Override the symlinks otherwise they mess with the wrapping
    cp --remove-destination $out/bin/byobu $out/bin/byobu-screen
    cp --remove-destination $out/bin/byobu $out/bin/byobu-tmux

    for i in $out/bin/byobu*; do
      # We don't use the usual ".$package-wrapped" because arg0 within the shebang scripts
      # points to the filename and byobu matches against this to know which backend
      # to start with
      file=".$(basename $i)"
      mv $i $out/bin/$file
      makeWrapper "$out/bin/$file" "$out/bin/$(basename $i)" --argv0 $(basename $i) \
        --set BYOBU_PATH ${lib.escapeShellArg (lib.makeBinPath [ vim bc ])} \
        --set BYOBU_PYTHON "${pythonEnv}/bin/python"
    done
  '';

  meta = with lib; {
    homepage = "https://launchpad.net/byobu/";
    description = "Text-based window manager and terminal multiplexer";

    longDescription =
      ''Byobu is a GPLv3 open source text-based window manager and terminal multiplexer.
        It was originally designed to provide elegant enhancements to the otherwise functional,
        plain, practical GNU Screen, for the Ubuntu server distribution.
        Byobu now includes an enhanced profiles, convenient keybindings,
        configuration utilities, and toggle-able system status notifications for both
        the GNU Screen window manager and the more modern Tmux terminal multiplexer,
        and works on most Linux, BSD, and Mac distributions.
      '';

    license = licenses.gpl3;

    platforms = platforms.unix;
    maintainers = with maintainers; [ qknight berbiche ];
  };
})
