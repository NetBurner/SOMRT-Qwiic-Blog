myPcb = "./includes/DEV-SOMRT1061_R1P1.stl";

// Install the Allerta and Allerta Stencil fonts in your system
// so that the labels are appropriately stencil-ified. You may
// encounter issues on Windows if fonts are installed as your
// user account and not as Administrator (system-level)

//TODO
// - consider cutouts for the J7 power screws (lower height!)
// - " " for the JP3-4 and JP1 usb jumpers
// - " " for the potentiometer
// - consider slightly lower buttons (1-2mm)
// - " separate assembly for easier/lower P1-P4 access
// - " cutout for wifi board
// - " hinge and/or snap-fit option


/* Begin easily changeable non-YAPP stuff */
outputWifi = true;

lightTubeWall = 1.2; // 0.4 to 1.2mm has been tested; at least 1x the printer nozzle diameter

screen1in3Width = 30.5;
screen1in3Height = 15;
screen1in3Depth = 4.5;

screenMicroWidth = 16.5;
screenMicroHeight = 13;
screenMicroDepth = 6;

keypadWidth = 46;
keypadHeight = 57;
keypadDepth = 4;

screenMountRight = 105;
keypadMountRight = 52;
lidMountForward = 100;
lidMountStandoffHeight = 8;

wifiMountHeight = 13; // mm of wifi board pcb antenna from top of main board

// screw standoffs are sized for M3 inserts and socket caps, change this to your insert diameter (usually 4.1-5)
// to use 4mm head ~2mm thread >=7mm long pointy screws, try 1.5-2.
screwThreadDiameter = 5;
connectorDiameter = 7.3;

/* End easily changeable non-YAPP stuff */

////////////////////////////////////////////////////////////////
// we include YAPP here so that the above variables are in-scope
// while YAPP's own variables are defined below
include <./YAPP_Box-3.0.1-modified/YAPPgenerator_v3.scad>
////////////////////////////////////////////////////////////////


/* Begin easily changeable YAPP stuff */

//showPCB=true;
//showSideBySide=false;
//inspectX=95;
//inspectY=7.5;

backSideMountingDepth = 0;

printBaseShell      = true;
printLidShell       = true;

/* End easily changeable YAPP stuff */


// Edit these parameters for your own board dimensions
wallThickness       = 2.5;
basePlaneThickness  = 2.5;
lidPlaneThickness   = 2.5;

// Total height of box = basePlaneThickness + lidPlaneThickness 
//                     + baseWallHeight + lidWallHeight

baseWallHeight      = 10.5;
lidWallHeight       = 25;

pcbLength           = 135;
pcbWidth            = 135;
pcbThickness        = 1.7;
                            
// padding between pcb and inside wall
paddingFront        = .25;
paddingBack         = 1;
paddingRight        = 1;
paddingLeft         = 1;

// ridge where Base- and Lid- off the box can overlap
// Make sure this isn't less than lidWallHeight
ridgeHeight         = 4;
ridgeSlack          = 0.4;
roundRadius         = 2.0;  // don't make this to big..

//-- How much the PCB needs to be raised from the base
//-- to leave room for solderings and whatnot
standoffHeight      = 5.0;
standoffDiameter    = 5;
standoffPinDiameter = 2.4;

connectors = 
[
    //  x              y                              height th hd                  ins OD
    [17.3,           4.2, standoffHeight-pcbThickness*2+0.13, 3.5, 6.5, screwThreadDiameter, connectorDiameter],
    [131.5,          3.6, standoffHeight-pcbThickness*2+0.13, 3.5, 6.5, screwThreadDiameter, connectorDiameter],
    [3.8,   pcbWidth-4.3, standoffHeight-pcbThickness*2+0.13, 3.5, 6.5, screwThreadDiameter, connectorDiameter],
    [111.4, pcbWidth-6.8, standoffHeight-pcbThickness*2+0.13, 3.5, 6.5, screwThreadDiameter, connectorDiameter],
];

/*
// press-fit standoffs (use instead of screw standoffs)
pcbStands = 
[
    [17.3,  4.2],
    [131.5, 3.6],
    [3.8,   pcbWidth-4.3],
    [111.4, pcbWidth-6.8],
];

// snap-together lid (use instead of screw standoffs)
snapJoins =   
[
    [40,  5, yappLeft, yappRight, yappSymmetric],
    [95,  5, yappBack],
    [44,  5, yappFront]
];*/

cutoutsBack =
[   //  x     y   wid   len rad           shape    origin
    [19.9,    8, 31.5,   13, 1, yappRoundedRect, yappCoordPCB, yappCenter], //ser2
    [55.1,    8, 31.5,   13, 1, yappRoundedRect, yappCoordPCB, yappCenter], //ser1
    [83.2,  3.3,   13,    8, 1, yappRoundedRect, yappCoordPCB, yappCenter], //usb-c
    [107.5,   8,   10,    8, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j7
    [118.8, 7.2,  9.4, 11.5, 1,   yappRectangle, yappCoordPCB, yappCenter], //j8
];

cutoutsFront =
[   // x      y  wid  ht rad           shape    origin
    [123,   8.2, 17,  15, 1,   yappRectangle, yappCoordPCB, yappCenter], //j5 eth0
    [100.8, 8.2, 17,  15, 1,   yappRectangle, yappCoordPCB, yappCenter], //j6 eth1
    [77.4,  3.3, 13,   8, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j11 otg dev
    [59.4,    6, 14,   7, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j15 otg host
    [31,    2.7, 14, 2.5, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j10 microsd
    [31,    3.3,  9,   10, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j10 microsd thumb
    [14.7,  3.3,  9,   10, 1, yappRoundedRect, yappCoordPCB, yappCenter], //p5 qwiic
    if (outputWifi) [23.5,  wifiMountHeight+pcbThickness,  20,   5, 1, yappRoundedRect, yappCoordPCB, yappCenter], //wifi
];

cutoutsLid =
[   //  x     y  wid len rad        shape    origin
    /*
    // Uncomment these to expose the normal dev board header pins
    [71.7, 29.8, 33,  9, 1, yappRectangle, yappCoordPCB, yappCenter], //p1
    [102,  60.5,  9, 33, 1, yappRectangle, yappCoordPCB, yappCenter], //p2
    [71.7, 91.7, 33,  9, 1, yappRectangle, yappCoordPCB, yappCenter], //p3
    [41.5, 60.5,  9, 33, 1, yappRectangle, yappCoordPCB, yappCenter], //p4
    [120,  44.5, 25,  4, 1, yappRectangle, yappCoordPCB, yappCenter], //p6
    // x              y wid len rad        shape depth   origin
    [98,   pcbWidth-7.5, 23, 9, 1, yappRectangle, 30, yappCoordPCB, yappCenter], //adc
    [49,   pcbWidth-4.5,  8, 3, 1, yappRectangle, yappCoordPCB, yappCenter], //3.3v
    [60.5, pcbWidth-4.5,  8, 3, 1, yappRectangle, yappCoordPCB, yappCenter], //5v
    [24.3,  pcbWidth-26,  8, 3, 1, yappRectangle, yappCoordPCB, yappCenter], //gnd
    */

    // x    y   wid len rad          shape    origin
    //[pcbWidth*.75, screenMountRight, screenMicroWidth, screenMicroHeight, 1, yappRoundedRect, yappCoordPCB, yappCenter], // micro qwiic screen
    [lidMountForward, screenMountRight, screen1in3Width, screen1in3Height, 1, yappRoundedRect, yappCoordPCB, yappCenter], // 1.3" qwiic screen
    [lidMountForward,  keypadMountRight,   keypadWidth+1, keypadHeight+1, 3.5, yappRoundedRect, yappCoordPCB, yappCenter], //qwiic keypad
];

// s1 and s2 are screw hole distances from center (+/-)
// h1 is the height of the base of the strap
// h2 is additional thickness of the strap beyond the base
module insideStrap(l,w,h1,h2,s1,s2)
{
  $fn = 20;
  translate([0,0,h1/2]){
      difference() {
        cube([l,w,h1], center=true);
        translate([s1,0,0]) cylinder(h=h1+2, d=3.5, center=true);
        translate([s2,0,0]) cylinder(h=h1+2, d=3.5, center=true);
      }
      translate([0,0,h1/2+h2/2]) cube([l*.4,w,h2], center=true);
  }
}

module hookLidInside()
{

  module halfStandoff(x, y, d, h)
  {
    // screen is centered at 100,100 and we want 8mm standoff height
    translate([x, y, 0]){
      pinFillet(-d/2, 2);
      translate([0, 0, -h]){
        difference(){
          cylinder(d=d, h=100); // outer
          translate([0,0,-1]) cylinder(d=screwThreadDiameter, h=5); // inner screw hole          
        }
      }
    }
  }

  // standoffs for micro screen mount
  //for (offset = [screenMicroWidth/2+7,-screenMicroWidth/2-7]) {
  //  halfStandoff(pcbWidth*.75+paddingBack+offset,screenMountRight+paddingLeft,max(6,screwThreadDiameter*1.5),lidMountStandoffHeight);
  //}

  // standoffs for 1.3" screen mount
  for (offset = [screen1in3Width/2+7,-screen1in3Width/2-7]) {
    halfStandoff(lidMountForward+paddingBack+offset,screenMountRight+paddingLeft,max(6,screwThreadDiameter*1.5),lidMountStandoffHeight);
  }

  // standoffs for keypad mount
  for (offset = [keypadWidth/2+7,-keypadWidth/2-7]) {
    halfStandoff(lidMountForward+paddingBack+offset, keypadMountRight+paddingLeft,max(6,screwThreadDiameter*1.5),lidMountStandoffHeight);
  }
}

// keyboard strap
translate([-60,80,0]) rotate(90) insideStrap(46+20,10,2,lidMountStandoffHeight-keypadDepth+1,46/2+7,-46/2-7);

// tiny screen strap
//translate([-40,80,0]) rotate(90) insideStrap(screenMicroWidth+25,10,2,lidMountStandoffHeight-screenMicroDepth+1,screenMicroWidth/2+7,-screenMicroWidth/2-7);

// 1.3" screen strap
translate([-40,80,0]) rotate(90) insideStrap(screen1in3Width+25,10,2,lidMountStandoffHeight-screen1in3Depth+1,screen1in3Width/2+7,-screen1in3Width/2-7);

ridgeExtFront =
[   // pos width height  origin
    [111.8, 48, 15.65, yappCoordPCB, yappCenter],    // ethernet
    [77.1,  13,     1, yappCoordPCB, yappCenter], //j11 otg dev
    [59,    14,     3, yappCoordPCB, yappCenter], //j15 otg host
    [23.5,   35,     12.5, yappCoordPCB, yappCenter],    // qwiic, microsd, wifi
];

ridgeExtBack =
[   // pos width height  origin
    [19.9, 31.5, 2, yappCoordPCB, yappCenter], //ser2
    [55.1, 31.5, 2, yappCoordPCB, yappCenter], //ser1
    [83.2,   13, 1, yappCoordPCB, yappCenter], //usb-c
    [107.5,  10, 5, yappCoordPCB, yappCenter], //j7
    [118.8, 9.4, 2, yappCoordPCB, yappCenter], //j8
];

lightTubes =
[
    // 1.75mm circular for gluing transparent filament in
    // the current 2mm top diameter is usually a little too narrow for it to fit
    // which keeps things inside and level but reduces visibility a bit
    //  x  y len wid wall gap      type lens
    [36.8, 7, 2, 2.5, lightTubeWall, 5, yappCircle, 0], // led9
    [48.5, 8, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led1
    [55,   8, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led2
    [61.7, 8, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led3
    [68.1, 8, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led4
    [11.5, pcbWidth-4.5, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // pwr3.3
    [21.5, pcbWidth-4.5, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // pwr5
    [23,    pcbWidth-34, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // usbtx
    [23,    pcbWidth-43, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // usbrx
];


pushButtons = 
[
    // x     y  le wi ra  ab   sH  sT pD hT         sh  an fi wl  pl slack
    [79,   7.2, 0, 0, 4, 0.5, 8.5, 3, 4, 2, yappCircle, 0, 0, 2, 2.5, 0.7],
    [91.5, 7.2, 0, 0, 4, 0.5, 8.5, 3, 4, 2, yappCircle, 0, 0, 2, 2.5, 0.7],  
];

labelsPlane = 
[   //                 x                    y rot dep   plane               font size    text
    [   41+wallThickness,    60+wallThickness, 0, 10, yappLid, "Allerta Stencil", 4.5, "SOMRT1061" ],
    [    9+wallThickness,   126+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "3.3v" ],
    [ 20.4+wallThickness,   126+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "5v" ],
    [ 17.7+wallThickness,  89.5+wallThickness, 0, 20, yappLid, "Allerta Stencil",   3, "RX" ],
    [   18+wallThickness, 103.5+wallThickness, 0, 10, yappLid, "Allerta Stencil",   3, "TX" ],
    [ 36.2+wallThickness,    11+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "9" ],
    [ 48.2+wallThickness,    11+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "1" ],
    [ 54.5+wallThickness,    11+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "2" ],
    [ 61.2+wallThickness,    11+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "3" ],
    [ 67.5+wallThickness,    11+wallThickness, 0, 10, yappLid, "Allerta Stencil", 3.5, "4" ],
    [   75+wallThickness,    14+wallThickness, 0, 10, yappLid, "Allerta Stencil", 4.5, "IRQ" ],
    [   88+wallThickness,    15+wallThickness, 0, 10, yappLid, "Allerta Stencil", 4.5, "RST" ],
    [    2+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "5-24v (+)" ],
    [ 23.5+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "[+] [-]" ],
    [ 48.5+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "USB" ],
    [   42+wallThickness,    16+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "PWR/UART" ],
    [ 73.5+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "Serial 0" ],
    [108.5+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "Serial 2" ],
    [  114+wallThickness,    22+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Ethernet 0" ],
    [   91+wallThickness,    22+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Ethernet 1" ],
    [   64+wallThickness,    22+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "OTG" ],
    [ 71.5+wallThickness,    17+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Device" ],
    [   55+wallThickness,    17+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Host" ],
    [   26+wallThickness,    25+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "MicroSD" ],
    [  9.5+wallThickness, 24.3+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "QWIIC" ],
    if (outputWifi) [  20+wallThickness, 30.3+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "WiFi" ],
];


imagesPlane =
[ //              x                   y rot dep   plane                        image  scale
    [40+wallThickness, 72+wallThickness, 0, 10, yappLid, "includes/netburner-logo-stencil.svg", 0.75],
];

if (showPCB)
{
    translate([wallThickness+paddingBack+backSideMountingDepth,wallThickness+paddingLeft,basePlaneThickness+standoffHeight+pcbThickness]) 
    {
        rotate([0,0,0]) color("darkgray") import(myPcb);
    }
}

difference(){
    YAPPgenerate();

    if (outputWifi) {
        $fn=20;
        // cut the standoff in half if the WiFi board is installed
        translate([
            (pcbWidth+wallThickness)-connectorDiameter/2+1,
            showSideBySide ? (pcbLength+wallThickness)*2+25-connectorDiameter/2+0.5 : wallThickness+8-connectorDiameter/2+0.5,
            showSideBySide ? lidPlaneThickness+lidWallHeight+ridgeHeight-ridgeSlack/2-wifiMountHeight : basePlaneThickness+standoffHeight+pcbThickness
        ])
            cylinder(d=connectorDiameter+0.5,h=wifiMountHeight);
    }
}
if (outputWifi) {
    $fn=20;
    // make an 11mm spacer if the WiFi board is being used
    translate([-15,pcbWidth,0]) difference() {
        cylinder(d=connectorDiameter,h=11);
        translate([0,0,-1]) cylinder(d=connectorDiameter*.7,h=11+2);
    }
}