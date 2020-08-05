This folder contains files with hosts that should be processed by exscript-backup
Each hosts file will run in a single exscript-backup process
Only files with extension *.tsv are processed

Files should be tab-delimited and have at least a column: hostname or address as the first column
Other columns can be used as parameters inside the template file.
See the exscript documentation for the exact syntax.

As an extension to the default exscript behavior it's possible to add a parameter to indicate
which authentication (account-pool) file should be used and/or which exscript template should be used.

To do this start your hosts file with the following line:
   # ACCOUNT-POOL:default.cfg  TEMPLATE:test.exscript

Replace "default.cfg" with any other account-pool file. that exists in the etc/auth folder.
Replace test.exscript with any other exscript template file that exists in the etc/templates folder.

Be aware that this will override the default account-pool settings.
