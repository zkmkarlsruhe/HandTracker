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
 *
 * references: https://google.github.io/mediapipe/solutions/hands.html
 */
#pragma once

#include "ofMain.h"

/// tracked hand
class Hand {

    public:

        Hand() = default;
        virtual ~Hand() {}

        std::vector<float> positions; //< 3d landmark positions
        float palm = 0;               //< palm confidence 0-1
        float landmark = 0;           //< landmark confidence 0-1
        bool detected = false;        //< true if tracker confidence is high enough

        /// finger point indices
        static const struct Fingers {
            std::size_t size = 5;
            std::size_t  thumb[5] = {0,  1,  2,  3,  4};
            std::size_t  index[5] = {0,  5,  6,  7,  8};
            std::size_t middle[5] = {0,  9, 10, 11, 12};
            std::size_t   ring[5] = {0, 13, 14, 15, 16};
            std::size_t  pinky[5] = {0, 17, 18, 19, 20};
        } fingers;

        /// draw landmark points and joint lines
        void draw();

        /// draw joint lines
        void drawLines();

        /// draw landmark points
        void drawPoints();

        /// util to get glm::vec3 from float vector
        glm::vec3 getPointAtIndex(std::size_t index);
};
