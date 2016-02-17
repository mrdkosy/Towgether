#include "ofApp.h"
#define SCALE 0.4
//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(0);
    ofSetVerticalSync(true);
    ofxAccelerometer.setup();
    ofxiPhoneSetOrientation(ofxiPhone_ORIENTATION_LANDSCAPE_LEFT);
    ofSetCircleResolution(100);
    ofEnableAlphaBlending();
    
    ofRegisterTouchEvents(this);
    ofxAccelerometer.setup();
    ofxiPhoneAlerts.addListener(this);
    
    box2d.init();
    box2d.setGravity(0, 10);
    box2d.createBounds();
    box2d.setFPS(30.0);
    box2d.registerGrabbing();
    box2d.setIterations(5, 5); //インタラクションの精度を設定
    ofSetFrameRate(60);
    
    loop();
    sumScore = 0;
    score = 0;
    modeManage = 0;
    
    //box2d
    boxColor[0] = ofColor(0, 173, 182);
    
    
    //game manage
    gameMode = true;
    
    //barrier
    barrierWidth = 50;
    barrier[0].set(0, 0, barrierWidth, ofGetHeight());
    barrier[1].set(0, 0, ofGetWidth(), barrierWidth);
    barrier[2].set(ofGetWidth()-barrierWidth, 0, barrierWidth, ofGetWidth());
    barrier[3].set(0, ofGetHeight()-barrierWidth, ofGetWidth(), barrierWidth);
    barrierNumber = 0;
    mbariNumber = 0;
    bGameOut[0] = barrierWidth;
    bGameOut[1] = ofGetWidth()-barrierWidth;
    bGameOut[2] = ofGetHeight()-barrierWidth;
    
    //rank
    levelUp.load("levelup.png");
    
    //camera
    camera.setMaxDimension(MAX(1024, ofGetHeight()));
    camera.openCamera();
    
    //font
    font.load("Campton-LightDEMO.otf", 80);
    
}
//--------------------------------------------------------------
void ofApp::pointCloudSetup(int imode){
    //image
    image.clone(photo);
    mesh.setMode(OF_PRIMITIVE_POINTS);
    int skip = 20;
    for(int y = 0; y < image.getHeight(); y += skip) {
        for(int x = 0; x < image.getWidth(); x += skip) {
            ofColor cur = image.getColor(x, y);
            mesh.addColor(cur);
            ofVec3f pos(x,y,0);
            mesh.addVertex(pos);
            photoColor.push_back(ofColor(cur));
            photoPosition.push_back(ofPoint(pos));
            if(imode == 1){
                meshPosition.push_back(ofPoint(photoPosition.back()));
                pointSpeed.push_back(ofVec2f(ofRandom(-5, 5), ofRandom(-5, 5)));
            }else if(imode == 2){
                meshPosition.push_back(ofPoint(ofRandom(-ofGetWidth()*2, ofGetWidth()*2),
                                               ofRandom(-ofGetHeight()*2, ofGetHeight()*2), 0));
            }
        }
    }
    photoMode = false;
    drawPointNum = sumScore;
    cout << drawPointNum << endl;
    if(drawPointNum > photoPosition.size()){
        drawPointNum = photoPosition.size();
    }
    
}
//--------------------------------------------------------------
void ofApp::loop(){
    //finger
    for(int i=0; i<FINGER_NUM; i++){//fingerIDの初期化
        fingerID[i] = -1;
        fingerPos[i].set(-1000, -1000);
    }
    
    //fErea
    int trans = 50;
    fErea[0].set(trans, trans);
    fErea[1].set(ofGetWidth()-trans, ofGetHeight()-trans);
    fEreaRadius = 40;
    
    //main circle
    for(int i=0; i<15; i++){
        mainCircePos.push_back(ofVec2f(-10000, -10000));
        ONorOFF.push_back(-10000);
    }
    
    //particle
    for(int i=0; i<15; i++){
        particlePos.push_back(ofVec3f(-10000, -10000, 0));
        PARTICLE_MODE.push_back(-1);
    }
    
    //box2d
    circles.clear();
    color.clear();
    box2dPos.clear();
    
    //rank up
    thenFrame = -1;
    hSwitch = true;
    
}
//--------------------------------------------------------------
void ofApp::update(){
    if(modeManage == 0){
        if(camera.getImageUpdated()){
            
            photo.setFromPixels(camera.getPixelsRef());
            
            imgPos.x = 0;
            //        imgPos.y = camRect.getBottom() + 20;
            imgPos.y = 0;
            
            photoSize.x = ofGetHeight();
            photoSize.y = photo.getHeight() * (ofGetHeight()/photo.getWidth());
            
            image.clone(photo);
//            pointCloudSetup(1);
            
//            for(int i=0; i<photoPosition.size(); i++){
//                meshPosition.at(i).x += pointSpeed.at(i).x;
//                meshPosition.at(i).y += pointSpeed.at(i).y;
//            }
//            
            pixelDispersion();//pixel分散モード

            camera.close();
        }
        
    }else if(modeManage == 1){
        box2d.update();
        ofPoint gravity = ofxAccelerometer.getForce();
        gravity *= 5.0;
        gravity.y *= -1.0;
        gravity.x *= -1.0;
        gravity.z = 0;
        box2d.setGravity(ofPoint(gravity.y, gravity.x, 0));
        //    cout << gravity << endl;
        
    }else if(modeManage == 2){
        int late = 20;
        if(photoMode == true){
            for(int i=0; i<drawPointNum; i++){
                meshPosition.at(i).x += (photoPosition.at(i).x - meshPosition.at(i).x)/late;
                meshPosition.at(i).y += (photoPosition.at(i).y - meshPosition.at(i).y)/late;
            }
        }
    }
    
    
}
//--------------------------------------------------------------
void ofApp::pixelDispersion(){//pixcelを分散
    /*
    ofPushMatrix();
    {
        ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
        ofRotateY(90);
        ofRotateX(180);
        ofScale(SCALE, -SCALE, SCALE);
        ofRotateY(90);
        ofTranslate(-image.getWidth() / 2, -image.getHeight() / 2);
        
        for(int i=0; i<photoPosition.size(); i++){
            ofSetColor(photoColor.at(i), 255);
            cout << meshPosition.at(i).x << endl;
            ofDrawCircle(meshPosition.at(i), 10);
        }
        ofSetColor(255, 80);
        image.draw(0, 0,  image.getWidth(), image.getHeight());
    }
    ofPopMatrix();
     */
    
    
    modeManage = 1;
    
}
//--------------------------------------------------------------
void ofApp::pixelSet(){//pixelを集合
    ofPushMatrix();
    {
        ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
        ofRotateY(90);
        ofRotateX(180);
        ofScale(SCALE, -SCALE, SCALE);
        ofRotateY(90);
        ofTranslate(-image.getWidth() / 2, -image.getHeight() / 2);
        
        for(int i=0; i<drawPointNum; i++){
            //                if(viewMode.at(i)){
            ofSetColor(photoColor.at(i), 255);
            ofDrawCircle(meshPosition.at(i), 10);
            //                }
        }
        ofSetColor(255, 80);
        image.draw(0, 0,  image.getWidth(), image.getHeight());
        ofSetColor(255, 255);
    }
    ofPopMatrix();
    font.drawString(ofToString(sumScore), 10, 90);
    
}
//--------------------------------------------------------------
void ofApp::particleProducer(ofVec3f v, int m, int ni){
    int time = ofGetFrameNum()-v.z;
    //v.x,v.y: position, v.z:frame, m:particle_mode, ni:particle number
    if(m == 0){
        ofSetLineWidth(1);
        ofSetColor(255, 200);
        ofNoFill();
        ofDrawCircle(v.x, v.y, 20+(time*2) );
    }else if(m == 1){
        ofPushStyle();
        ofSetColor(255, 255, 255, 120);
        ofSetCircleResolution(3);
        ofFill();
        for(int j=0; j<3; j++){
            ofDrawCircle( time*20-80*j, v.y, 25);
            ofDrawCircle(v.x, time*20-80*j, 25);
        }
        ofPopStyle();
    }else if(m == 2){
        ofPushStyle();
        ofFill();
        ofSetColor(255, 200);
        int count = time/2;
        if(count > 10){
            count = 10;
            num -= 1;
            if(num < 0){
                num = 0;
            }
        }else{
            num = 10;
        }
        for(int i=10-num; i<count; i++){
            int w = 65;
            ran[i][0] = w*cos(ofDegToRad( (360/10)*i ));
            ran[i][1] = w*sin(ofDegToRad( (360/10)*i ));
            if(ni == onlyOne-1){
                ofDrawCircle(v.x+ran[i][0], v.y+ran[i][1], ofRandom(1,5));
            }
        }
        ofPopStyle();
    }else if (m == 3){
        ofPushMatrix();
        ofPushStyle();
        ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
        ofSetLineWidth(ofRandom(1, 15));
        ofSetCircleResolution(6);
        ofNoFill();
        ofRotateZ(ofGetFrameNum()*8);
        ofSetColor(255, 255-time*10);
        if(ni == onlyOne-1)ofDrawCircle(0, 0, (ofGetHeight()*0.8)/2 );
        ofPopStyle();
        ofPopMatrix();
    }
}
//--------------------------------------------------------------
int ofApp::touchON_OFF(){
    ofNoFill();
    ofSetLineWidth(5);
    ofSetColor(255);
    ofDrawCircle(fErea[0], fEreaRadius);
    ofDrawCircle(fErea[1], fEreaRadius);
    
    if(
       ( (ofDist(fingerPos[0].x, fingerPos[0].y, fErea[0].x, fErea[0].y) < fEreaRadius) &&
        (ofDist(fingerPos[1].x, fingerPos[1].y, fErea[1].x, fErea[1].y) < fEreaRadius) )
       || ((ofDist(fingerPos[1].x, fingerPos[1].y, fErea[0].x, fErea[0].y) < fEreaRadius) &&
           (ofDist(fingerPos[0].x, fingerPos[0].y, fErea[1].x, fErea[1].y) < fEreaRadius)) ) {
           gameMode = true;
           ofFill();
           ofSetColor(255, 100);
           ofDrawCircle(fErea[0], fEreaRadius);
           ofDrawCircle(fErea[1], fEreaRadius);
           return 1;
       }else{
           gameMode = false;
           return 0;
       }
}
//--------------------------------------------------------------
void ofApp::mainCirceProducer(){
    if (ofGetFrameNum()%50 == 0) {
        ofVec2f v;
        v.set(ofRandom(fEreaRadius,ofGetWidth()-fEreaRadius),
              ofRandom(fEreaRadius,ofGetHeight()-fEreaRadius));
        while( ofDist(v.x, v.y, fErea[0].x, fErea[0].y) < fEreaRadius+20 ||
              ofDist(v.x, v.y, fErea[1].x, fErea[1].y) < fEreaRadius+20 ||
              v.x - fEreaRadius< bGameOut[0] || v.x > bGameOut[1]-fEreaRadius ||
              v.y - fEreaRadius < bGameOut[0] || v.y > bGameOut[2]-fEreaRadius
              ){
            v.set(ofRandom(ofGetWidth()), ofRandom(ofGetHeight())); //randomに白円を描画
        }
        mainCircePos.push_back(v);
        ONorOFF.push_back(255);
    }
    
    
    ofSetColor(255, 255);
    int radius = 20;
    for(int i=mainCircePos.size()-15; i<mainCircePos.size(); i++){
        if(ofDist(fingerPos[2].x, fingerPos[2].y, mainCircePos.at(i).x, mainCircePos.at(i).y) < radius*1.1||
           ofDist(fingerPos[3].x, fingerPos[3].y, mainCircePos.at(i).x, mainCircePos.at(i).y) < radius*1.1){
            if(ONorOFF.at(i) != 0){
                ONorOFF.at(i) = 0;
                //particleの位置を指定
                particlePos.push_back(ofVec3f(mainCircePos.at(i).x, mainCircePos.at(i).y, ofGetFrameNum()));
                PARTICLE_MODE.push_back(ofRandom(0, PARTICLE_NUM));
                onlyOne = particlePos.size();
                
                //************************************
                //box2dをpush
                ofVec2f cPos;
                cPos.x = mainCircePos.at(i).x;
                cPos.y = mainCircePos.at(i).y;
                for(int j=0; j<3; j++){
                    float r = ofRandom(8, 15);
                    box2dPos.push_back(ofVec2f(cPos.x+ofRandom(-50, 50), cPos.y+ofRandom(-50, 50)));
                    circles.push_back(ofPtr<ofxBox2dCircle>(new ofxBox2dCircle));
                    circles.back().get()->setPhysics(3.0, 0.1, 0.1);//density bounce friction
                    circles.back().get()->setup(box2d.getWorld(),box2dPos.back().x,box2dPos.back().y, r);
                    color.push_back(new ofColor);
                    color.back() -> set(boxColor[0].r, boxColor[0].g, boxColor[0].b);
                }
                //************************************
                
            }
        }
        ofFill();
        ofSetColor(255, ONorOFF.at(i));
        ofDrawCircle(mainCircePos.at(i).x, mainCircePos.at(i).y, radius);
    }
    
}
//--------------------------------------------------------------
void ofApp::barrierDraw(){
    ofSetLineWidth(4);
    ofSetColor(255, 255, 255, 150);
    int bTurn = ofGetFrameNum()%480;
    if(bTurn == 0){
        barrierNumber = mbariNumber;
    }else if(bTurn == 330){
        mbariNumber = ofRandom(0, 4);
    }else if(bTurn > 330){
        ofNoFill();
        ofSetColor(255, 255, 255, ofRandom(150));
        ofDrawRectangle(barrier[mbariNumber].x, barrier[mbariNumber].y, barrier[mbariNumber].z, barrier[mbariNumber].w);
        ofSetColor(255, 255, 255, ( ofGetFrameNum()*10 )%150);
    }
    //barrierを描画
    ofFill();
    ofDrawRectangle(barrier[barrierNumber].x, barrier[barrierNumber].y, barrier[barrierNumber].z, barrier[barrierNumber].w);
    
    //    box2dがbarrier内に入ったか
    for(int i=0; i<box2dPos.size(); i++){
        if( (barrierNumber == 1 && box2dPos.at(i).y < bGameOut[0]) ||
           (barrierNumber == 2 && box2dPos.at(i).x > bGameOut[1]) ||
           (barrierNumber == 3 && box2dPos.at(i).y > bGameOut[2]) ||
           (barrierNumber == 0 && box2dPos.at(i).x < bGameOut[0]) ){
            ofSetColor(255, 0, 0);
            ofFill();
            //game over モードへ
            if(hSwitch){
                pointCloudSetup(2);
                modeManage = 2;
            }
        }
        
    }
}
//--------------------------------------------------------------
void ofApp::rankUp(){
    int f = ofGetFrameNum() - thenFrame;
    ofPushStyle();
    if(f == 0){
        hSwitch = false;
    }else if(f < 150){
        ofSetColor(0, 0, 0, f);
        ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
        ofSetColor(255, f*2);
        float w = ofGetWidth()*0.75;
        float h = levelUp.getHeight() * (w/levelUp.getWidth());
        levelUp.draw(ofGetWidth()/2 - w/2, ofGetHeight()/2 - h/2, w, h);
    }else if(f == 150){
        score += box2dPos.size();
        loop();
    }
    ofPopStyle();
}
//--------------------------------------------------------------
void ofApp::draw(){
    if(modeManage == 0){
        if(photo.isAllocated()){
            ofPushMatrix();
            ofRotateZ(-90);
            ofTranslate(-ofGetHeight(), ofGetWidth()/2-photoSize.y/2);
            photo.draw(imgPos.x, imgPos.y, photoSize.x, photoSize.y);
            ofPopMatrix();
        }
    }else if(modeManage == 1){
        //box2d
        ofFill();
        ofSetLineWidth(1);
        for(int i=0; i<circles.size(); i++){
            ofSetColor(color.at(i)->r, color.at(i)->g, color.at(i)->b);
            circles[i].get()->draw();
            box2dPos.at(i) = circles[i].get()->getPosition();
        }
        
        //touch
        if( touchON_OFF() ){
            mainCirceProducer();
            for(int i=particlePos.size()-15; i<particlePos.size(); i++){
                particleProducer(particlePos.at(i), PARTICLE_MODE.at(i), i);
                
            }
            barrierDraw();
        }
        
        //score
        sumScore = box2dPos.size() + score;
        if (sumScore%30 == 0 && sumScore!=0 && PARTICLE_MODE.back() != -1) {
            thenFrame = ofGetFrameNum();
        }
        
        //rank up
        if(thenFrame > 0){
            rankUp();
        }
    }else if(modeManage == 2){
        pixelSet();
    }
    
    //指の位置を初期化
    fingerPos[2].set(-100, -100);
    fingerPos[3].set(-100, -100);
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    //指のid, 位置を格納
    if(touch.id < FINGER_NUM){
        if(fingerID[touch.id] < 0){
            fingerID[touch.id] = touch.id;
            fingerPos[touch.id].x = touch.x;
            fingerPos[touch.id].y = touch.y;
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    //指の位置を更新
    fingerPos[touch.id].x = touch.x;
    fingerPos[touch.id].y = touch.y;
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //id, posを初期化
    fingerID[touch.id] = -1;
    fingerPos[touch.id].set(-1000, -1000);
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    photoMode = true;

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}
