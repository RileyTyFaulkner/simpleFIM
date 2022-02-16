# simpleFIM

#### Code was written in November of 2021, pushing to git for records

This is a simple powershell script allowing a user to generate hashes on files in a folder, and then monitor differences between live hashes and stored hashes. 

This was a quick project to mess with powershell, and get a technical grasp on integrity. If I were to take this further- I'd implement file structure handling (recursive search through folders), better reporting/notification methods, allowing user input for hash algo. 

#### Usage

Running simpleFIM will prompt the user for input, option A and B. User should first select A- which will generate a hashes.txt log file which can then be used to monitor integrity. Rerunning the script and selecting B after a hashes.txt file has been generated will then begin monitoring file integrity. If a file is added, deleted, or changed in the IntegrityMonitor directory- the user will be notified of the change in console. 
