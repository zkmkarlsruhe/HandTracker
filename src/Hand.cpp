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
#include "Hand.h"

const Hand::Fingers Hand::fingers;

void Hand::draw() {
    drawLines();
    drawPoints();
}

void Hand::drawLines() {
    ofNoFill();
    ofSetColor(255);
    ofSetLineWidth(5);

    // thumb
    ofBeginShape();
    for(int i = 0; i < fingers.size; ++i) {
        ofVertex(getPointAtIndex(fingers.thumb[i]));
    }
    ofEndShape();

    // index finger
    ofBeginShape();
    for(int i = 0; i < fingers.size; ++i) {
        ofVertex(getPointAtIndex(fingers.index[i]));
    }
    ofEndShape();

    // middle finger
    ofBeginShape();
    for(int i = 0; i < fingers.size; ++i) {
        ofVertex(getPointAtIndex(fingers.middle[i]));
    }
    ofEndShape();

    // ring finger
    ofBeginShape();
    for(int i = 0; i < fingers.size; ++i) {
        ofVertex(getPointAtIndex(fingers.ring[i]));
    }
    ofEndShape();

    // pinky finger
    ofBeginShape();
    for(int i = 0; i < fingers.size; ++i) {
        ofVertex(getPointAtIndex(fingers.pinky[i]));
    }
    ofEndShape();

    ofSetLineWidth(1);
}

void Hand::drawPoints() {
    ofFill();
    ofSetRectMode(OF_RECTMODE_CENTER);
    for(int i = 0; i < positions.size(); i += 3) {
        auto x = positions[i];
        auto y = positions[i+1];
        auto z = positions[i+2];
        ofSetColor(120, 120-z*10, 0);
        ofDrawRectangle(x, y, z, 2, 2);
    }
    ofSetRectMode(OF_RECTMODE_CORNER);
}

glm::vec3 Hand::getPointAtIndex(std::size_t index) {
    std::size_t i = index * 3;
    return glm::vec3(positions[i], positions[i + 1], positions[i + 2]);
}
