#include "ofMain.h"
#include "testApp.h"
#include "ofAppGLUTWindow.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <unistd.h>

//========================================================================
testApp* app;
void* mocap_thread(void* param);

int main( ){
    app = new testApp();
    
    pthread_t tid;
    int thread_param;
    pthread_create(&tid, NULL, mocap_thread, (void*)&thread_param);
    
    ofAppGlutWindow* window = new ofAppGlutWindow();
	ofSetupOpenGL(window, 1000, 800, OF_WINDOW);			// <-------- setup the GL context

	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( app );
    

}


void* mocap_thread(void* param)
{
    //WSAData wsaData;
    int sock;
    struct sockaddr_in addr;
    int i_port = 10080;
    
    //WSAStartup(MAKEWORD(2,0), &wsaData);
    
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons(i_port);
    addr.sin_addr.s_addr = INADDR_ANY;
    
    bind(sock, (struct sockaddr *)&addr, sizeof(addr));
    
    app->data = (testApp::MocapFormat *)malloc(sizeof(testApp::MocapFormat));
    unsigned char recvData[28];
    
    while(1){
        recv(sock, (char *)recvData, sizeof(recvData),0);
        app->data = (testApp::MocapFormat *)recvData;
    }
    close(sock);
    //WSACleanup();
    
    getchar();
    return 0;
}

