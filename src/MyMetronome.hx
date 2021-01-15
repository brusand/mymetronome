/*
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.
	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
*/


import haxe.Timer;
import feathers.events.TriggerEvent;
import feathers.controls.Panel;
import openfl.events.Event;
import feathers.layout.VerticalLayout;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextField;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;
import openfl.display.Sprite;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.HProgressBar;
import feathers.controls.HSlider;
import feathers.controls.Label;


class MyMetronome extends Application {
    private var active = false;
    private var startTime:Float;
    private var bpm:Float = 60.0;
    private var bpmDivider:Int = 4;
    private var bpmPulsation:Int = 4;
    private var elapsedTime:Float = 0.0;

    private var progress:HProgressBar;
    private var timeLabel:Label;
    private var bpmSlider:HSlider;
    private var decompteSlider:HSlider;
    private var subTickSlider:HSlider;
    private var resetButton:Button;
    private var sprite:Sprite;
    private var _rect:Sprite;
    private var _circle:Sprite;
    private var _triangle:Sprite;
    private var valueBpm:Label;
    private var valueDecompte:Label;
    private var valueSubTick:Label;
    private var tick: Int = -2;
    private var mesure: Int = -2;
    private var timer:Timer;
    private var subTicksTimer:Timer;
    private var decompte: Sprite;
    private var decompteField: TextField;
    private var decompteMesure:Int=4;
    private var subTick:Int=2;
    private var subTicksCount:Int=0;
    private var play:Button;
    private var stop:Button;
    private var mesures:Array<Sprite> = [];
    private var tickModulo:Int;
    private var radius:Int = 100;

    public function new() {
        super();
        this.layout = new VerticalLayout();

        decompte = new Sprite ();
        decompteField = new TextField();
        decompteField.defaultTextFormat = new TextFormat("_sans", 20, 0xffffff);
        if (tick<0) {
            decompte.graphics.beginFill (0xFFCC00);
            decompteField.text = cast(tick);

        } else {
            decompte.graphics.beginFill (0x00FF00);
            decompteField.text = cast(mesure);
        }
        decompte.graphics.drawCircle (radius, radius, radius);
        decompteField.autoSize = TextFieldAutoSize.CENTER;
        decompteField.x = (decompte.width - decompteField.width) / 2.0;
        decompteField.y = (decompte.height - decompteField.height) / 2.0;

        decompte.addChild (decompteField);
        this.addChild (decompte);


        var container = new LayoutGroup();
        container.layout = new VerticalLayout();
        this.addChild(container);

        var panel = new Panel();
        panel.layout = new HorizontalLayout();


        for (i in 0...bpmDivider) {
            var mySprite = new Sprite ();

            mySprite.graphics.beginFill (0xFFCC00);
            mySprite.graphics.lineStyle (2, 0x990000, .75);
            mySprite.graphics.drawCircle (radius, radius, radius);

            var textField = new TextField();
            textField.defaultTextFormat = new TextFormat("_sans", 20, 0xffffff);
            textField.text = cast( i + 1 );
            textField.autoSize = TextFieldAutoSize.CENTER;
            textField.x = (mySprite.width - textField.width) / 2.0;
            textField.y = (mySprite.height - textField.height) / 2.0;
        
            mySprite.addChild (textField);
            mesures.push(mySprite);
            panel.addChild (mySprite);
        }

        container.addChild (panel);


        var controls = new LayoutGroup();
        controls.layout = new HorizontalLayout();
        this.addChild(controls);

        play = new Button();
        play.text = "Play";
        play.enabled = true;
        play.addEventListener(TriggerEvent.TRIGGER, play_triggerHandler);
        controls.addChild(play);


        stop = new Button();
        stop.text = "Stop";
        stop.enabled = false;
        stop.addEventListener(TriggerEvent.TRIGGER, stop_triggerHandler);
        controls.addChild(stop);


        var options = new LayoutGroup();
        options.layout = new VerticalLayout();

        var optionBpm = new LayoutGroup();
        optionBpm.layout = new HorizontalLayout();

        this.bpmSlider = new HSlider();
        this.bpmSlider.minimum = 10.0;
        this.bpmSlider.maximum = 300.0;
        this.bpmSlider.snapInterval = 10.0;
        this.bpmSlider.value = bpm;
        this.bpmSlider.addEventListener(Event.CHANGE, bpmSlider_changeHandler);


        optionBpm.addChild(this.bpmSlider);

        valueBpm = new Label();
        valueBpm.text =  " " + this.bpmSlider.value;

        optionBpm.addChild(valueBpm);

        var bpmLabel = new Label();
        bpmLabel.text =  " Bpm";

        optionBpm.addChild(bpmLabel);

        options.addChild(optionBpm);


        var optionDecompte = new LayoutGroup();
        optionDecompte.layout = new HorizontalLayout();

        this.decompteSlider = new HSlider();
        this.decompteSlider.minimum = 0.0;
        this.decompteSlider.maximum = 10.0;
        this.decompteSlider.snapInterval = 1.0;
        this.decompteSlider.value = decompteMesure;
        this.decompteSlider.addEventListener(Event.CHANGE, decompteSlider_changeHandler);
        optionDecompte.addChild(this.decompteSlider);

        valueDecompte = new Label();
        valueDecompte.text =  " " + this.decompteSlider.value;
        optionDecompte.addChild(valueDecompte);

        var decompteLabel = new Label();
        decompteLabel.text =  " Decompte";
        optionDecompte.addChild(decompteLabel);

        options.addChild(optionDecompte);


        var optionSubTick = new LayoutGroup();
        optionSubTick.layout = new HorizontalLayout();

        this.subTickSlider = new HSlider();
        this.subTickSlider.minimum = 0.0;
        this.subTickSlider.maximum = 4.0;
        this.subTickSlider.snapInterval = 2.0;
        this.subTickSlider.value = subTick;
        this.subTickSlider.addEventListener(Event.CHANGE, subTickSlider_changeHandler);
        optionSubTick.addChild(this.subTickSlider);

        valueSubTick = new Label();
        valueSubTick.text =  " " + this.subTickSlider.value;
        optionSubTick.addChild(valueSubTick);

        var SubTickLabel = new Label();
        SubTickLabel.text =  " Sub Tick";
        optionSubTick.addChild(SubTickLabel);

        options.addChild(optionSubTick);



        this.addChild(options);


    }

    private function refreshAll():Void {
        valueBpm.text =  " " + this.bpmSlider.value;
        valueDecompte.text =  " " + this.decompteSlider.value;
        valueSubTick.text =  " " + this.subTickSlider.value;
    }

    private function refreshDecompte():Void {

        if (tick > 0) {
            mesures[tickModulo].graphics.beginFill (0xFFCC00);
            mesures[tickModulo].graphics.drawCircle(radius, radius, radius);
            mesures[tickModulo].graphics.endFill();
        }

        tickModulo = tick % bpmDivider;
        if (tick > 0 && tickModulo == 0) {
            mesure += 1;
            if ( mesure == 0 ) mesure = 1;
        }

        mesures[tickModulo].graphics.beginFill (0x00FF00);
        mesures[tickModulo].graphics.drawCircle(radius, radius, radius);
        mesures[tickModulo].graphics.endFill();

        if (mesure < 0) {
            decompte.graphics.beginFill (0xFFCC00);
        } else {
            decompte.graphics.beginFill (0x00FF00);
            decompte.graphics.beginFill (0x00FF00);
            decompte.graphics.drawCircle(radius, radius, radius);
            decompte.graphics.endFill();
        }

        decompteField.text = cast(mesure);
        subTicksCount = 0;

        tick ++; // pour la prochaine loop

    }
    private function refreshSubTicks():Void {
        if (tick > 0 ) {
            if (subTicksCount%subTick != 0) {
                mesures[tickModulo].graphics.beginFill (0xFFCC00);
                mesures[tickModulo].graphics.drawCircle(radius, radius, radius/subTick * subTicksCount%subTick);
                mesures[tickModulo].graphics.endFill();
            }
            subTicksCount++;
        }
    }

    private function bpmSlider_changeHandler(event:Event):Void {
        this.bpm = this.bpmSlider.value;
        this.refreshAll();
    }

    private function decompteSlider_changeHandler(event:Event):Void {
        this.decompteMesure = cast this.decompteSlider.value;
        this.refreshAll();
    }

    private function subTickSlider_changeHandler(event:Event):Void {
        this.subTick = cast this.subTickSlider.value;
        this.refreshAll();
    }

    private function play_triggerHandler(event:TriggerEvent):Void {
        var button = cast(event.currentTarget, Button);
        play.enabled = false;
        stop.enabled = true;

        trace("button triggered: " + button.text);
        // start decompte -1, -2
        tick = 0;
        subTicksCount = 0;
        mesure = - decompteMesure;
        timer = new haxe.Timer(cast(60000/bpm)); // 1000ms delay  30-> 2000 (1 noire = 2 secondes)
        timer.run = function() { 
            refreshDecompte();
        }

        subTicksTimer = new haxe.Timer(cast(60000/bpm/subTick)); // 1000ms delay  sub tick /2  -> /4  /8
        subTicksTimer.run = function() { 
            refreshSubTicks();
        }
    }
    private function stop_triggerHandler(event:TriggerEvent):Void {
        var button = cast(event.currentTarget, Button);
        play.enabled = true;
        stop.enabled = false;
        trace("button triggered: " + button.text);
        timer.stop();
        subTicksTimer.stop();
        tick = 0;
        subTicksCount = 0;
        mesure = - decompteMesure;

        mesures[tickModulo].graphics.beginFill (0xFFCC00);
        mesures[tickModulo].graphics.drawCircle(radius, radius, radius);
        mesures[tickModulo].graphics.endFill();

        tickModulo = 0;
    }

    private function drawWedge(target:Graphics, x:Number, y:Number, startAngle:Number, arc:Number, radius:Number, yRadius:Number = NaN):Void {
        // move to x,y position
        target.moveTo(x, y);
        
        // if yRadius is undefined, yRadius = radius
        if(isNaN(yRadius))
        {
            yRadius = radius;
        }
        
        // limit sweep to reasonable numbers
        if(Math.abs(arc) > 360)
        {
            arc = 360;
        }
        
        // Flash uses 8 segments per circle, to match that, we draw in a maximum
        // of 45 degree segments. First we calculate how many segments are needed
        // for our arc.
        var segs:int = Math.ceil(Math.abs(arc) / 45);
        
        // Now calculate the sweep of each segment.
        var segAngle:Number = arc / segs;
        
        // The math requires radians rather than degrees. To convert from degrees
        // use the formula (degrees/180)*Math.PI to get radians.
        var theta:Number = -(segAngle / 180) * Math.PI;
        
        // convert angle startAngle to radians
        var angle:Number = -(startAngle / 180) * Math.PI;
        
        // draw the curve in segments no larger than 45 degrees.
        if (segs > 0) {
            // draw a line from the center to the start of the curve
            var ax:Number = x + Math.cos(startAngle / 180 * Math.PI) * radius;
            var ay:Number = y + Math.sin(-startAngle / 180 * Math.PI) * yRadius;
            
            target.lineTo(ax, ay);
            
            // Loop for drawing curve segments
            for(var i:int = 0; i < segs; i++)
            {
                angle += theta;
                var angleMid:Number = angle - (theta / 2);
                var bx:Number = x + Math.cos(angle) * radius;
                var by:Number = y + Math.sin(angle) * yRadius;
                var cx:Number = x + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
                var cy:Number = y + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
                target.curveTo(cx, cy, bx, by);
            }
            // close the wedge by drawing a line to the center
            target.lineTo(x, y);
        }

    }
}
