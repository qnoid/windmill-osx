//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import SwiftGit2
import LlamaKit


public typealias WindmillProvider = () -> Windmill

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

extension NSError {
    
    enum ErrorCode : Int {
        
        /// Error loading repo
        case RepoError
        
        /// Error loading commit
        case CommitError
    }

    class func errorRepo(localGitRepo: String, underlyingError : NSError) -> NSError
    {
        let localizedDescription = NSLocalizedString("windmill.repo.error.description", comment:"")
        let failureDescription = String(format:localizedDescription, localGitRepo)
        
        return NSError(domain: WindmillDomain, code: ErrorCode.RepoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:""),
            NSUnderlyingErrorKey: underlyingError])
    }
    
    class func errorCommit(underlyingError : NSError) -> NSError{
        return NSError(domain: WindmillDomain, code: ErrorCode.CommitError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.latestCommit.error.description", comment:""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:""),
            NSUnderlyingErrorKey: underlyingError])
    }
}

protocol WindmillDelegate
{
    func created(windmill: Windmill, projects:Array<Project>, project: Project)
    func failed(windmill: Windmill, error: NSError)
}

final public class Windmill
{
    static let logger : ConsoleLog = ConsoleLog()
    
    var delegate: WindmillDelegate?
    
    let scheduler: Scheduler
    let keychain: Keychain
    
    var projects : Array<Project>
    
    convenience init()
    {
        self.init(scheduler: Scheduler(), keychain: Keychain.defaultKeychain())
    }

    convenience init(keychain: Keychain)
    {
        self.init(scheduler: Scheduler(), keychain: keychain)
    }

    convenience init(scheduler: Scheduler)
    {
        self.init(scheduler: scheduler, keychain: Keychain.defaultKeychain())
    }

    required public init(scheduler: Scheduler, keychain: Keychain)
    {
        self.scheduler = scheduler
        self.keychain = keychain
        self.projects = []
    }

    /**

    /**
    
    Adds the 'project' to the datasource.
    
    :postcodition: MainWindowController#reloadData will be called if the given 'project' was added
    
    :param: project the project to add to the datasource
    
    :returns: true if the 'project' was added to the datasource, false if already in the datasource
    */

    project was added
    project not be added
    project failed to create
    
    */
    func add(localGitRepo: String) -> Bool
    {
        if let localGitRepoURL = NSURL(fileURLWithPath: localGitRepo)
        {
            let name = localGitRepoURL.lastPathComponent!
            
            let repo = Repository.atURL(localGitRepoURL)
            
            if let repo = repo.value
            {
                let latestCommit: Result<Commit, NSError> = repo.HEAD().flatMap { commit in repo.commitWithOID(commit.oid) }
                
                if let commit = latestCommit.value {
                    Windmill.logger.log(.INFO, "Latest Commit: \(commit.message) by \(commit.author.name)")
                    
                    let origin = repo.allRemotes().value![0].URL
                    
                    let project = Project(name: name, origin: origin)
                    if(contains(self.projects, project)){
                        Windmill.logger.log(.INFO, "Project already added: \(project)")
                        return false
                    }
                    
                    self.projects.append(project)

                    self.delegate?.created(self, projects:self.projects, project: project)

                    let defaultFileManager = NSFileManager.defaultManager()
                    
                    let userLibraryDirectoryView = defaultFileManager.userLibraryDirectoryView()
                    let directoryForProvisioningProfiles = userLibraryDirectoryView.directory.mobileDeviceProvisioningProfiles()
                    
                    let mobileProvisioningExists = directoryForProvisioningProfiles.fileExists("\(name).mobileprovision")
                    
                    self.deployGitRepo(localGitRepo)
                    
                    return true
                }
                else if let error = latestCommit.error {
                    Windmill.logger.log(.ERROR, "Could not get commit: \(error)")
                    self.delegate?.failed(self, error: NSError.errorCommit(error))
                }
            }
            else if let error = repo.error {
                Windmill.logger.log(.ERROR, "Could not open repository: \(error)")
                self.delegate?.failed(self, error: NSError.errorRepo(localGitRepo, underlyingError:error))
            }
            
        }
        else {
            Windmill.logger.log(.ERROR, "Error parsing location of local git repo: \(localGitRepo)")
        }
        
        return false
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