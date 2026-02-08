# WinPlaso

## Summary

Better summary coming soon™. TL;DR is that I think I have a reproducable process for building fast Windows binaries. Remember kids, don't trust random binaries from the internet, everything you need to do this yourself should be below.

References
* https://nullsec.us/log2timeline-windows-build/

## How to build

This build used a clean Windows 11 24H2 VM and commands below were all performed in a PowerShell 7.5.4 terminal. I wouldn't expect PowerShell 5 to work any different, but that may be the one setup change you need to make.

I created a directory in the root of C: named PlasoBuild, `C:\PlasoBuild\`, to hold repos, python venv's, and other files. If you build somewhere else, adjust accordingly.

### Necessary Windows packages 

The Microsoft.VisualStudio.BuildTools winget will install Visual Studio Community and should automatically select the correct necessary workload and sub components. Double check this though, as some of these may change or be renamed. It's a roughly 6gb install, so it will take a minute. 

I used Python Manager for this, if you have an existing Python install, you're on your own. All of these can be installed from their various source websites if you want to use that, this just makes it easy to copy/paste commands. Admin rights will be requested for several of these.

Close and reopen your terminal after this step.
```PowerShell
mkdir C:\PlasoBuild\
cd C:\PlasoBuild\
winget install -e --id Microsoft.VisualStudio.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100"
winget install Git.Git
winget install Python.PythonInstallManager
```

### Python setup
`py -VV` should install the latest version of Python and then print the version number. As of this writing, that is `Python 3.14.3`. If you want to install a specific version, you can use `pymanager install 3.14.3`. l2tdevtools requires `wmi` and doesn't seem to require but uses `deprecated`, `future`, and `build`. Plaso doesn't require but uses `fakeredis` and `mock` for tests.

As of litereally 2 hours ago (2026-02-08 19:28:18 UTC), in the middle of testing this, [setuptools version 82.0.0](https://setuptools.pypa.io/en/stable/history.html#v82-0-0) was pushed out. This deprecates `pkg_resources` and causes a run_tests.py failure on the DownloadPageContent test (`ERROR: download_helpers.pypi (unittest.loader._FailedTest.download_helpers.pypi ... ModuleNotFoundError: No module named 'pkg_resources'`). I don't know if this actually causes a problem, but I figured it's safer to drop back one release for now.

Close and reopen your terminal before this step.
```PowerShell
cd C:\PlasoBuild\
py -VV 
python -m venv plaso-env && . .\plaso-env\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install wmi deprecated future build mock 'fakeredis<=2.21.3' 'setuptools==81.0.0'
```

### Clone the needed repos
Note the `core.autocrlf=false`, without this Windows will "correct" line endings and some Plaso tests will fail. Not sure if it's necessary for the other two, but can't hurt right?
```PowerShell
cd C:\PlasoBuild\
git -c core.autocrlf=false clone https://github.com/pyinstaller/pyinstaller.git
git -c core.autocrlf=false clone https://github.com/log2timeline/plaso.git
git -c core.autocrlf=false clone https://github.com/log2timeline/l2tdevtools.git
```

### Install PyInstaller
Version 6.18.0 is the latest as of this writing. You can use `git tag` to view all tags, but the easier way is to visit [https://github.com/pyinstaller/pyinstaller/releases](https://github.com/pyinstaller/pyinstaller/releases) and see what the latest stable release tag is.
```PowerShell
cd C:\PlasoBuild\pyinstaller\
git checkout tags/v6.18.0
python -m pip install .
```

### Install l2tdevtools, update binaries
This will update the binaries used for the final build. If you get an `ModuleNotFoundError: No module named 'l2tdevtools.download_helpers'` error, you didn't [patch pyproject.toml](https://github.com/BeanBagKing/WinPlaso/tree/main/PatchedFiles)

You can optionally run `run_tests.py` at this point, you should get one failure for testRunCommand. This is because the test tries to run `echo hello`, but Windows doesn't have an echo binary, it's a function of cmd, so the run command would be `cmd /c echo hello`. TL;DR, this shouldn't affect anything.
```PowerShell
cd C:\PlasoBuild\l2tdevtools\
Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/pyproject.toml" -OutFile "C:\PlasoBuild\l2tdevtools\pyproject.toml"
python -m pip install .
python .\tools\update.py
# Optional
python .\run_tests.py 
```

### Patch make_release.ps1
At this point grab the patched version of `make_release.ps1`, and optionally, `vmdk_file_io.py`. [https://github.com/BeanBagKing/WinPlaso/tree/main/PatchedFiles](https://github.com/BeanBagKing/WinPlaso/tree/main/PatchedFiles)
```
Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/make_release.ps1" -OutFile "C:\PlasoBuild\l2tdevtools\data\pyinstaller\make_release.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/vmdk_file_io.py" -OutFile "C:\PlasoBuild\plaso-env\Lib\site-packages\dfvfs\file_io\vmdk_file_io.py"
```

### Build Plaso for Windows
As with PyInstaller, I'm using the latest stable version (20260119) as of this writing. Releases page: [https://github.com/log2timeline/plaso/releases](https://github.com/log2timeline/plaso/releases). Make sure you are in the `C:\PlasoBuild\plaso` directory when you execute `make_release.ps1`
```
cd C:\PlasoBuild\plaso\
git checkout tags/20260119
C:\PlasoBuild\l2tdevtools\data\pyinstaller\make_release.ps1
```
Fin. You should have a `plaso-20260119-amd64.zip` (or whatever your build number is) in the `C:\PlasoBuild\plaso\` directory

## Info

More info, screenshots, etc. coming one day.

## Bugs, Issues, and Notes
* The "refresh" rate of the status is extreamly slow if you're used to the official plaso builds. Official builds seem to update every 0.5 seconds or so. These binaries seem to update every 1 minute or so. It's not frozen, just give it time.
* It seems to leave `Worker_*.log.gz`, `something.plaso`, and other files around in the run path instead of cleaning up after itself.
* There's a lot of untested flags. Basic timelining works and provides the expected output for at least Windows 11 and Ubuntu 24.04 images. I haven't tested every image I can think of, nor all the optional flags.
* If you are testing and diff a WSL timeline with one created with Windows binaries, remember that Windows uses CRLF line endings, so EVERY line will be different. Run dos2unix on the Windows timeline.
    * Also keep version differences in mind. Ubuntu 24.04 PPA package is still on 20250918. I've noticed some differenecs in the 'parser' field, but no difference in the 'Timestamp' or 'Message' field (the actual important data).
