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
