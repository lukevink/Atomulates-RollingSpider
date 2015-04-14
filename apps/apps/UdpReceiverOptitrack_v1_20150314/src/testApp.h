#pragma once

#include "ofMain.h"
#include "Grid.h"



#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import <libARSAL/ARSAL.h>
#import <libARNetwork/ARNetwork.h>
#import <libARNetworkAL/ARNetworkAL.h>

#include <termios.h>

#import "DeviceController.h"
#import "control.h"

#include "ofxSimpleSerial.h"
#include <vector>
#include "ofUtils.h"

class testApp : public ofBaseApp{

	public:

		void setup();
		void update();
		void draw();
		
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
        void gotMessage(ofMessage msg);
        void onNewMessage(string & message);
    
        typedef struct{
            unsigned char ID[4];
            unsigned char x[4];
            unsigned char y[4];
            unsigned char z[4];
            unsigned char roll[4];
            unsigned char pitch[4];
            unsigned char yaw[4];
        } MocapFormat;
        MocapFormat *data;
    
        //spider drone
        void discover_and_fly_drone();
        DeviceController *MDDC;
        
        //graphics
        ofTrueTypeFont		font;
        
        //3d graphics
        ofEasyCam camEasyCam;
        ofCamera * camera;
        grid nodeGrid;
    
    
    
        //state
        int readyForCommands = 0;

    
        //drone
        float roll, pitch, gaz, yaw;
    
    
        ofxSimpleSerial	serial;
        bool		requestRead;
        string		message;
        string      irCommand = "No Command";

};

