/*
 * HandTracker
 *
 * Copyright (c) 2021 ZKM | Hertz-Lab
 * Dan Wilcox <dan.wilcox@zkm.de>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * This code has been developed at ZKM | Hertz-Lab as part of „The Intelligent
 * Museum“ generously funded by the German Federal Cultural Foundation.
 */
#pragma once

#include "ofMain.h"
#include "ofxTensorFlow2.h"
#include "ofxOsc.h"
#include "Hand.h"
#include "Range.h"

class ofApp : public ofBaseApp {

    public:
        void setup();
        void update();
        void draw();
        void exit();

        void keyPressed(int key);
        void keyReleased(int key);
        void mouseMoved(int x, int y);
        void mouseDragged(int x, int y, int button);
        void mousePressed(int x, int y, int button);
        void mouseReleased(int x, int y, int button);
        void mouseEntered(int x, int y);
        void mouseExited(int x, int y);
        void windowResized(int w, int h);
        void dragEvent(ofDragInfo dragInfo);
        void gotMessage(ofMessage msg);

        bool debug = true; //< shown debug view?
        bool mirror = true; //< mirror camera input horizontally?
        bool wireframe = true; //< draw hand wireframe?
        bool run = true; //< run tracking? set = false to save CPU

        bool newInput = false; //< is there new input to process?

        // neural network I/O
        ofxTF2::ThreadedModel model;
        cppflow::tensor input;
        ofImage imgOut;
        Hand hand;
        struct Threshold {
            float palm = 0.01;
            float landmark = 0.25;
        } threshold;
        const float nnWidth = 224;
        const float nnHeight = 224;

        // video input
        ofVideoGrabber vidIn;
        const float camWidth = 640;
        const float camHeight = 480;

        // mappings
        struct Mapping {
            Range pinch = {110, 20, 0, 1};
            Range spread = {64, 120, 0, 1};
        } mapping;

        // OSC
        ofxOscSender sender;
};
