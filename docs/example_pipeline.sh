#!/bin/sh

# export environment
export GST_REGISTRY=/tmp/gst_registry.bin
export LD_LIBRARY_PATH=/opt/gstreamer/lib
export GST_PLUGIN_PATH=/opt/gstreamer/lib/gstreamer-0.10
export PATH=/opt/gstreamer/bin:$PATH
export GST_PLUGIN_SCANNER=/opt/gstreamer/libexec/gstreamer-0.10/gst-plugin-scanner

# pipeline decode elemenatry H.264 stream
gst-launch -v filesrc location=sample.264 ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec framerate=30 ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink sync=false

# play MPEG-2 elementary stream 
gst-launch -v filesrc location=sample.m2v typefind=true ! mpegvideoparse ! omx_mpeg2dec framerate=30 ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink 


# pipeline to decode MP4 container (H.264 + AAC)
gst-launch filesrc location="sample.mp4" ! qtdemux name=demux demux.audio_00 ! queue ! faad ! alsasink demux.video_00 ! queue ! h264parse ! omx_h264dec ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink 

# pipeline to decode H.264 video streamed over RTSP/RTP
gst-launch rtspsrc location=rtsp://172.24.136.242:5544/test ! rtph264depay ! h264parse access-unit=true ! omx_h264dec ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink sync=false 

# play mpeg2 ts file with MPEG-2 HD video and AC3 audio (progressive content)
gst-launch -v filesrc location=sample.ts typefind=true ! ffdemux_mpegts name=demux demux.video_00 ! queue ! mpegvideoparse ! omx_mpeg2dec ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink demux.audio_00 ! queue ! ffdec_ac3 ! alsasink 

# play mpeg2 ts file with H264 video using V4l2 sink
gst-launch -v filesrc location=tekken6.ts ! mpegtsdemux ! h264parse output-format=1 access-unit=true ! omx_h264dec ! omx_scaler ! v4l2sink min-queued-bufs=3 

# play WMV stream 
gst-launch -v filesrc location=sample.wmv ! asfdemux name=demux demux.video_00 ! queue ! omx_vc1dec ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink demux.audio_00 ! queue ! ffdec_wmav2 ! audioconvert ! audioresample ! audiorate ! 'audio/x-raw-int,rate=48000,channels=2' ! alsasink 

# pipeline to scale the decoded video to 720P using omx_scaler element
gst-launch filesrc location=sample.264 ! typefind ! h264parse access-unit=true ! omx_h264dec ! omx_scaler ! 'video/x-raw-yuv,width=1280,height=720' ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink sync=false -v 

# pipeline to crop the decoded video to using omx_scaler element
gst-launch -v filesrc location=/usr/share/ti/data/videos/dm816x_1080p_demo.264  ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec ! omx_scaler cropstartx=0 cropstarty=0 cropwidth=960 cropheight=540 ! 'video/x-raw-yuv,width=960,height=540' ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink

# play mp4 using playbin2
gst-launch playbin2 uri=file:///home/root/sample.mp4 -v 


# Mosaic 4 decoded H.264 elementary streams from file input, each of 1280x720 size, into one video output stream of 1270x720 size
gst-launch omx_videomixer framerate=30 port-index=0 name=mix ! v4l2sink userpointer=true filesrc location=sample_1.h264 ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec ! mix. filesrc location=sample_2.h264 ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec ! mix. filesrc location=sample_3.h264 ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec ! mix. filesrc location=sample_4.h264 ! 'video/x-h264' ! h264parse access-unit=true ! omx_h264dec ! mix. 

# Mosaic 4 decoded H.264 elementary streams from a RTP streaming source, each of 1280x720 size, into one video output stream of 1270x720 size
gst-launch omx_videomixer framerate=30 port-index=0 name=mix ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! gstperf ! omx_videosink sync=false rtspsrc location=rtsp://172.24.137.15:5554/Test ! rtph264depay ! h264parse access-unit=true ! omx_h264dec ! mix. rtspsrc location=rtsp://172.24.137.15:5554/Test1 ! rtph264depay ! h264parse access-unit=true ! omx_h264dec ! mix. rtspsrc location=rtsp://172.24.137.15:5554/Test2 ! rtph264depay ! h264parse access-unit=true ! omx_h264dec ! mix. rtspsrc location=rtsp://172.24.137.15:5554/Test3 ! rtph264depay ! h264parse access-unit=true ! omx_h264dec ! mix.

#Other Pipelines
# pipeline to display the videotest pattern using omx sink
gst-launch -v videotestsrc ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink sync=false

# pipeline to color convert videotestsrc pattern from NV12 to YUY2 using HW accelerated omx element and then display using omx sink
gst-launch -v videotestsrc ! omx_scaler ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink sync=false

# pipeline to scale the QVGA video test pattern to VGA
gst-launch -v videotestsrc ! 'video/x-raw-yuv,width=320,height=240' ! omx_scaler ! 'video/x-raw-yuv,width=640,height=480' ! omx_ctrl display-mode=OMX_DC_MODE_1080P_60 ! omx_videosink sync=false -v

# pipeline to encode videotest pattern in H.264
gst-launch -v videotestsrc num-buffers=1000 ! omx_h264enc ! filesink location=sample.264
