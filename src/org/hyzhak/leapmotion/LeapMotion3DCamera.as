package org.hyzhak.leapmotion {
    import com.leapmotion.leap.Controller;
    import com.leapmotion.leap.Finger;
    import com.leapmotion.leap.Frame;
    import com.leapmotion.leap.Hand;
    import com.leapmotion.leap.Vector3;
    import com.leapmotion.leap.events.LeapEvent;
    import com.leapmotion.leap.util.LeapUtil;

    import flash.display.Sprite;

    public class LeapMotion3DCamera extends Sprite {

        private var _controller:Controller;

        public function LeapMotion3DCamera() {
            super();
            init();
        }

        private function init():void {
            _controller = new Controller();
            _controller.addEventListener( LeapEvent.LEAPMOTION_INIT, onInit );
            _controller.addEventListener( LeapEvent.LEAPMOTION_CONNECTED, onConnect );
            _controller.addEventListener( LeapEvent.LEAPMOTION_DISCONNECTED, onDisconnect );
            _controller.addEventListener( LeapEvent.LEAPMOTION_EXIT, onExit );
            _controller.addEventListener( LeapEvent.LEAPMOTION_FRAME, onFrame );
        }

        private function onInit(event:LeapEvent):void {
            trace("onInit");
        }

        private function onConnect(event:LeapEvent):void {
            trace("onConnect");
        }

        private function onDisconnect(event:LeapEvent):void {
            trace("onDisconnect");
        }

        private function onExit(event:LeapEvent):void {
            trace("onExit");
        }

        private function onFrame(event:LeapEvent):void {
            // Get the most recent frame and report some basic information
            var frame:Frame = event.frame;
            trace( "Frame id: " + frame.id + ", timestamp: " + frame.timestamp + ", hands: " + frame.hands.length + ", fingers: " + frame.fingers.length + ", tools: " + frame.tools.length );

            if ( frame.hands.length > 0 )
            {
                // Get the first hand
                var hand:Hand = frame.hands[ 0 ];

                // Check if the hand has any fingers
                var fingers:Vector.<Finger> = hand.fingers;
                if ( fingers.length > 0 )
                {
                    // Calculate the hand's average finger tip position
                    var avgPos:Vector3 = Vector3.zero();
                    for each ( var finger:Finger in fingers )
                        avgPos = avgPos.plus( finger.tipPosition );

                    avgPos = avgPos.divide( fingers.length );
                    trace( "Hand has " + fingers.length + " fingers, average finger tip position: " + avgPos );
                }

                // Get the hand's sphere radius and palm position
                trace( "Hand sphere radius: " + hand.sphereRadius + " mm, palm position: " + hand.palmPosition );

                // Get the hand's normal vector and direction
                var normal:Vector3 = hand.palmNormal;
                var direction:Vector3 = hand.direction;

                // Calculate the hand's pitch, roll, and yaw angles
                trace( "Hand pitch: " + LeapUtil.toDegrees( direction.pitch ) + " degrees, " + "roll: " + LeapUtil.toDegrees( normal.roll ) + " degrees, " + "yaw: " + LeapUtil.toDegrees( direction.yaw ) + " degrees\n" );
            }
        }
    }
}
