# composefs: The reliability of disk images, the flexibility of files

The composefs project combines several underlying Linux features to provide a very flexible mechanism to support read-only mountable filesystem trees, stacking on top of an underlying "lower" Linux filesystem.

The key technologies composefs uses are:

overlayfs as the kernel interface
EROFS for a mountable metadata tree
fs-verity (optional) from the lower filesystem
The manner in which these technologies are combined is important. First, to emphasize: composefs does not store any persistent data itself. The underlying metadata and data files must be stored in a valid "lower" Linux filesystem. Usually on most systems, this will be a traditional writable persistent Linux filesystem such as ext4, xfs, btrfs etc.

The "tagline" for this project is "The reliability of disk images, the flexibility of files", and is worth explaining a bit more. Disk images have a lot of desirable properties in contrast to other formats such as tar and zip: they're efficiently kernel mountable and are very explicit about all details of their layout. There are well known tools such as dm-verity which can apply to disk images for robust security. However, disk images have well known drawbacks such as commonly duplicating storage space on disk, can be difficult to incrementally update, and are generally inflexible.

composefs aims to provide a similarly high level of reliability, security, and Linux kernel integration; but with the flexibility of files for content - avoiding doubling disk usage, worrying about partition tables, etc.
