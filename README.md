GBSFileWrapper: Better File Wrappers
================================

NSFileWrapper is an incredibly convenient class, but it has a lot of strange and inconvenient properties:

* File wrappers are immutable--unless they represent directories, in which case you can add and remove child wrappers. Or unless you call `-readFromURL:options:error:`, which updates the file wrapper in-place.
* The name of the file represented by a file wrapper is stored in up to three places--its `filename` property, its `preferredFilename` property, and the dictionary contained in its parent's `fileWrappers` property. Which of these is canonical? (I think it's the parent's `fileWrappers` dictionary, but I'm not sure.)
* They include a lot of obsolete methods for working with paths.
* They have an obsolete way of talking about file attributes, using an NSDictionary with the old .file* methods instead of something like the more modern -[NSURL getResourceValue:forKey:error:] API.
* There's no good way to make a file wrapper backed by a different data source--like a zip archive or git repository--except by loading all the data into memory and building a tree of file wrappers to represent it.

GBSFileWrapper represents a cleaner way of doing things. I think you'll like it.

GBSFileWrapper
-------------

A GBSFileWrapper is an immutable object representing a file system object. GBSFileWrappers have two important user-facing properties: `type` and `contents`. Type is one of the `GBSFileWrapperType` constants: `GBSFileWrapperTypeNil`, `GBSFileWrapperTypeDirectory`, `GBSFileWrapperTypeRegularFile`, or `GBSFileWrapperTypeSymbolicLink`. `contents` is an object of an appropriate type for the file system object in question--`NSData` for a regular file, `NSURL` for a symbolic link, or `NSDictionary` for a directory.

Metadata about the file system object in question can be accessed via `-resourceValuesForKeys:error:` or its convenience wrapper, `-getResourceValue:forKey:error:`. There are also a number of convenience methods added by various categories, such as `-initWithURL:options:error:`, `-initWithContents:resourceValues:`, and `-NSFileWrapper`. By default, URL-based methods load their contents lazily.

GBSMutableFileWrapper
-------------------

Like many Apple classes, GBSFileWrapper has a mutable subclass, GBSMutableFileWrapper. GBSMutableFileWrapper makes the `content` property writable; setting it to an `NSData` will create a regular file, `NSURL` will create a symbolic link, and `NSDictionary` will create a directory. Rather than setting the entire directory's contents in one go, you can also call `-setContentsChildFileWrapper:forName:` to change just one file. (Pass `nil` to remove a child.) If you want to add a child without replacing any existing children, instead call `-addContentsChildFileWrapper:forPreferredName:`; this will modify the filename if necessary, returning the new filename to the caller.

GBSMutableFileWrapper also adds `-setResourceValues:` and a convenience wrapper, `-setResourceValue:forKey:`. Both GBSFileWrapper and GBSMutableFileWrapper conform to `NSCopying` and `NSMutableCopying` so you can easily create a mutable copy of a file wrapper.

GBSFileWrapperDataSource
---------------------

GBSFileWrapperDataSource is a protocol that lets you back a GBSFileWrapper with your own logic. To use it, simply implement the methods in GBSFileWrapperDataSource on a class and pass an object of that class to -[GBSFileWrapper initWithDataSource:].

You can access a file wrapper's data source through the `GBSFileWrapper.dataSource` property. If a data source doesn't want to handle certain things--for instance, it doesn't want to implement all the logic necessary to handle mutation--it can construct an alternate data source and call `-[GBSFileWrapper substituteEquivalentDataSource:]` to instruct the file wrapper to use it in the future. (It should then forward the method call to the new data source.)

GBSFileWrapper ships with a concrete data source class, GBSFileWrapperMemoryDataSource, which simply uses an Objective-C object to store the data.

Project Status
-----------

GBSFileWrapper is usable, but it's in a very early state of development. I'm still changing things on a whim. (For example, I'm thinking about changing `type` to `kind`, which seems to match OS X terminology better.) If you want to actually use it, expect stuff to constantly be changing underfoot.

Known issues include:

* GBSFileWrapper doesn't interact with the file system directly yet; it uses NSFileWrapper as an intermediary. This means, among other things, that the resourceValue-related APIs only operate on a tiny slice of the actual metadata available.

Copyright
-------

Copyright (c) 2013 Groundbreaking Software.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


