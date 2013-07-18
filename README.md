TOMData
=======

TOMData makes Core Data easier to work with. Categories on existing Core Data classes provide methods for quick block based interface and do automatic error handling via `TOMDataErrorHandler`.

Using Predefined Contexts
-------------------------

TOMData utilizes parent and child context to provide an easy way for detaching data persistence from main queue. A root managed object context is the base context that is directly connected to persistent store coordinators. It operates on a private queue, therefore saving is always done in background. Main context is a child of the root context and should be used for all main queue interactions. Because main context is not directly associated with any persistent store coordinators, when you want to apply changes to your persistent store, you should use the `tom_saveWithParentContext` or `tom_saveWithParentContexts` methods to also save the root context.

![TOMData Predefined Contexts](http://f.cl.ly/items/0C0g3R362k3z1h3P1Q3c/TOMData.png "TOMData Predefined Contexts")

Misc
----

* TOMData uses ARC.
* Detailed documentation is available [here](http://tomazsh.github.com/TOMData/).
* TOMData is available under the MIT license. See the LICENSE file for more info.