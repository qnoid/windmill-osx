//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation
import SwiftGit2
import LlamaKit

private let userIdentifier = NSUUID().UUIDString;

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    @IBOutlet weak var menu: NSMenu!
    
    weak var window: NSWindow!
    var statusItem: NSStatusItem!
    
    var mainWindowController: MainWindowController!
    var projectsDatasource : ProjectsDataSource!
    
    var keychain: Keychain = Keychain.defaultKeychain()
    var scheduler: Scheduler = Scheduler()

    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        self.statusItem = NSStatusBar.systemStatusItem(self.menu, event:Event(
            action: "mouseDown:",
            target: self,
            mask: NSEventMask.LeftMouseDownMask
            ))
        self.statusItem.toolTip = NSLocalizedString("applicationDidFinishLaunching.statusItem.toolTip", comment: "")
        
        let image = NSImage(named:"windmill")!
        image.setTemplate(true)
        self.statusItem.button?.image = image
        self.statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
        self.statusItem.button?.window?.delegate = self
        
        self.keychain.createUser(userIdentifier)
        self.mainWindowController = MainWindowController.mainWindowController()
        self.projectsDatasource = ProjectsDataSource()
        self.mainWindowController.datasource = self.projectsDatasource
        self.window = mainWindowController.window
        self.window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func mouseDown(theEvent: NSEvent)
    {
        let statusItem = self.statusItem
        dispatch_async(dispatch_get_main_queue()){
            statusItem.popUpStatusItemMenu(statusItem.menu!)
        }
    }
    
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        println(__FUNCTION__);
        return .Copy;
    }
    
    func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation
    {
        return .Copy;
        
    }
    
    func draggingExited(sender: NSDraggingInfo!)
    {
        println(__FUNCTION__);
    }
    
    func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
    {
        println(__FUNCTION__);
        return true;
        
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool
    {
        println(__FUNCTION__);
        let pboard = sender.draggingPasteboard()
        
        if let folder = pboard.firstFilename()
        {
            println(folder)
            self.didPerformDragOperationWithFolder(folder)
            
            return true
        }
        
        return false
    }
    
    func didPerformDragOperationWithFolder(localGitRepo: String)
    {
        if let localGitRepoURL = NSURL(fileURLWithPath: localGitRepo)
        {
            let name = localGitRepoURL.lastPathComponent!

            let repo = Repository.atURL(localGitRepoURL)
            
            if let repo = repo.value
            {
                let latestCommit: Result<Commit, NSError> = repo.HEAD().flatMap { commit in repo.commitWithOID(commit.oid) }
                
                if let commit = latestCommit.value {
                    println("Latest Commit: \(commit.message) by \(commit.author.name)")
                    

                    let origin = repo.allRemotes().value![0].URL
                        
                    if(self.projectsDatasource.add(Project(name: name, origin: origin))){
                        self.deployGitRepo(localGitRepo)
                    }
                    
                }
                else {
                    println("Could not get commit: \(latestCommit.error)")
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("didPerformDragOperationWithFolder.alert.messageText.latestCommit.error", comment: "")
                    alert.informativeText = NSLocalizedString("didPerformDragOperationWithFolder.alert.informativeTextbar.latestCommit.error", comment: "")
                    alert.alertStyle = .CriticalAlertStyle
                    alert.beginSheetModalForWindow(self.window, completionHandler: nil)
                }
            }
            else {
                println("Could not open repository: \(repo.error)")
                let alert = NSAlert(error: repo.error!)
                alert.informativeText = NSLocalizedString("didPerformDragOperationWithFolder.alert.informativeTextbar.repo.error", comment: "")
                alert.alertStyle = .CriticalAlertStyle
                alert.beginSheetModalForWindow(self.window, completionHandler: nil)
            }

        }
        else {
            println("Error parsing location of local git repo: \(localGitRepo)")
        }
    }
    
    func deployGitRepo(localGitRepo : String)
    {
        let taskOnCommit = NSTask.taskOnCommit(localGitRepo: localGitRepo)
        self.scheduler.queue(taskOnCommit)
        
        if let user = self.keychain.findWindmillUser()
        {
            let deployGitRepoForUserTask = NSTask.taskNightly(localGitRepo: localGitRepo, forUser:user)
            
            deployGitRepoForUserTask.addDependency(taskOnCommit){
                self.scheduler.queue(deployGitRepoForUserTask)
                self.scheduler.schedule {
                    return NSTask.taskPoll(localGitRepo)
                    }(ifDirty: {
                        [unowned self] in
                        self.deployGitRepo(localGitRepo)
                        })
            }
        }
    }
}

