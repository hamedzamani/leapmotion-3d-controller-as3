package org.hyzhak.leapmotion.controller3D.intersect {
    import com.leapmotion.leap.Controller;
    import com.leapmotion.leap.Frame;
    import com.leapmotion.leap.Matrix;
    import com.leapmotion.leap.Pointable;
    import com.leapmotion.leap.Vector3;
    import com.leapmotion.leap.events.LeapEvent;

    import flash.events.EventDispatcher;

    import org.hyzhak.utils.MatrixUtil;
    import org.hyzhak.utils.PoolOfObjects;

    [Event(name="hover", type="org.hyzhak.leapmotion.controller3D.intersect.IntersectEvent")]
    [Event(name="unhover", type="org.hyzhak.leapmotion.controller3D.intersect.IntersectEvent")]
    public class LeapMotionIntersectSystem extends EventDispatcher {
        public var transformation:Matrix = Matrix.identity();

        //The timestamp in microseconds.
        public var microsecondToHover:int = 0;

        public var intersectables:IntersectableSystem = new IntersectableSystem();

        private var _poolPointableIntersection:PoolOfObjects = new PoolOfObjects(Intersection);

        private var _controller:Controller;
        private var _childUnderFinger:Vector.<Intersection> = new <Intersection>[];
        private var _previousTime:Number;

        public function LeapMotionIntersectSystem(controller:Controller) {
            _controller = controller;
            _controller.addEventListener(LeapEvent.LEAPMOTION_FRAME, onFrame);
        }

        private function onFrame(event:LeapEvent):void {
            markAsUnprocessed();
            processFrame(event.frame);
            swipeUnprocessed();
        }

        private function processFrame(frame:Frame):void {
            var currentTime:Number = frame.timestamp;
            var deltaTime:Number;
            if (_previousTime > 0) {
                deltaTime = currentTime - _previousTime;
            }
            _previousTime = currentTime;

            var pointables:Vector.<Pointable> = frame.pointables;

            for(var i:int = 0, count:int = pointables.length; i < count; i++) {
                var pointable:Pointable = pointables[i];
                var id:int = pointable.id;

                var vec:Vector3 = MatrixUtil.transformPoint(pointable.tipPosition, transformation);
                var intersectable:IIntersectable = intersectables.getChildAt(vec);
                MatrixUtil.poolOfVector3.returnObject(vec);

                var intersection:Intersection = null;

                if ( id < _childUnderFinger.length) {
                    intersection = _childUnderFinger[id];
                }

                if (intersection && intersection.intersectable == intersectable) {
                    intersection.duration += deltaTime;
                    intersection.unprocessed = false;
                    if (intersection.duration >= microsecondToHover) {
                        hover(intersection, pointable);
                    }
                } else {
                    if (intersection) {
                        unhover(intersection, id);
                    }

                    if (intersectable) {
                        intersection = _poolPointableIntersection.borrowObject();
                        intersection.intersectable = intersectable;
                        intersection.duration = 0;
                        intersection.unprocessed = false;
                        if (_childUnderFinger.length <= id) {
                            _childUnderFinger.length = id + 1;
                        }
                        _childUnderFinger[id] = intersection;
                    }
                }
            }
        }

        private function markAsUnprocessed():void {
            for(var i:int = 0, count:int = _childUnderFinger.length; i < count; i++) {
                var intersection:Intersection = _childUnderFinger[i];
                if (intersection) {
                    intersection.unprocessed = true
                }
            }
        }

        private function swipeUnprocessed():void {
            for(var i:int = 0, count:int = _childUnderFinger.length; i < count; i++) {
                var intersection:Intersection = _childUnderFinger[i];
                if (intersection && intersection.unprocessed) {
                    unhover(intersection, i);
                }
            }
        }

        private function hover(intersection:Intersection, pointable:Pointable):void {
            if (intersection.intersectable.hover(pointable.id, pointable)) {
                dispatchEvent(new IntersectEvent(IntersectEvent.HOVER, intersection.intersectable));
            }
        }

        private function unhover(intersection:Intersection, id:int):void {
            if (intersection == null || intersection.intersectable == null) {
                return;
            }

            if (intersection.intersectable.unhover(id)) {
                dispatchEvent(new IntersectEvent(IntersectEvent.UNHOVER, intersection.intersectable));

                if (_childUnderFinger.length <= id) {
                    throw new Error("Wrong index");
                }
                _childUnderFinger[id] = null;
                intersection.intersectable = null;
                _poolPointableIntersection.returnObject(intersection);
            }
        }
    }
}

import org.hyzhak.leapmotion.controller3D.intersect.IIntersectable;

internal class Intersection {
    public var intersectable:IIntersectable;
    public var duration:int;
    public var unprocessed:Boolean;
}