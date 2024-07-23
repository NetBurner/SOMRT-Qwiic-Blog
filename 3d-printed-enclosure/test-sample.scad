myPcb = "./includes/DEV-SOMRT1061_R1P1.stl";

// Install the Allerta and Allerta Stencil fonts in your system
// so that the labels are appropriately stencil-ified. You may
// encounter issues on Windows if fonts are installed as your
// user account and not as Administrator (system-level)

/* Begin easily changeable non-YAPP stuff */
lightTubeWall = 1.2; // 0.4 to 1.2mm has been tested; at least 1x the printer nozzle diameter

screen1in3Width = 30.5;
screen1in3Height = 15;
screen1in3Depth = 5;

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

// screw standoffs are sized for 4mm head ~2mm thread >=7mm long pointy screws.
// to use M3 inserts and socket caps, change this to your insert diameter (try 4.1-4.5)
// and the connectors array "th" (3) to have more leeway like 3.5
screwThreadDiameter = 2;

/* End easily changeable non-YAPP stuff */


////////////////////////////////////////////////////////////////
// we include YAPP here so that the above variables are in-scope
// while YAPP's own variables are defined below
include <./YAPP_Box-3.0.1-modified/YAPPgenerator_v3.scad>
////////////////////////////////////////////////////////////////


/* Begin easily changeable YAPP stuff */

//showPCB=true;
//showSideBySide=false;
//inspectX=7;
//inspectY=7;

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

pcbLength           = 50; // changed for test
pcbWidth            = 50; // changed for test
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

// reduced for test
connectors = 
[
    //  x              y                              height th hd                  ins OD
    [17.3,           4.2, standoffHeight-pcbThickness*2+0.13, 3, 6.5, screwThreadDiameter, 7.3],
    [3.8,   pcbWidth-4.3, standoffHeight-pcbThickness*2+0.13, 3, 6.5, screwThreadDiameter, 7.3],
];

/*
// press-fit standoffs (use instead of screw standoffs)
pcbStands = 
[
    [17.3,  4.2],
    [3.8,   pcbWidth-4.3],
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
    [107.5-85,   8,   10,    8, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j7
    [118.8-85, 7.2,  9.4, 11.5, 1,   yappRectangle, yappCoordPCB, yappCenter], //j8
];

cutoutsFront =
[   // x      y  wid  ht rad           shape    origin
    [100.8-65, 8.2, 17,  15, 1,   yappRectangle, yappCoordPCB, yappCenter], //j6 eth1
    [77.4-59.6,  3.3, 13,   8, 1, yappRoundedRect, yappCoordPCB, yappCenter], //j11 otg dev
];

cutoutsLid =
[   //  x     y  wid len rad        shape    origin
    [lidMountForward*.39, screenMountRight/3, screen1in3Width/2, screen1in3Height/2, 1, yappRoundedRect, yappCoordPCB, yappCenter], // 1.3" qwiic screen
    [lidMountForward*.39,  keypadMountRight/3,   keypadWidth/3+1, keypadHeight/3+1, 3.5, yappRoundedRect, yappCoordPCB, yappCenter], //qwiic keypad
];

// s1 and s2 are screw hole distances from center (+/-)
// h1 is the height of the base of the strap
// h2 is additional thickness of the strap beyond the base
module insideStrap(l,w,h1,h2,s1,s2)
{
  $fn = 20;
  difference() {
    cube([l,w,h1], center=true);
    translate([s1,0,0]) cylinder(h=h1+2, d=2.5, center=true);
    translate([s2,0,0]) cylinder(h=h1+2, d=2.5, center=true);
  }
  translate([0,0,h1/2+h2/2]) cube([l*.4,w,h2], center=true);
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
  //  halfStandoff(pcbWidth*.75+paddingBack+offset,screenMountRight+paddingLeft,6,lidMountStandoffHeight);
  //}

  // standoffs for 1.3" screen mount
  for (offset = [screen1in3Width/2+7,-screen1in3Width/2-7]) {
    halfStandoff(lidMountForward*.39+paddingBack+offset,screenMountRight/3+paddingLeft,6,lidMountStandoffHeight);
  }

  // standoffs for keypad mount
  for (offset = [keypadWidth/2+7,-keypadWidth/2-7]) {
    halfStandoff(lidMountForward*.39+paddingBack+offset, keypadMountRight/2+paddingLeft,6,lidMountStandoffHeight);
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
    [100.8-65, 17, 15.65, yappCoordPCB, yappCenter],    // ethernet
    [77.4-59.6, 13,     1, yappCoordPCB, yappCenter], //j11 otg dev
];

ridgeExtBack =
[   // pos width height  origin
    [107.5-85,  10, 5, yappCoordPCB, yappCenter], //j7
    [118.8-85, 9.4, 2, yappCoordPCB, yappCenter], //j8
];

lightTubes =
[
    // 1.75mm circular for gluing transparent filament in
    // the current 2mm top diameter is usually a little too narrow for it to fit
    // which keeps things inside and level but reduces visibility a bit
    //  x  y len wid wall gap      type lens
    [48.5-45, 8+4, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led1
    [55  -45, 8+4, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led2
    [61.7-45, 8+4, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led3
    [68.1-45, 8+4, 2, 2.5, lightTubeWall, 2, yappCircle, 0], // led4
];

pushButtons = 
[
    // x     y  le wi ra  ab   sH  sT pD hT         sh  an fi wl  pl slack
    [79*.32,   7.2*6, 0, 0, 4, 0.5, 8.5, 3, 4, 2, yappCircle, 0, 0, 2, 2.5, 0.5],
];

labelsPlane = 
[   //                 x                    y rot dep   plane               font size    text
    [ 48.2+wallThickness-45,    11+wallThickness+4, 0, 10, yappLid, "Allerta Stencil", 3.5, "1" ],
    [ 54.5+wallThickness-45,    11+wallThickness+4, 0, 10, yappLid, "Allerta Stencil", 3.5, "2" ],
    [ 61.2+wallThickness-45,    11+wallThickness+4, 0, 10, yappLid, "Allerta Stencil", 3.5, "3" ],
    [ 67.5+wallThickness-45,    11+wallThickness+4, 0, 10, yappLid, "Allerta Stencil", 3.5, "4" ],
    [    2+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "5-24v (+)" ],
    [ 23.5+wallThickness,    21+basePlaneThickness, 0, 0.5, yappBack,  "Allerta",   3, "[+] [-]" ],
    [   91+wallThickness-63,    22+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Ethernet 1" ],
    [ 71.5+wallThickness-61,    17+basePlaneThickness, 0, 0.5, yappFront, "Allerta",   3, "Device" ],
];


imagesPlane =
[ //              x                   y rot dep   plane                        image  scale
    [40*.65+wallThickness, 72*.37+wallThickness, 0, 10, yappBase, "includes/netburner-logo-stencil.svg", 0.75*.7],
];

if (showPCB)
{
    translate([wallThickness+paddingBack+backSideMountingDepth,wallThickness+paddingLeft,basePlaneThickness+standoffHeight+pcbThickness]) 
    {
            rotate([0,0,0]) scale(0.37) color("darkgray") import(myPcb);
    }
}

YAPPgenerate();