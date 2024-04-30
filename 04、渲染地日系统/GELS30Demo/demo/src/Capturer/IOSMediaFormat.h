//
//  IOSMediaFormat.h
//  IOS
//
//  Created by wakeyang on 2018/6/21.
//  Copyright © 2018年 IOS. All rights reserved.
//

#ifndef IOSMediaFormat_h
#define IOSMediaFormat_h

typedef struct _IOSAudioFormat
{
    int sample_rate;
    int sample_bits;
    int channels;
    float duration;
} IOSAudioFormat;

typedef struct _IOSVideoFormat
{
    int width;
    int height;
    int degree;
    float frame_rate;
    float duration;
} IOSVideoFormat;

#define    MEDIA_MASK_VIDEO 1
#define    MEDIA_MASK_AUDIO 2

typedef struct _IOSMediaFormat
{
    int mask ;

    IOSVideoFormat video_format;
    IOSAudioFormat audio_format;
} IOSMediaFormat;

#endif /* IOSMediaFormat_h */
