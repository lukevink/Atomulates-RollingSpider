#include "testApp.h"

#define VICON

void testApp::discover_and_fly_drone() {
    
    float speed = 0.50;
    
    int commandFound = 0;
    
    while(MDDC.service == nil) {
        [NSThread sleepForTimeInterval:0.3];
    }
    
    BOOL connectError = [MDDC start];
    if(connectError) {
        NSLog(@"connectError = %d", connectError);
        [MDDC stop];
        return;
    } else {
        NSLog(@"MDDC Started");
    }
    
    //meter/sec - min: 0.5, max: 2.5
    [MDDC sendMaxVerticalSpeed:2.5];
    [NSThread sleepForTimeInterval:0.3];
    
    //degree - min: 5, max: 25
    [MDDC sendMaxTilt:41.0];
    [NSThread sleepForTimeInterval:0.3];
    
    //degree/sec - min: 50, max: 360
    [MDDC sendMaxRotationSpeed:100.0];
    [NSThread sleepForTimeInterval:0.3];
    
    //meter - min: 2, max: 10
    [MDDC sendMaxAltitude:2];
    [NSThread sleepForTimeInterval:0.3];
    
    //Turn off wheels
    [MDDC sendWheelsOn:0];
    [NSThread sleepForTimeInterval:0.3];
    
    [MDDC sendCutOutMode:0];
    [NSThread sleepForTimeInterval:0.3];
    
    NSLog(@"Rolling Spider ready for commands");
    readyForCommands = true;
    
    /* Keys:
     escape key - lands and ends session
     f - sends flat trim command
     t - auto takeoff toggle
     + - speed up
     - - slow down
     space bar - land / takeoff toggle
     enter key - tatke a photo
     up arrow - tilt forward
     back arrow - tilt backwards
     right arrow - rotate right
     left arrow - rotate left
     w - ascend
     s - descend
     d - roll right
     a - roll left
    */
    
    
    while(1){
        while(1) {
            
            //autonomous control
            //drone_control(&pitch, &roll, &yaw, &gaz);
            [MDDC setFlag:1];
            //[MDDC setRoll:0];
            //[MDDC setPitch:0];
            [MDDC setRoll:roll];
            [MDDC setPitch:pitch];
            [MDDC setYaw:yaw];
            [MDDC setGaz:gaz];
            [NSThread sleepForTimeInterval:0.016];
            
            /*
            if (fabs(my-0.14)>0.02 ||fabs(mx+0.07)>0.02){
                if (fabs(my-0.14)>0.02) {
                    [MDDC setFlag:1];
                    [MDDC setPitch:(my-0.14)*0.5];
                }
                else{
                    [MDDC setPitch:0];
                }
                //autonomous control
                if (fabs(mx+0.07)>0.02) {
                    [MDDC setFlag:1];
                    [MDDC setRoll:(0.07+mx)*0.5];
                }
                else{
                    [MDDC setRoll:0];
                }
                [NSThread sleepForTimeInterval:0.016];
                 
            }
            else{
                [MDDC setRoll:0];
                [MDDC setPitch:0];
            }
             */
            
             
            //escape
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,53)) {
                commandFound = 1;
                NSLog(@"Landing");
                break;
            }
            //F - flat trim
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,3)) {
                NSLog(@"Flat trim");
                [MDDC sendFlatTrim];
                [NSThread sleepForTimeInterval:0.10];
            }
            //T - auto takeoff toggle
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,17)) {
                [MDDC setFlag:0];
                if(autoTakeoff == 0) {
                    NSLog(@"Auto Takeoff Enabled");
                    [MDDC sendAutoTakeoff:1];
                    autoTakeoff = 1;
                } else {
                    NSLog(@"Auto Takeoff Disabled");
                    [MDDC sendAutoTakeoff:0];
                    autoTakeoff = 0;
                }
                [NSThread sleepForTimeInterval:0.25];
            }
            //+ - faster
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,24)) {
                if(speed < 1.0) {
                    speed += 0.1;
                    NSLog(@"Speeding Up %f", speed);
                }
                [NSThread sleepForTimeInterval:0.10];
            }
            //- - slower
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,27)) {
                if(speed >= 0.1) {
                    speed -= 0.1;
                    NSLog(@"Speeding Down %f", speed);
                }
                [NSThread sleepForTimeInterval:0.10];
            }
            //space - land or takeoff
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,49)) {
                if(land == 1) {
                    NSLog(@"Landing");
                    //Turn off wheels
                    //[MDDC sendWheelsOn:0];
                    //[NSThread sleepForTimeInterval:0.3];
                    [MDDC sendLanding];
                    [NSThread sleepForTimeInterval:1];
                    land = 0;
                } else {
                    NSLog(@"Taking Off");
                    //Turn off wheels
                    //[MDDC sendWheelsOn:1];
                    //[NSThread sleepForTimeInterval:0.3];
                    //Deactivate ability to tilt
                    [MDDC setFlag:0];
                    [MDDC sendFlatTrim];
                    [NSThread sleepForTimeInterval:0.25];
                    [MDDC sendTakeoff];
                    [NSThread sleepForTimeInterval:0.5];
                    [MDDC sendFlatTrim];
                    land = 1;
                }
            }
            //enter key - photo
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,36)) {
                NSLog(@"Taking Photo");
                [NSThread sleepForTimeInterval:0.25];
                [MDDC sendMediaRecordPicture:1];
                [NSThread sleepForTimeInterval:1.0];
            }
            
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,126)) {
                //up arrow - tilt forward
                [MDDC setFlag:1];
                [MDDC setPitch:speed*0.5];
            } else if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,125)) {
                //back arrow - tilt backwards
                [MDDC setFlag:1];
                [MDDC setPitch:-speed*0.5];
            } else {
                [MDDC setPitch:0];
            }
            
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,124)) {
                //right arrow - rotate right
                [MDDC setYaw:speed];
            } else if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,123)) {
                //left arrow - rotate left
                [MDDC setYaw:-speed];
            } else {
                [MDDC setYaw:0];
            }
            
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,13)) {
                //W - up
                [MDDC setGaz:speed*0.5];
            } else if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,1)) {
                //S - down
                [MDDC setGaz:-speed*0.5];
            } else {
                [MDDC setGaz:0];
            }
            
            if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,2)) {
                //D - roll right
                [MDDC setFlag:1];
                [MDDC setRoll:speed*0.5];
            } else if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState,0)) {
                //A - roll left
                [MDDC setFlag:1];
                [MDDC setRoll:-speed*0.5];
            } else {
                [MDDC setRoll:0];
            }
        }
        
        [MDDC sendLanding];
        [NSThread sleepForTimeInterval:2];
        
        [MDDC stop];
        NSLog(@"MDDC Stopped");
    }
    
}


//--------------------------------------------------------------
void testApp::setup(){
    
    MDDC = [[DeviceController alloc] init];
    
    dispatch_queue_t btqueue = dispatch_queue_create("BTQueue", NULL);
    dispatch_async(btqueue,^{
        discover_and_fly_drone();
        //tcflush(STDOUT_FILENO, TCIOFLUSH);
    });
    dispatch_release(btqueue);
    
    ofDisableArbTex();
	ofSetVerticalSync(true);
    ofSetFrameRate(30);
    ofBackground(40, 40, 40);
    //ofSetWindowShape(800, 800);
    ofEnableSmoothing();
    ofEnableDepthTest();
    
    
    // user camera
    
    
    camEasyCam.lookAt(ofVec3f(0,0,0), ofVec3f(0,0,2600));
    camEasyCam.setOrientation(ofVec3f(145,0,0));
    camEasyCam.setDistance(5000);
    camEasyCam.setFov(45);
    camera = &camEasyCam;
    
    
    //graphics
    font.loadFont("DIN.otf", 30);
    
    //drone
    const float origin_x = 0.6;
    const float origin_y = -0.02;
    const float origin_z = 0.7;
    set_x_z_y_o(origin_x,origin_z,origin_y,0.0);
//    printf("result of computation1: %f", 20.0f / 3 * 7); //46.6664
//    printf("result of computation2: %f", (20.0f / 3) * 7); //46.6664
//    printf("result of computation3: %f", 20.0f / (3 * 7)); //0.952381
    printf("***** SETUP: set origin to: [%f,%f,%f]\n",origin_x,origin_y,origin_z);
    start_pid = false;
    roll = 0; pitch = 0; gaz=0; yaw=0;
    
    
    //serial

    serial.setup("/dev/tty.usbmodem1411", 9600);
    serial.startContinuousRead();
    ofAddListener(serial.NEW_MESSAGE,this,&testApp::onNewMessage);
    
    message = "";
 
    
    ofSetFrameRate(30);
}



void testApp::onNewMessage(string & message)
{
    cout << "" << message << "\n";
    if (message=="atom1_active"){
       
        //Kill Atom 
        irCommand = "ATOM1 TAP";
        NSLog(@"ATOM1 TAPPED / DROP");
        [MDDC sendEmergency];
        
        //Kill PID
        start_pid = false;

        //Reset Origin
        set_x_z_y_o(mx, 1.6, my, 0.0); // altitude set to 1.6 for pid
        printf("****** ORIGIN SET TO: [%f,%f,%f]\n",mx,my,1.6);
        lastSetMy = my;
        
        //Enable Auto Take off
        NSLog(@"Auto Takeoff Enabled");
        [MDDC sendAutoTakeoff:1];
        autoTakeoff = 1;
        
        
        
        
        
        
    } else if (message=="atom2_active"){
        //LAND DRONE
        irCommand = "ATOM2 TAP";
        NSLog(@"ATOM1 TAPPED / DROP");
        [MDDC sendEmergency];
        
    } else if (message=="atom3_active"){
        //LAND DRONE
        irCommand = "ATOM3 TAP";
        NSLog(@"ATOM1 TAPPED / DROP");
        [MDDC sendEmergency];
        
    } else if (message=="all_z_up"){
        //ALL DOWN
        irCommand = "ALL UP";
        NSLog(@"ALL UP");
        gaz = 1;
        [NSThread sleepForTimeInterval:0.1];
        
    } else if (message=="all_z_down"){
        //ALL DOWN
        irCommand = "ALL DOWN";
        NSLog(@"ALL DOWN");
        gaz = -1;
        [NSThread sleepForTimeInterval:0.1];

        
    } else if (message=="all_left"){
        //ALL LEFT
        irCommand = "ALL LEFT";
        NSLog(@"ALL LEFT");
        roll =  -1;
        [NSThread sleepForTimeInterval:0.2];

        
    } else if (message=="all_right"){
        //ALL RIGHT
        irCommand = "ALL RIGHT";
        NSLog(@"ALL RIGHT");
        roll = 1;
        [NSThread sleepForTimeInterval:0.2];

        
    } else {
        irCommand = "";
    }
    
    
    gaz = 0;
    roll = 0;
    

    

}

//--------------------------------------------------------------
static bool set_pid_restart = false;
static long long pid_restart_time = 0;

static int path_position = 0;
static int last_path_position = 0;

static long long keep_time = 0;
static bool first_reach = true;


void testApp::update(){
    
    
    
    float _x, _y, _z;
#ifdef VICON
        _x     = *(float *)data->x;
        _y     = *(float *)data->y;
        _z     = *(float *)data->z;
        mr     = *(float *)data->roll;
        mp     = *(float *)data->pitch;
        mya    = *(float *)data->yaw;
        //std::cout << mx << " " << my << " " << mz << " " << mr  << " " << mp << " " << mya << std::endl;
        
        _x*=0.001;
        _y*=0.001;
        _z*=0.001;
#else
        _x     = *(float *)data->x;
        _y     = -*(float *)data->z;
        _z     = *(float *)data->y;
        mr     = *(float *)data->roll;
        mp     = *(float *)data->pitch;
        mya    = *(float *)data->yaw;
#endif
    
    
    if(fabs(_x) > 0.00001 || fabs(_y) > 0.00001 || fabs(_z) > 0.00001){
        mx = _x;
        my = _y;
        mz = _z;
    }
    
    
    if (true){
        if (start_pid){
            drone_control(&pitch, &roll, &yaw, &gaz);
            //sang - reorient
            yaw = 0.3*(mya-0.018);
        }
        else{
            roll = 0;
            pitch = 0;
            yaw = 0;
            gaz = 0;
        }
        
        
        //ardrone.moves(pitch, roll, gaz, yaw);
    }


//    // SQUARE PATH code
//    const float POINT_RADIUS = 0.2;
//    const float SQUARE_SIZE = 0.6;
//    const int KEEP_MILLIS = 400;
//    if (abs(gmx-mx)<POINT_RADIUS && abs(gmy-my)<POINT_RADIUS) {
//        if (first_reach) {
//            first_reach = false;
//            keep_time = ofGetElapsedTimeMillis()+KEEP_MILLIS;
//        } else {
//            if (ofGetElapsedTimeMillis()> keep_time) {
//                path_position=((path_position+1)%4);
//            }
//        }
//    } else {
//        first_reach = true;
//    }
//    
//    if (last_path_position!=path_position) {
//        last_path_position = path_position;
//        
//        switch (path_position) {
//            case 0:
//                gmy+=SQUARE_SIZE;
//                break;
//            case 1:
//                gmx+=SQUARE_SIZE;
//                break;
//            case 2:
//                gmy-=SQUARE_SIZE;
//                break;
//            case 3:
//                gmx-=SQUARE_SIZE;
//                break;
//        }
//        
//    }
    
   
    
//    // SNAPTOGRID code
//    const double SNAPTOGRID_SIZE = 0.3;
//    const double LOITER_SIZE = 0.3;
//    const int PID_SLEEP_TIME_MILLIS = 10000;
//    if (!set_pid_restart && abs(mx-gmx)>LOITER_SIZE) {
//
//        gmx = round(mx/SNAPTOGRID_SIZE)*SNAPTOGRID_SIZE;
//        gmy = round(my/SNAPTOGRID_SIZE)*SNAPTOGRID_SIZE;
//       
//        /*
//        start_pid = false;
//        set_pid_restart = true;
//        pid_restart_time = ofGetElapsedTimeMillis()+PID_SLEEP_TIME_MILLIS;
//        printf("STOPPED PID\n");
//         */
//    }
//    
//    if (set_pid_restart && ofGetElapsedTimeMillis()>pid_restart_time) {
//        printf("RESTARTING PID\n");
//        set_pid_restart = false;
//        start_pid = true;
//    }
//    //set_x_z_y_o(round((mx/SNAPTOGRID_SIZE))*SNAPTOGRID_SIZE, 0.7, lastSetMy, 0.0);
    
    
    if(requestRead)
    {
        cout << "sendRequest\n";
        serial.sendRequest();
        requestRead = false;
    }
    
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    camera->begin();
    nodeGrid.draw();
    
    //boundary
    ofSetColor(255, 255, 0);
    ofSetLineWidth(2);
    ofLine(-533, -1000, my*1000, 620, -1000., my*1000);
    ofLine(620, -1000., my*1000, 620, 325, my*1000);
    ofLine(620, 325, my*1000, -533, 325, my*1000);
    ofLine(-533, 325, my*1000, -533, -1000, my*1000);
    ofSetLineWidth(1);
    
    //goal position
    ofSetColor(255, 0, 0, 80);
    ofDrawBox((gmx*1000)-600, (-mz*1000)+200, gmy*1000, 100);
    ofSetColor(0, 125, 125);
    ofDrawBox((gmx*1000)-600, (-gmz), gmy*1000, 100);
    
    //axis
    ofSetLineWidth(3);
    ofSetColor(255, 0, 0);
    ofLine(0, 0, 0, 800, 0, 0);
    ofSetColor(0, 255, 0);
    ofLine(0, 0, 0, 0, 800, 0);
    ofSetColor(0, 0, 255);
    ofLine(0, 0, 0, 0, 0, 800);
    ofSetLineWidth(1);
    
    //drone position
    ofSetColor(255, 255, 255);
    ofDrawSphere((1000*mx)-600, (-1000*mz)+200, 1000*my, 40);
    ofSetColor(255, 255, 255,40);
    ofDrawSphere((1000*mx)-600, (-gmz), 1000*my, 40);

    
    camera->end();
    
    // Draw annotations (text, gui, etc)
    ofPushStyle();
    glDepthFunc(GL_ALWAYS); // draw on top of everything
    
    
    if (start_pid){
        ofSetColor(255);
    }
    else{
        ofSetColor(125);
    }
    font.drawString("Roll: "+ofToString(mr,4)+" Pitch: "+ofToString(mp,4)+" Yaw: "+ofToString(mya,4), 20, 40);
    font.drawString("X: "+ofToString(mx,4)+" Y: "+ofToString(my,4)+" Z: "+ofToString(mz,4), 20, 80);
    font.drawString("dX: "+ofToString(gmx-mx,4)+" dY: "+ofToString(gmy-my,4)+" dZ: "+ofToString(gmz-mz,4), 20, 120);
    if (MDDC.battery<20) {
        ofSetColor(255,0,0);
    }
    font.drawString("Battery: " + ofToString(MDDC.battery) + " PID: " +  (start_pid?"On":"Off") + (readyForCommands?" READY!":" !!NOT READY!!")+" PathPos: "+ ofToString(path_position), 20, 160);
  
    font.drawString(ofToString("X_PID") + (x_hyster?"(H)":"(-)")+": " + ofToString(gainx[0],2) + " : " + ofToString(gainx[1],7) + " : " + ofToString(gainx[2],2), 20, 680);
    font.drawString(ofToString("Y_PID") + (y_hyster?"(H)":"(-)")+": " + ofToString(gainy[0],2) + " : " + ofToString(gainy[1],7) + " : " + ofToString(gainy[2],2), 20, 730);
    font.drawString(ofToString("Z_PID") + (z_hyster?"(H)":"(-)")+": " + ofToString(gainz[0],2) + " : " + ofToString(gainz[1],7) + " : " + ofToString(gainz[2],2), 20, 780);
    
    font.drawString(irCommand, 740, 780);


    
    
    ofDrawBitmapString(ofToString(ofGetFrameRate())+" fps", 300, 200);
    
    // restore the GL depth function
    glDepthFunc(GL_LESS);
    ofPopStyle();}



//--------------------------------------------------------------
void testApp::keyPressed(int key){
    
    static char whichToChange = 'x';
    
    if (key == ' ') {
        //if (ardrone.onGround()) ardrone.takeoff();
        //else                    ardrone.landing();
    }
    
    if (key == 'p' || key == 'P') {
        start_pid= !start_pid;
    }
    

    
    //SEPERATE KEY LIVE PID
    
//    switch (key) {
//            case 'x':
//            case 'X':
//                whichToChange = 'x';
//            break;
//            case 'y':
//            case 'Y':
//                whichToChange = 'y';
//    }
//    
//
//    if (key == ']') {
//        if (whichToChange == 'x'){
//            gainx[0] = gainx[0] + 0.05;
//        } else {
//            gainy[0] = gainy[0] + 0.05;
//        }
//    }
    
    
    //NUMERIC KEY PID
    
    if (key == '5') {
        gainx[0] = gainx[0] - 0.05;
        gainy[0] = gainy[0] - 0.05;
    }
    
    if (key == '6') {
        gainx[0] = gainx[0] + 0.05;
        gainy[0] = gainy[0] + 0.05;
    }
    if (key == '7') {
        gainx[1] = gainx[1] - 0.00005;
        gainy[1] = gainy[1] - 0.00005;
    }
    
    if (key == '8') {
        gainx[1] = gainx[1] + 0.00005;
        gainy[1] = gainy[1] + 0.00005;
    }
    if (key == '9') {
        gainx[2] = gainx[2] - 0.05;
        gainy[2] = gainy[2] - 0.05;
    }
    
    if (key == '0') {
        gainx[2] = gainx[2] + 0.05;
        gainy[2] = gainy[2] + 0.05;
    }
    
    
    if (key == '!') {
        printf("---------\n");
    }

    
    if(key == 'o' || key == 'O') {
        set_x_z_y_o(mx, 1.6, my, 0.0); // altitude set to 1.6 for pid
        printf("****** ORIGIN SET TO: [%f,%f,%f]\n",mx,my,1.6);
        lastSetMy = my;
    }
    
    if (key == OF_KEY_UP)  { pitch =  1; }
    if (key == OF_KEY_DOWN)  { pitch = -1;}
    if (key == OF_KEY_LEFT)   { roll =  -1; }
    if (key == OF_KEY_RIGHT) { roll = 1; }
    if (key == 'w' || key == 'W')      { gaz =  1; }
    if (key == 's' || key == 'S')      { gaz = -1; }
    if (key == 'd' || key == 'D')      { yaw =  0.5; }
    if (key == 'a' || key == 'A')      { yaw = -0.5; }
    
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
    roll = 0; pitch = 0; gaz = 0; yaw = 0;
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    float click_world_x, click_world_y;
    
    click_world_x = 1.1*(x-ofGetWindowWidth()/2)/400.f;
    click_world_y = -1.1*(y-ofGetWindowHeight()/2)/400.f;
    
    //set_x_z_y_o(click_world_x,click_world_y,0.5,0.0);
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
    float click_world_x, click_world_y;
    
    click_world_x = 1.1*(x-ofGetWindowWidth()/2)/400.f;
    click_world_y = -1.1*(y-ofGetWindowHeight()/2)/400.f;
    
    //set_x_z_y_o(click_world_x,click_world_y,0.5,0.0);
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}
