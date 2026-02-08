# make_release.ps1
Direct link to the official version: https://github.com/log2timeline/l2tdevtools/blob/main/data/pyinstaller/make_release.ps1

Part of [l2tdevtools](https://github.com/log2timeline/l2tdevtools/tree/main), this file belongs in `l2tdevtools\data\pyinstaller`. The original commit contains the unmodified version as of 2028-02-08. The majority of the changes were accounting for new directory structures, as seen in the [initial diff](https://github.com/BeanBagKing/WinPlaso/commit/ef30dc420eb5ba05d9a56330697c26d9c40082c5). The errors below are expected as of 2026-02-08, since the licensing copy is variable, I'm not going to correct these.
```
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libcaes' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.libfwps' because it does not exist.
Copy-Item: Cannot find path 'C:\working\plaso\dist\l2tdevtools\data\licenses\LICENSE.Click' because it does not exist.
Remove-Item: Cannot find path 'C:\working\plaso\dist\plaso\licenses\LICENSE.libwrc' because it does not exist.
```
