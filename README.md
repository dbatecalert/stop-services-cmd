# stop-services-cmd
Manage Windows service events.

Summary: 
The batch file and accompanying list of services (stop_updates_06.cmd and test_stop_services.txt)
together help manage windows service events. Running the batch file looks through the services file 
for matching Windows services to stop and disable. When granted administrative privileges the
program stops running services and disables not protected services. A basic set of Windows and 
third party software update services are included in the list.

Warning: 
Service info summary information can be shown without administrative permissions and without changing
any services. But, stopping or disabling services requires administrative permissions. Sufficient
precautions should be taken before running this program. Create a system restore point prior to 
using this program, and know how to restore windows in case of unexpected results. Before adding
services to stop and disable the services file first research the impact on your Windows experience.

Features:
1) Service info summary (non administrative) - counts, running, nondisabled, protected

2) Manually run with toggle to run as administrator, or scheduled to run with highest privileges.

3) Stops running services - matching services file.

4) Disables non-disabled and not protected services - matching services file.

5) Logs work as administrator to Event Viewer. Stop service event logging includes service start time.

6) Windows automatically logs disabled services to the System Event log.

7) To create a minimal Task Scheduler task select "Run with highest privileges", create a one time trigger to repeat the task every <period> for indefinite duration, and create an action to start the program from an administrative folder.
  
8) When running manually or testing as a normal user just click-run on the batch file. After showing a service info summary if there is no work the program will close automatically. Updating running and non-disabled services requires administrative permissions and the batch file will automatically prompt for User Account Control (UAC) permission elevation. Only if
UAC approved the script will re-run and stop matching services and disable nonprotected services.
