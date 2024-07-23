/* Revision: 3.5.2 */

/******************************************************************************
* Copyright 1998-2018 NetBurner, Inc.  ALL RIGHTS RESERVED
*
*    Permission is hereby granted to purchasers of NetBurner Hardware to use or
*    modify this computer program for any use as long as the resultant program
*    is only executed on NetBurner provided hardware.
*
*    No other rights to use this program or its derivatives in part or in
*    whole are granted.
*
*    It may be possible to license this or other NetBurner software for use on
*    non-NetBurner Hardware. Contact sales@Netburner.com for more information.
*
*    NetBurner makes no representation or warranties with respect to the
*    performance of this computer program, and specifically disclaims any
*    responsibility for any damages, special or consequential, connected with
*    the use of this program.
*
* NetBurner
* 5405 Morehouse Dr.
* San Diego, CA 92121
* www.netburner.com
******************************************************************************/

#include <init.h>
#include <nbrtos.h>
#include <system.h>
#include <sim.h>
#include <buffers.h>
#include <pins.h>
#include <utils.h>
#include <math.h>
#include <Wire.h>

#include <SparkFun_Qwiic_Keypad_Arduino_Library.h>
#include <SparkFun_Qwiic_OLED.h>

#include <json_lexer.h>
#include <webclient/http_funcs.h>
#include <nbtime.h>   // Include for NTP functions

const char *AppName = "QwiicBlogExample";

const char *DATA_URL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_day.geojson";
const int DATA_UPDATE_INTERVAL = 60*15; // Every 15 minutes

SerialIf Serial;
TwoWire Wire;

// The Library supports four different types of SparkFun boards. The demo uses the following
// defines to determine which device is being used. Uncomment the device being used for this demo.

//QwiicMicroOLED myOLED;
//QwiicTransparentOLED myOLED;
//QwiicNarrowOLED myOLED;
Qwiic1in3OLED myOLED;

QwiicFont *pFont;


#include "res/qwiic_resdef.h"
#define BMP_STOPWATCH_WIDTH  7
#define BMP_STOPWATCH_HEIGHT 7
class QwStopwatch final : public bmpSingleton<QwStopwatch> {
public:
    const uint8_t* data(void)
    {
        // we use LCD Assistant (linked from the SparkFun website) for this
        // use vertical byte orientation
        static const uint8_t bmp_stopwatch_data[] = {
            // stopwatch 7x7
            0x1C, 0x22, 0x49, 0x4F, 0x41, 0x22, 0x1C,
        };

        return bmp_stopwatch_data;
    }

    QwStopwatch()
        : bmpSingleton<QwStopwatch>(BMP_STOPWATCH_WIDTH, BMP_STOPWATCH_HEIGHT)
    {
    }
};
#define QW_BMP_STOPWATCH QwStopwatch::instance()


KEYPAD key;

bool updateNow = false;
int currentScreen = 0;
int32_t nQuakes = 0;
const int MAX_QUAKES = 10;
const char *LOADING_MSG = "\n\nLoading...";
NBString screenBuf[MAX_QUAKES]; // up to ten screens worth of info
const int WEB_TIMEOUT = 15; // seconds

void handleKeypad()
{
    uint8_t rv=key.getButton();
    key.updateFIFO();
    if(rv>0)
    {
        // asterisk clears
        if (rv == '2') {
            currentScreen--;
            if (currentScreen < 0) currentScreen = nQuakes-1; // loop
            printf("[PREV]");
        } else if (rv == '8') {
            currentScreen++;
            if (currentScreen > nQuakes-1) currentScreen = 0; // loop
            printf("[NEXT]");
        } else if (rv == '#') {
            printf("[RELOAD]");
            updateNow = true;
        } else {
            printf("[%c]",rv);
        }

    }
}

// Assuming a fixed-width font, how many characters can we fit per line?
int getMaxLineChars()
{
    int pixelWidth = myOLED.getWidth();
    int charWidth = myOLED.getStringWidth("X");
    return pixelWidth/charWidth;
}

void updateScreen()
{
    myOLED.erase();
    myOLED.setCursor(0, 0);
    myOLED.print(screenBuf[currentScreen]);
    if (screenBuf[currentScreen] != LOADING_MSG)
        myOLED.bitmap(0, 0, QW_BMP_STOPWATCH);
    myOLED.display();
}

bool updateRemoteData()
{
    ParsedJsonDataSet JsonResult;
    bool result = DoGet(DATA_URL, JsonResult, WEB_TIMEOUT);
    if (result)
    {
        // JsonResult.PrintObject(true);
        nQuakes = JsonResult("metadata")("count");

        printf("Got %ld quakes:\r\n", nQuakes);

        // limit nQuakes to 10 max
        if (nQuakes > MAX_QUAKES) nQuakes = MAX_QUAKES;

        for (int i = 0; i < nQuakes; i++)
        {   // A JsonRef is a pointer into a ParsedJsonDataSet object variable or object to simplify access.
            // The following code creates a pointer into the event array to capture the properties object.
            JsonRef OneQuakeProperties = JsonResult("features")[i]("properties");
            if (OneQuakeProperties.Valid())
            {
                double magnitude = OneQuakeProperties("mag");
                NBString place_name = OneQuakeProperties("place");

                time_t when = OneQuakeProperties("time");
                when /= 1000;
                time_t now = time(NULL);
                time_t delta = (now - when);
                //int sec = delta % 60;
                int mins = (delta / 60) % 60;
                int hour = (delta / 3600);

                // avoid wrapping past the end of the screen and back to 0,0
                int maxLineChars = getMaxLineChars();

                // Format results and write to screen
                screenBuf[i].sprintf("  %dh %1.1f\n\n%s", hour, mins, magnitude, place_name.substr(0,maxLineChars*4).c_str());

                printf("  %d ago - %2.1f %s\r\n", hour, magnitude, place_name.c_str());

                currentScreen = 0; // reset display

            } //Array object look up is valid
            else
            {
                printf("Parse error failed to find array element %d\r\n", i);
            }

        }  // for
    }  // valid result
    else
    {
        iprintf("Failed to contact server\r\n");
    }
    return result;
}

void UserMain(void *pd)
{
	init();        // Initialize network stack
    // SetHttpDiag(true);
	//Enable system diagnostics. Probably should remove for production code.
	EnableSystemDiagnostics();
	iprintf("Application: %s\r\nNNDK Revision: %s\r\n", AppName, GetReleaseTag());

	WaitForActiveNetwork(TICKS_PER_SECOND * 25);

    // Set time (so HTTPS doesn't throw errors)
    bool bTimeSet = SetTimeNTPFromPool();
    if(bTimeSet)
    {
        printf("Time Set\r\n");
    }

    // Get earthquake data
    printf("Running OLED Earthquake example\n");

    // Initialize the OLED device and related graphics system
    Wire.begin();

    while (myOLED.begin() == false)
    {
        printf("OLED begin failed. Waiting...\n");
        OSTimeDly(TICKS_PER_SECOND*5);
    }
    printf("OLED begin success.\n");

    pFont = myOLED.getFont();

    // Initialize and connect to the keypad
    while (key.begin() == false)
    {
        printf("Keypad begin failed. Waiting...\n");
        OSTimeDly(TICKS_PER_SECOND*5);
    }
    printf("Keypad begin success.\n");
    while (key.isConnected() == false)
    {
        printf("Keypad is not connected. Waiting...\n");
        OSTimeDly(TICKS_PER_SECOND*5);
    }
    printf("Keypad is connected.\n");

    time_t lastDataUpdate = 0;

    screenBuf[0] = LOADING_MSG;
    currentScreen = 0;
    updateScreen();

    // Main program loop
	while(1)
	{
        if (time(NULL) - lastDataUpdate > DATA_UPDATE_INTERVAL || updateNow) {
            updateNow = false;

            screenBuf[0] = LOADING_MSG;
            currentScreen = 0;
            updateScreen();

            OSTimeDly(TICKS_PER_SECOND);

            while(!updateRemoteData()){
                OSTimeDly(TICKS_PER_SECOND*WEB_TIMEOUT);
            }
            lastDataUpdate = time(NULL);
        }

        handleKeypad();
        updateScreen();

        OSTimeDly(1);
	}

};

