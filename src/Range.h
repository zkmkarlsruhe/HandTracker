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

#include "ofMath.h"

/// mapping range: in -> out
typedef struct Range {
    float inmin = 0;
    float inmax = 1;
    float outmin = 0;
    float outmax = 1;

    // map v from input range to clamped output range
    float map(float v) const {
        float min = outmin;
        float max = outmax;
        if(min > max) {
            min = outmax;
            max = outmin;
        }
        return ofClamp(ofMap(v, inmin, inmax, outmin, outmax), min, max);
    }
} Range;
