{ stdenv, pkgconfig, fetchurl, python, dropbox }:
let
  version = "2018.11.28";
  dropboxd = "${dropbox}/bin/dropbox";
in
stdenv.mkDerivation {
  name = "dropbox-cli-${version}";

  src = fetchurl {
    url = "https://linux.dropboxstatic.com/packages/nautilus-dropbox-${version}.tar.bz2";
    sha256 = "0m1m9c7dfc8nawkcrg88955125sl1jz8mc9bf6wjay9za8014w58";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ python ];

  phases = "unpackPhase installPhase";

  installPhase = ''
    mkdir -p "$out/bin/" "$out/share/applications"
    cp data/dropbox.desktop "$out/share/applications"
    cp -a data/icons "$out/share/icons"
    find "$out/share/icons" -type f \! -name '*.png' -delete
    substitute "dropbox.in" "$out/bin/dropbox" \
      --replace '@PACKAGE_VERSION@' ${version} \
      --replace '@DESKTOP_FILE_DIR@' "$out/share/applications" \
      --replace '@IMAGEDATA16@' '"too-lazy-to-fix"' \
      --replace '@IMAGEDATA64@' '"too-lazy-to-fix"'
    sed -i 's:db_path = .*:db_path = "${dropboxd}":' $out/bin/dropbox
    chmod +x "$out/bin/"*
    patchShebangs "$out/bin"
  '';

  meta = {
    homepage = http://dropbox.com;
    description = "Command line client for the dropbox daemon";
    license = stdenv.lib.licenses.gpl3;
    maintainers = with stdenv.lib.maintainers; [ the-kenny ];
    # NOTE: Dropbox itself only works on linux, so this is ok.
    platforms = stdenv.lib.platforms.linux;
  };
}
