---
name: laptop-and-dotfiles
description: Where a change lands when the user asks for a change on this laptop.
---

# Laptop and dotfiles

When the user asks for a change on this laptop, apply the change on the laptop and write the change in this project in the same task. Install an application on the laptop and add its install step to `packages.sh`. Change a configuration file on the laptop and write the same change in the file under `home/`. Report both results to the user, and report a step that you could not apply on the laptop with the command that the user must run.

Obey this rule also for a change that you start yourself. When you install an application, when you write a file under `~/`, or when you change a setting of this laptop, write the change in this project in the same task. Ask no question first.

Make each file that you write under `home/` the target of a symlink on the laptop. Run `ln -sfn` on the file on the laptop, then run `ls -la` on that file and read the arrow in the output. A regular file on the laptop holds different content from this project after one more change.

Name in your report the path in this project of each file that you wrote.
