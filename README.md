# My-CFG

Welcome to My-CFG! This repository provides automated setup scripts to configure my environments on both Windows and Linux (Ubuntu). Customize UI style, set up shortcuts, remove unwanted applications, and install the ones I need.

## Linux

```
git clone https://github.com/raissonsouto/my-cfg.git && bash my-cfg/linux/run-all.sh
```

## Windows

1. [Download this repository to your computer.](https://github.com/raissonsouto/my-cfg/archive/refs/heads/main.zip)

2. Open Windows PowerShell as an administrator.

3. Allow Windows to run scripts without been digitally signed.

```
set-executionpolicy Unrestricted
```

4. Navigate to the directory containing the `windows.ps1`.

```
cd ~/Downloads/my-cfg/my-cfg-main/
```

5. Run the `windows.ps1` script. Obs: Modify ``windows.ps1` to your own needs before run it.

```
windows/windows.ps1
```

6. Disable scripts without been digitally signed.

```
set-executionpolicy Restricted
```

## Contributing
Fell free to enhance and expand My-CFG further. If you have improvements, bug fixes, or new features to propose, open an issue or submit a pull request.
