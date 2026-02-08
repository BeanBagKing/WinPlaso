# make_release.ps1
Direct link to the official version: [https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1](https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1)

Part of [l2tdevtools](https://github.com/log2timeline/l2tdevtools/tree/main), this file belongs at `l2tdevtools\data\pyinstaller\make_release.ps1`. The original commit contains the unmodified version as of 2028-02-08. The majority of the changes were accounting for new directory structures, as seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/ef30dc420eb5ba05d9a56330697c26d9c40082c5). The errors below are expected as of 2026-02-08, since the licensing copy is variable, I'm not going to correct these.
```
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libcaes' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libfwps' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.Click' because it does not exist.
Remove-Item: Cannot find path 'C:\working\plaso\dist\plaso\licenses\LICENSE.libwrc' because it does not exist.
```

# pyproject.toml
Direct link to the official version: [https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1](https://github.com/log2timeline/l2tdevtools/blob/main/pyproject.toml)

Part of [l2tdevtools](https://github.com/log2timeline/l2tdevtools/tree/main), this file belongs at `l2tdevtools\pyproject.toml`. The original commit contains the unmodified version as of 2028-02-08. The only change was a wildcard, as seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/2f715b030fb3ddb295d077fedffe44a33d5bcf6b), so that pip install will include subpackages like l2tdevtools.download_helpers. You can also use the original and do `pip install -e .` so that imports come from the package directory.
