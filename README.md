# expressRez Readme

## Table of Contents

* Introduction
* Instructions
* License
* Support

## Introduction

expressRez is a set of scripts to pack and re-rez large, copyable builds. It can communicate with "child" parts whose root prims are up to 100 meters from the base prim.

I created expressRez because I needed a way to package up a build I was working on and didn't think it'd be very hard to put together. I was a bit wrong. A day or two of coding later, expressRez was completed.

## Instructions

For the latest version of the expressRez scripts (and these instructions), please visit http://github.com/expresszenovka/expressRez

I assume that build you're packaging is already completed. There are three parts to the process: recording, packing, and unpacking.

### Recording

1. Choose a spot near the center of your build.
2. Link pieces of your build together as best you can, making sure that the root prims of all pieces are within a 100m radius of the central location you chose.
3. Rename each piece so that it has a unique name. This prevents renaming when packing the pieces.
4. Add the expressRez prim script to the root prim of every piece you created in the last step.
5. Rez a prim at the central location and add the expressRez recorder script to it. Then click on it and wait.
6. After 30 seconds, the script should spit out a bunch of stuff between a !---- START ----! and a !---- DONE ----!
7. Copy the part in middle (without timestamps) to a notecard.

### Packing
1. Pick up all the pieces you have built (still containing the prim script)
2. Rez a new prim and add all pieces to its inventory.
3. Add the notecard with positions from before. It should be the only notecard in the prim.
4. Add the expressRez main script to the box as well.

### Unpacking
1. Rez the packed box at an approximate desired location.
2. If not prompted, click on the packed box.
3. Choose rez to unpack the build relative to the new location.
4. Move the packed box till the build is in the correct location. Prims may lag based on the number of pieces.
5. When the correct location is found, choose set from the dialog. This will delete all the scripts added.
6. If the approximate location is wrong or you need to remove all prims, choose delete. **NB: if the item does not have copy permissions, delete could cause loss of the build**
7. After setting the build, delete the packed box.

## License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Support

As stated in the license above, I make no guarantees for this software.

It has worked for me, but I haven't had the time to test it extensively, nor do I plan on making changes unless functionality breaks horribly. This is why I offer it free of charge under the GPL. If anyone finds something broken or wishes to improve upon it, they may. I'd definitely appreciate any fixes being submitted back upstream to me.

However, I understand that people might need help with using these scripts. They may not know how to modify the scripts to work for them. To that end, I will offer paid support for these scripts. Please IM Express Zenovka inworld for more information.

Also, you might take a look into the following commercial products that most of what expressRez does and plenty more:

* Rez-Faux, by Lex Neva
* Rez-Foo, by CrystalShard Foo

I've never actually worked with either product as a builder, though I have bought houses using both in the past. I didn't need all their features and wanted to write my own.