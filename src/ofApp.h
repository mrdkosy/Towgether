#pragma once

#include "ofxiOS.h"
#include "ofxBox2d.h"
#include "ofxiOSImagePicker.h"

#define FINGER_NUM 4
#define PARTICLE_NUM 4

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
        void loop();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
    int angle, modeManage;
    
    //box2d
    ofxBox2d box2d;                             // Box2Dの世界
    vector <ofPtr <ofxBox2dCircle> >    circles;    // 円の配列
    vector <ofPtr <ofxBox2dRect> > boxes;        // 四角の配列
    vector <ofColor*> color;
    ofColor boxColor[4];
    vector <ofVec2f>box2dPos;
    
    
    //finger
    int touchON_OFF(); //指を枠内に固定しているか
    ofVec2f fingerPos[FINGER_NUM], fErea[2];
    int fingerID[FINGER_NUM], fEreaRadius;
    
    //game play or over
    bool gameMode;
    
    //main circle
    vector<ofVec2f> mainCircePos;
    void mainCirceProducer();
    vector<int> ONorOFF;
    
    //particle
    void particleProducer(ofVec3f v, int m, int ni);
    vector<ofVec3f>particlePos; //x, y, frame
    vector<int> PARTICLE_MODE;
    int ran[10][2], onlyOne, num;
    
    //barrier
    ofVec4f barrier[4];
    void barrierDraw();
    int barrierNumber, barrierWidth, bGameOut[3], mbariNumber;
    
    //rank
    int score, thenFrame, sumScore;
    void rankUp();
    ofImage levelUp;
    bool hSwitch;
    
    
    //point cloud
    ofImage image;
    ofMesh mesh;
    vector<ofColor> photoColor;
    vector<ofPoint> photoPosition, meshPosition;
    vector<bool>viewMode;
    bool photoMode;
    void pointCloudSetup(int mode);
    int drawPointNum;
    vector<ofVec2f> pointSpeed;

    
    
    //camera
    ofxiOSImagePicker camera;
    ofImage	photo;
    ofPoint imgPos;
    ofPoint prePoint;
    
    ofVec2f photoSize;
    void pixelSet();
    void pixelDispersion();
    
    //score
    ofTrueTypeFont font;
    
    
};


