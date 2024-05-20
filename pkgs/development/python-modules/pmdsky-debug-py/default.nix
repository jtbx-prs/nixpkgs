{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
}:

#This package is auto-generated. It could totally be possible to generate it from upstream, but seems unecessary
buildPythonPackage rec {
  pname = "pmdsky-debug-py";
  version = "8.0.4";
  pyproject = true;
  # SkyTemple specifically require this version. This is used when patching the binary,
  # and risk to be a bit problematic if using the latest version, given it doesn’t follow semver.

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = pname;
    rev = version;
    sha256 = "sha256-D81vXhYGxwvy26PvicniCLiS58LmrSP9ppzXKRzQSJc=";
  };

  prePatch = "cd src";

  nativeBuildInputs = [ setuptools ];

  meta = with lib; {
    description = "Autogenerated and statically check-able pmdsky-debug symbol definitions for Python";
    homepage = "https://github.com/SkyTemple/pmdsky-debug-py";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
