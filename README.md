# NetBurner Qwiic SOMRT1061 Blog Example

This example shows how to use Qwiic I2C with the SOMRT1061 Development Kit.

For a full explanation on how to use this repo and for a step by step guide to
get up and running, please see our article, [Use Qwiic and SOMRT1061 for Rapid Prototyping](https://www.netburner.com/learn/use-qwiic-i2c-and-somrt1061-for-rapid-prototyping/),
found on NetBurner's website at [www.netburner.com](https://www.netburner.com).

## Code

This code runs best in NNDK 3.5.2 or higher and is intended for the SOMRT1061.

1. Create a new blank NetBurner project in NBEclipse with your SOMRT1061's IP, etc.
2. Copy these files on top of the files in the project, replacing any existing files or folders.
3. Compile and upload.
4. Connect your Qwiic 1.3" OLED Display and Keypad. If using other devices, modify
   the code appropriately.

## Case

This is a 3D printed enclosure made with OpenSCAD and YAPP, which is an optional
but fun way to mount the peripherals and create an enclosure for your SOMRT1061
dev board.

- Install the Allerta and Allerta Stencil fonts in your system
  so that the labels are appropriately stencil-ified. You may
  encounter issues on Windows if fonts are installed as your
  user account and not as Administrator (system-level)
- Try the 3d-printed-enclosure/test-sample.scad or .stl files first.
- Modify the variables at the top of the file (or, worst case, inside the file)
  as needed to produce an STL file that works for your slicer and printer.
- Once the diameters, measurements, and print settings are dialed in, then use the
  somrt1061-qwiic-dev-board-example-enclosure.scad file with those same settings.
- If you're truly brave, you can try printing the included STL files directly,
  however printers often have quirks that affect the precise fit of parts.
- For best print results, you'll probably want to use your slicer to split the model
  into individual objects or parts and print one or a few parts at a time.
  Be aware that some slicers have trouble with the button flanges and standoff
  inner radiuses: check that when you do the split that all tubes remain the same
  height and there are no leftover rings laying on the virtual print bed after splitting.
- Refer to the linked blog post for detailed assembly instructions.
