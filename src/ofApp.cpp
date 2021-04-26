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
#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
	ofSetFrameRate(60);
	ofSetVerticalSync(true);
	ofSetWindowTitle("Hand Tracker");
    ofEnableAlphaBlending();
    //ofSetLogLevel("HandTracker", OF_LOG_VERBOSE);

	// setup model
	if(!model.load("model")) {
		std::exit(EXIT_FAILURE);
	}
	std::vector<std::string> inputNames = {
		"input_1"
	};
	std::vector<std::string> outputNames = {
		"Identity",
		"Identity_1",
        "Identity_2"
	};
	model.setup(inputNames, outputNames);

	// setup video grabber
	vidIn.setDesiredFrameRate(60);
	vidIn.setup(camWidth, camHeight);

	// allocate output image
	imgOut.allocate(nnWidth, nnHeight, OF_IMAGE_COLOR);
    imgOut.getTexture().setTextureMinMagFilter(GL_NEAREST, GL_NEAREST);

	// start the model!
	model.setIdleTime(16); // check every frame, responsive but save some CPU
	model.startThread();

    // osc
    sender.setup("localhost", 9999);
}

//--------------------------------------------------------------
void ofApp::update() {

	// create tensor from video frame
	vidIn.update();
	if(run && vidIn.isFrameNew()) {
		// get the frame, resize, and copy to tensor
		ofPixels & pixels = vidIn.getPixels();
		ofPixels resizedPixels(pixels);
		resizedPixels.resize(nnWidth, nnHeight);
		input = ofxTF2::pixelsToTensor(resizedPixels);
		input = cppflow::cast(input, TF_UINT8, TF_FLOAT);
		input = cppflow::div(input, {255.0f});
		input = cppflow::expand_dims(input, 0);
		imgOut.setFromPixels(resizedPixels);
		imgOut.update();
		newInput = true;
	}

	// thread-safe conditional input update
	if(newInput && model.readyForInput()) {
		model.update(input);
		newInput = false;
	}

	// thread-safe conditional output update
	if(model.isOutputNew()) {
		auto outputs = model.getOutputs();

		// get the landmarks 
		ofxTF2::tensorToVector(outputs[0], hand.positions);

		// check whether hand is present
		// outputs[1] is a scalar... conversion to scalar may be better
		std::vector<float> palm, landmark;
        ofxTF2::tensorToVector(outputs[2], palm);
        ofxTF2::tensorToVector(outputs[1], landmark);
        hand.palm = palm[0];
        hand.landmark = landmark[0];

        bool pdetected = hand.detected;
        hand.detected = (hand.palm >= threshold.palm &&
                         hand.landmark >= threshold.landmark);
        if(hand.detected != pdetected) {
            ofLogVerbose("HandTracker") << "detected: " << hand.detected;
            ofxOscMessage message;
            message.setAddress("/detected");
            message.addFloatArg(hand.detected);
            sender.sendMessage(message);
        }
        if(hand.detected) {
            ofxOscMessage message;
            glm::vec3 thumbTip = hand.getPointAtIndex(Hand::fingers.thumb[Hand::fingers.size-1]);
            glm::vec3 middleTip = hand.getPointAtIndex(Hand::fingers.middle[Hand::fingers.size-1]);
            glm::vec3 palmCenter = hand.getPointAtIndex(Hand::fingers.thumb[0]);

            // pinch
            float dist = glm::distance(thumbTip, middleTip);
            float pinch = mapping.pinch.map(dist);
            ofLogVerbose("HandTracker") << "pinch: " << pinch << " dist: " << dist;
            message.setAddress("/pinch");
            message.addFloatArg(pinch);
            sender.sendMessage(message);

//            // palm
//            float palm = mapping.palm.map(palmCenter.z);
//            ofLogVerbose("HandTracker") << "palm: " << palm << " z: " << palmCenter.z;
//            message.clear();
//            message.setAddress("/palm");
//            message.addFloatArg(palm);
//            sender.sendMessage(message);
//
//            // rotation
//            float angle = ofRadToDeg(glm::angle(glm::normalize(middleTip), glm::normalize(palmCenter)));
//            float rotation = mapping.rotation.map(angle);
//            ofLogVerbose("HandTracker") << "rotation: " << rotation << " angle: " << angle;
//            message.clear();
//            message.setAddress("/rotation");
//            message.addFloatArg(rotation);
//            sender.sendMessage(message);
        }
	}
}

//--------------------------------------------------------------
void ofApp::draw() {
    // TODO: doesn't handle aspect ratio differences...

    // web cam full res image background
    ofPushMatrix();
        if(mirror) {
            ofTranslate(ofGetWidth(), 0);
            ofScale(-ofGetWidth() / vidIn.getWidth(),
                    ofGetHeight() / vidIn.getHeight());
        }
        else {
            ofScale(ofGetWidth() / vidIn.getWidth(),
                    ofGetHeight() / vidIn.getHeight());
        }
        ofSetColor(255);
        vidIn.draw(0, 0);
    ofPopMatrix();

    ofPushMatrix();
        if(mirror) {
            ofTranslate(ofGetWidth(), 0);
            ofScale(-ofGetWidth() / imgOut.getWidth(),
                    ofGetHeight() / imgOut.getHeight());
        }
        else {
            ofScale(ofGetWidth() / imgOut.getWidth(),
                    ofGetHeight() / imgOut.getHeight());
        }

        // low res nn image overlay
        if(debug && run) {
            ofSetColor(255, 255, 255, 200);
            imgOut.draw(0, 0);
        }

        // detected hand
        if(hand.detected) {
            if(debug) {
                hand.draw();
            }
            else if(wireframe) {
                hand.drawLines();
            }
        }
    ofPopMatrix();

	// draw info
    if(debug) {
        std::string text;
        text = ofToString((int)ofGetFrameRate()) + " fps\n";
        text += "[/] inc/dec palm thresh\n";
        text += "+/- inc/dec landmark thresh\n";
        text += "d   show/hide debug view\n";
        text += "p   pause/unpause tracker\n";
        text += "w   show/hide hand wireframe\n";
        text += "detection thresholds:\n";
        text += "palm " + ofToString(threshold.palm) + "\n";
        text += "landmark " + ofToString(threshold.landmark) + "\n";
        text += "detection scores:\n";
        text += "palm " + ofToString(hand.palm, 2) + "\n";
        text += "landmark " + ofToString(hand.landmark, 2);
        ofDrawBitmapStringHighlight(text, ofGetWidth() - 220, 12);
    }
}

//--------------------------------------------------------------
void ofApp::exit() {
    if(hand.detected) {
        ofLogVerbose("HandTracker") << "detected: " << false;
        ofxOscMessage message;
        message.setAddress("/detected");
        message.addFloatArg(0);
        sender.sendMessage(message);
    }
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
	switch(key) {
        case '+': case '=':
            threshold.landmark = ofClamp(threshold.landmark + 0.01, 0, 1);
			break;
        case '-':
            threshold.landmark = ofClamp(threshold.landmark - 0.01, 0, 1);
            break;
        case ']':
            threshold.palm = ofClamp(threshold.palm + 0.01, 0, 1);
            break;
        case '[':
            threshold.palm = ofClamp(threshold.palm - 0.01, 0, 1);
            break;
        case 'd':
        debug = !debug;
        break;
        case 'p':
            run = !run;
            break;
        case 'w':
            wireframe = !wireframe;
            break;
	}
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {

}
