# Creating a SWMB package for OCS Inventory

We create a zip archive containing an `install.bat` file
and the setup installer of the SWMB application.
To simplify this task, the different commands are grouped in a `Makefile`.
These are easier to use under GNU/Linux.
```bash
make help
```

In the `Makefile`, set the `VERSION` and `REVISION` variables to the correct values.
Normally, the `VERSION` number is automatically updated with the value in the main installer `package.nsi`.
If no problem, `REVISION` value is one.
When creating the zip archive, the `install.bat` script will be automatically updated with these values.

It is possible to do a `make update` to update to the latest version proposed by the RESINFO working group.
This command is strictly equivalent to a `git pull` at the root of your SWMB clone.

Once the versions are set, do
```bash
make all
```
then upload the provided zip into your OCS Inventory server following the answers that the `Makefile` tells you.
Unfortunately, OCS does not yet have a REST API that allows simple uploading of the package from the command line.
