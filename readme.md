I have made the decision to release the source code of [Windmill](https://qnoid.com/software-engineer/#windmill).
* [Windmill on the Mac](https://github.com/qnoid/windmill-osx)   
Windmill on the Mac is a native macOS application written in Swift 5 on Xcode 10 targetting macOS 10.14. The codebase is about 16k LOC.

* [Windmill on the iPhone](https://github.com/qnoid/windmill-ios)   
Windmill on the iPhone is a native iOS app written in Swift 5 on Xcode 10 targetting iOS 12.2. The codebase is about 5k LOC.

* [Windmill REST API](https://github.com/qnoid/windmill-api)   
The Windmill REST API is a Java EE 8 implementation written in Java 8 using JAX-RS. The codebase is about 7.5k LOC.

## History

I started working on Windmill as a side project in 2014. In 2017 I decided to commit full time and in February 2018, Windmill on the Mac 1.0 was released. In July 2019 Apple rejected [Windmill on the iPhone](https://qnoid.com/2019/07/29/Windmill-on-the-iPhone.html#main) and took issue with Windmill in principle. I didn't make any money on Windmill and was not in a position to take it forward given these cirmustances thus formally [ending its development](https://qnoid.com/2020/01/03/Windmill.html) in January 2020.

## Why make the source code public?

Effectively, by Apple putting Windmill on notice, the only way I can distribute Windmill on the Apple platforms is at the source code level. Even though this does not serve the mission to make continuous delivery accessible, whatever value Windmill brings even as source code, is better than none at all. 

The development of Windmill did come to an abrupt end and didn't get a fair chance to become what I had envisioned. It would bring me joy to know that developers will benefit from it by learning something new. It's a way to give back to the community.

Windmill is not some example software after all. It is production grade that spans across the desktop, mobile and the server. The software engineering behind it is still relevant and the technologies used modern.

I was diligent, took great care and put a lot of attention in building succint, performant, reliable, and bug free software across multiple platforms. I believe the source code of Windmill has something to offer whether you are a beginner or a senior in software development in any of the 3 platforms.

## What does making the Windmill source code public mean?

As a product, my gut feeling tells me that unless a company with the available resources gets behind it, Windmill will not go far. I am hopeful but don't expect much.

As software, I believe not that much. These are times where running software, on your computer (desktop or mobile), unfettered is near impossible. In order to run Windmill on your Mac and the iPhone you will need an Apple Developer account. Since Windmill is built for developers, chances are you do have one. Still.

Windmill is built to take advantage of and be tightly integrated with the Apple ecosystem. It makes use of Push Notifications, Background Mode, CloudKit and In-App Purchases. You can strip away and refactor some of the code but the point still stands. Distributing, modifying and running software outside walled gardens isn't as straight forward.

The Windmill REST API is no different. The implementation relies heavily on AWS infrastructure. It will also take some elbow grease to get up and running. 

## What not to expect

Releasing the source code of Windmill does not make it open-source. I don't plan on contributing any time or energy developing it further. To support it as open-source would demand of me even more resources and attention which I don't have the luxury of.

Don't expect any instructions on how to build and run the code.   
Don't expect the code to be extensively documented.   
Don't expect me to respond to any issues raised or pull requests made. 

I don't plan to publish any Windmill architecture diagrams, security considerations or design documents either.

## How to make the best of the source code
### Study it.

As a Swift developer, the macOS app<sup id="a1">[1](#f1)</sup> should be the most juicy one for you. 

Have a look at the `ProcessManager` type on how to launch a Process, wait and receive data in the background from both standard out and err. The `ProcessManager` also allows you to recover a Process that has exited with an error code. As an example, look at how `ActivityBuild` creates a `RecoverableProcess`.

The `Windmill` type makes extensive use of the design pattern as described in [A series of steps](https://qnoid.com/2019/05/07/A-series-of-steps.html#main) post. Take a closer look at the `ActivityBuilder` type to see how Windmill uses it to create the pipeline to a succesful build.

As fas as the iOS app goes, have a look at `PaymentQueue`
and `SubscriptionManager` on how to process transactions when purchasing a subscription that requires validating a receipt on the server.

I have already documented how to [replace the rootViewController of the UIWindow](https://qnoid.com/2019/02/15/How_to_replace_the_-rootViewController-_of_the_-UIWindow-_in_iOS.html#main) that Windmill on the iPhone also makes use of.

As a Java developer, the REST API should prove useful as a reference implementation of the Java EE 8 spec. The most interesting tidbit is likely the use of an `EntityGraph` to retain the lazy associations of an `@Entity` while performing queries that require exclusively independent associations to materialise. In the case of the Windmill REST API, that would be the `AccountResource#list` that materialises a list of `Export` types and the `SubscriptionResource#isSubscriber` that materialises a list of `Transaction` types for a `Subscription`.

### Own the code.
At the very minimum Windmill on the Mac should serve as a replacement to Jenkins. For any developers that still use Xcode 10 to build and test their app, this is as straightforward as building and signing the app using your Apple account. The iCloud capability can be disabled as it's only relevant when used alongside the iPhone app.

If you are using Xcode 11, it will take some effort to add support since Apple has changed the result bundle format. At the very least Windmill needs to be updated to support the new format.

If you do put in the time and effort, it should be possible to have Windmill on the Mac, on the iPhone and on the server running which will give you app distribution.

## What did the future hold for Windmill?
Windmill was really at its infancy. Allowing developers to distribute their app and have over-the-air installation was the first step in making its development sustainable.

I had plans to develop an TV App to act as a dashboard for teams and have company wide notifications.

I wanted to add support for nightlies, the ability to substitute resources during packaging and support conditional compilation to allow for different builds.

Finally, I wanted to tackle distributed building, support multiple configurations (e.g. to maintain multiple releases) and integration with 3rd party libraries.

Feel free to use these guidelines as a roadmap.

## The licence

>   Created by Markos Charatzas (markos@qnoid.com)   
>   Copyright © 2014-2020 qnoid.com. All rights reserved.   
>    
>   The above copyright notice and this permission notice shall be included in
>   all copies or substantial portions of the Software.   
>    
>   Permission is granted to anyone to use this software for any purpose,
>   including commercial applications, and to alter it and redistribute it
>   freely, subject to the following restrictions:   
>    
>   This software is provided 'as-is', without any express or implied
>   warranty.  In no event will the authors be held liable for any damages
>   arising from the use of this software.   
>    
>   1. The origin of this software must not be misrepresented; you must not
>      claim that you wrote the original software. If you use this software
>      in a product, an acknowledgment in the product documentation is required.   
>   2. Altered source versions must be plainly marked as such, and must not be
>      misrepresented as being the original software.   
>   3. This notice may not be removed or altered from any source distribution.   

## Final words

I still believe in Windmill and would love for a company with the resources to step in and take it forward.

I am [available for hire](http://qnoid.com/static/Curriculum%20vitae.pdf). I am based in Athens, Greece and able to invoice from a UK company if needed.

---

<b id="f1">1.</b> I should point out that this was my first ever macOS app. It is highly probable that I have made some amateur mistakes while learning about the responder chain, how to manage multiple windows and handle the menu bar. Consider this a fair warning.[↩](#a1)
