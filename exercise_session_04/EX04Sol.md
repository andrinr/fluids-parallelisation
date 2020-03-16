# HP EX4

## Andrin Rehmann

### 1. Permissions

Permission of $HOME: `drwx------`

Permission of $SCRATCH: `drwxr-xr-x`

Other users directories are generally only accessible by them. Meaning for example on course00 we have `drwx------`

Creating a new file in the the users directory gives it the default permissions: `-rw-r--r--`

**COMMIT: Permission of user80 is `drwx------`, obviously I cannot read it, since I do not have the permissions.**

In order to change the user permission we can type `chmod u=rwe, g=, o=`

### 2. Regex - grep

- ```bash
  grep 00$ binary.txt
  ```

- ```bash
  grep '^1.*1$' binary.txt
  ```

- ```bash
  grep 110 binary.txt
  ```

- ```bash
   grep '1.*1.*1.*' binary.txt    
  ```

- ```bash
   grep '111' binary.txt    
  ```



### 3. Scripting











