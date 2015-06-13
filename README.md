# ghost

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with ghost](#setup)
    * [What ghost affects](#what-ghost-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ghost](#beginning-with-ghost)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs, configures and manages instances of Ghost blog.
It is originally written for Archlinux but will work on any systemd system.

## Module Description

Ghost is a pure blogging platform based on NodeJS. This module provides a
simplified way of creating configurations to manage any number of instances
of Ghost.

This module is for any system with systemd. Everything is run in standard
locations as per file-hierarchy and systemd standards. Any other dependencies
(nodejs currently) are managed by upstream Puppet modules.

## Setup

### What ghost affects

This module is only lightly tested outside of Archlinux, but there are no
foreseeable issues

### Setup Requirements

Puppetlabs-nodejs can be included but is not necessary so long as npm is
available on the system

### Beginning with ghost

The most basic configuration is as follows:

```
include ghost

ghost::instance { 'test':
 url => 'https://blog.foo-bar.com'
}
```

## Usage

### Ghost::Instance

After including the parent ghost module on your node, you can create multiple instances of Ghost using ghost::instance. The options you can specify are below:

**url**
 The URL where this instance will be hosted. e.g. 'https://blog.example.com'. (Required)

**user**
 The user which this instance will run as and which will own all files (Optional)

**group**
 The group which this instance will run as and which will own all files (Optional)

**home**
 The home in which all files will reside. (Optional)

**version**
 The version of ghost to install. Specifying a new version will update
 installed instances to the new (or old) version. (Optional)

**host**
 Host IP to listen on. (Optional) Defaults to localhost.

**port**
 Default port to listen on. (Optional) Defaults to 2368.

**transport**
 Mail transport option. (Optional) See http://docs.ghost.org/mail/

**from**
 Mail from option. (Optional) See http://docs.ghost.org/mail/

**mail_options**
 Mail misc options. Accepts a hash of options. (Optional) See http://docs.ghost.org/mail/


## Updates
By specifying a newer version of Ghost you can upgrade an instance. Copies of
the new version are only downloaded once per host. Updates follow the release
process outlined by the Ghost documentation.

## Limitations

This has been tested thoroughly on Archlinux but is designed to work on any
machine using systemd. The latest releases of most major distros should work
without issue:
  * Archlinux
  * Fedora 18+
  * RedHat 7+ and derivatives
  * Debian 8+
  * Ubuntu 15.04+

Currently only basic mail servers are supported. Ghost itself supports things
like mailgun and gmail directly. This module does not yet support that.

## Development

Licensed under the MIT license. Pull requests are more than welcome.
