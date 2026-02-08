```PowerShell
mkdir C:\PlasoBuild\
cd C:\PlasoBuild\
winget install -e --id Microsoft.VisualStudio.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100"
winget install Git.Git
winget install Python.PythonInstallManager

# Close and reopen your terminal windows

cd C:\PlasoBuild\
py -VV 
python -m venv plaso-env && . .\plaso-env\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install wmi deprecated future build mock 'fakeredis<=2.21.3' 'setuptools==81.0.0'

git -c core.autocrlf=false clone https://github.com/pyinstaller/pyinstaller.git
git -c core.autocrlf=false clone https://github.com/log2timeline/plaso.git
git -c core.autocrlf=false clone https://github.com/log2timeline/l2tdevtools.git

cd C:\PlasoBuild\pyinstaller\
git checkout tags/v6.18.0
python -m pip install .

cd C:\PlasoBuild\l2tdevtools\
Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/pyproject.toml" -OutFile "C:\PlasoBuild\l2tdevtools\pyproject.toml"
python -m pip install .
python .\tools\update.py

Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/make_release.ps1" -OutFile "C:\PlasoBuild\l2tdevtools\data\pyinstaller\make_release.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/BeanBagKing/WinPlaso/refs/heads/main/PatchedFiles/vmdk_file_io.py" -OutFile "C:\PlasoBuild\plaso-env\Lib\site-packages\dfvfs\file_io\vmdk_file_io.py"

cd C:\PlasoBuild\plaso\
git checkout tags/20260119
C:\PlasoBuild\l2tdevtools\data\pyinstaller\make_release.ps1
```
