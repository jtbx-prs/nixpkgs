{ lib
, buildPythonPackage
, fetchFromGitHub
, mock
, pyjwt
, pytestCheckHook
, pythonOlder
, pytz
, requests
}:

buildPythonPackage rec {
  pname = "twilio";
  version = "7.9.1";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "twilio";
    repo = "twilio-python";
    rev = "refs/tags/${version}";
    hash = "sha256-oi8LqyeqN8gn06B/m1wNI9iNu7hU3NrdkL7xTsImYPI=";
  };

  propagatedBuildInputs = [
    pyjwt
    pytz
    requests
  ];

  checkInputs = [
    mock
    pytestCheckHook
  ];

  disabledTests = [
    # Tests require network access
    "test_set_default_user_agent"
    "test_set_user_agent_extensions"
  ];

  pythonImportsCheck = [
    "twilio"
  ];

  meta = with lib; {
    description = "Twilio API client and TwiML generator";
    homepage = "https://github.com/twilio/twilio-python/";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
