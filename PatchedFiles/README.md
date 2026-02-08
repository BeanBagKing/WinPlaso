# make_release.ps1
Direct link to the official version: [https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1](https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1)

Part of [l2tdevtools](https://github.com/log2timeline/l2tdevtools/tree/main), this file belongs at `l2tdevtools\data\pyinstaller\make_release.ps1`. The original commit contains the unmodified version as of 2028-02-08. The majority of the changes were accounting for new directory structures, as seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/ef30dc420eb5ba05d9a56330697c26d9c40082c5). Lines [19](https://github.com/BeanBagKing/WinPlaso/blob/7e9bd876f3f3103e0c01d1613387f43fc1e3377f/PatchedFiles/make_release.ps1#L19) and [23](https://github.com/BeanBagKing/WinPlaso/blob/7e9bd876f3f3103e0c01d1613387f43fc1e3377f/PatchedFiles/make_release.ps1#L23) don't seem to make a difference, as python.exe should be in your path from pymanager, but you still might want to adjust them if you use a different version.

The errors below are expected as of 2026-02-08, since the licensing copy is variable, I'm not going to correct these.
```
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libcaes' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libfwps' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.Click' because it does not exist.
Remove-Item: Cannot find path 'C:\working\plaso\dist\plaso\licenses\LICENSE.libwrc' because it does not exist.
```

# pyproject.toml
Direct link to the official version: [https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1](https://github.com/log2timeline/l2tdevtools/blob/main/pyproject.toml)

Part of [l2tdevtools](https://github.com/log2timeline/l2tdevtools/tree/main), this file belongs at `l2tdevtools\pyproject.toml`. The original commit contains the unmodified version as of 2028-02-08. The only change was a wildcard, as seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/2f715b030fb3ddb295d077fedffe44a33d5bcf6b), so that pip install will include subpackages like l2tdevtools.download_helpers. You can also use the original and do `pip install -e .` so that imports come from the package directory.

# vmdk_file_io.py
Direct link to the official version: [https://github.com/log2timeline/dfvfs/blob/main/dfvfs/file_io/vmdk_file_io.py](https://github.com/log2timeline/dfvfs/blob/main/dfvfs/file_io/vmdk_file_io.py)

### Disclaimer / Warning
This is an AI slop change. It seems to fix the bug without introducing new problems, but there are workarounds if you don't want to risk issues.

Part of [dfvfs](https://github.com/log2timeline/dfvfs), this file will be provisioned in `<python-venv>\Lib\site-packages\dfvfs\file_io\vmdk_file_io.py` while installing prerequisites. The original commit contains the unmodified version as of 2028-02-08. This change addresses a dropped drive letter on split VMDKs, and can be seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/797b724d20efcba53b4b0daa37f738095cfbee1e). This was done to address a bug in [VMDK extent path resolution not handling drive letter](https://github.com/log2timeline/dfvfs/issues/776). If you tried to run log2timeline against a VM that used "_Split virtual disk into multiple files_" and was on a different drive letter, the drive letter would get dropped and you would get an error reading "_Unable to scan source with error: Unable to open file object with error: Unable to locate all extent data files._" with log2timeline, or no error at all with psteal. This did NOT cause problems with "_Store virtual disk as a single file_" VMs. As a workaround, if you run into this error and don't want to use the AI slop patch, you can run log2timeline from the VMDK directory and it will happily work, presumably because it's now using relative paths.

If you want to add this fix, get through the `python .\tools\update.py` portion of l2tdevtools and then replace `vmdk_file_io.py` in your python environments `\Lib\site-packages\dfvfs\file_io\` folder.
