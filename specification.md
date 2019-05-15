# Getting started with Windmill

## The user must be able to add an Xcode project to Windmill

* auto detect the scheme for the project and proceed to run as normal
* first look for the "humanish" repository name (i.e. git@bitbucket.org:qnoid/balance.git > balance)
* then for a scheme match based on the repository name
    * if there is no match
	* look for a target match
	    * if there is no match
		* use the first scheme

## When a scheme is updated on the project, the scheme should be updated on the next run

* if the name of the selected scheme hasn't changed in the project, the scheme should remain selected on the next run
* if the name of the selected scheme did change, the sceme selected is undefined


## Show the application icon in the toolbar under the "sceme" menu

* if the application icon is currently unknowned, show a default one
* show the same icon for every scheme listed

## Windmill must be able to also pull code from any git submodules as part of monitoring a project repo

# Simulator Support

## The user must be able to run the build on a Simulator

* By default, the device should be the same as the one the app was built and tested for.
* If the device is removed since Windmill performed the last run, simply open the Simulator.
* The user should be given the option to install the build on any device.

# Test Reports

## Windmill must report test failures

* The user can click the test failure icon, including failed count to see the list of test failures
* The user can also navigate using the 'Jump to Next/Previous Issue' menu item

# Subscribers

# Distribute app

## Given an active subscription, Windmill should distribute the export

* The distribute stage starts only after every checkout, build, test, archive, export succeeds

## The user must be able to retry the distribute stage in case it fails

* In case of an error in the distribute stage 
	* Give the user the option to retry
