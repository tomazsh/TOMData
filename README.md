NNNData
=======

NNNData provides a simple boilerplate for making apps that utilize Core Data. Categories on existing Core Data classes provide methods for quick block based interface and do automatic error handling via `NNNDataErrorHandler`.

Using Predefined Contexts
-------------------------

NNNData utilizes parent and child context to provide an easy way for detaching data persistence from main queue. A root managed object context is the base context that is directly connected to persistent store coordinators. It operates on a private queue, therefore saving is always done in background. Main context is a child of the root context and should be used for all main queue interactions. Because main context is not directly associated with any persistent store coordinators, when you want to apply changes to your persistent store, you should use the `saveWithParentContext` or `saveWithParentContexts` methods to also save the root context.

![NNNData Predefined Contexts](http://f.cl.ly/items/37161u3k2k430j3M0D05/NNNData.png "NNNData Predefined Contexts")

Misc
----

* NNNData uses ARC.
* Detailed documentation is available [here](http://tomazsh.github.com/NNNData/).
* NNNData is available under the MIT license. See the LICENSE file for more info.