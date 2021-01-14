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
    private var bpm:Float = 0.0;
    private var elapsedTime:Float = 0.0;

    private var progress:HProgressBar;
    private var timeLabel:Label;
    private var bpmSlider:HSlider;
    private var resetButton:Button;
    private var sprite:Sprite;
    private var _rect:Sprite;
    private var _circle:Sprite;
    private var _triangle:Sprite;
    private var valueBpm:Label;
    private var tick: Int = -2;
    private var mesure: Int = 1;
    private var timer:Timer;
    private var decompte: Sprite;
    private var decompteField: TextField;
    private var play:Button;
    private var stop:Button;

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
        decompte.graphics.drawCircle (50, 50, 50);
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

        var radius = 50;
        
        var mySprite = new Sprite ();
        mySprite.graphics.beginFill (0xFFCC00);
        mySprite.graphics.drawCircle (radius, radius, radius);

        var textField = new TextField();
        textField.defaultTextFormat = new TextFormat("_sans", 20, 0xffffff);
        textField.text = "1";
        textField.autoSize = TextFieldAutoSize.CENTER;
        textField.x = (mySprite.width - textField.width) / 2.0;
        textField.y = (mySprite.height - textField.height) / 2.0;
  
        mySprite.addChild (textField);
        panel.addChild (mySprite);

        //draw circle
        _circle = new Sprite();
        _circle.graphics.beginFill(0x00FF00);
        _circle.graphics.drawCircle(radius, radius, radius);
        _circle.graphics.endFill();

        panel.addChild(_circle);

        _circle = new Sprite();
        _circle.graphics.beginFill(0x00FF00);
        _circle.graphics.drawCircle(radius, radius, radius);
        _circle.graphics.endFill();
        panel.addChild(_circle);

        _circle = new Sprite();
        _circle.graphics.beginFill(0x00FF00);
        _circle.graphics.drawCircle(radius, radius, radius);
        _circle.graphics.endFill();

        panel.addChild(_circle);


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
        this.bpmSlider.step = 10.0;
        this.bpmSlider.value = 60.0;
        this.bpmSlider.addEventListener(Event.CHANGE, bpmSlider_changeHandler);


        optionBpm.addChild(this.bpmSlider);

        valueBpm = new Label();
        valueBpm.text =  " " + this.bpmSlider.value;

        optionBpm.addChild(valueBpm);

        var bpm = new Label();
        bpm.text =  " Bpm";

        optionBpm.addChild(bpm);

        options.addChild(optionBpm);

        this.addChild(options);


    }

    private function refreshAll():Void {
        valueBpm.text =  " " + cast(this.bpmSlider.value);
    }
    private function refreshDecompte():Void {
        if (tick<0) {
            decompte.graphics.beginFill (0xFFCC00);
            decompteField.text = cast(tick);

        } else {
            decompte.graphics.beginFill (0x00FF00);
            decompteField.text = cast(mesure);
            mesure += 1;
        }
        refreshAll();
    }
    private function bpmSlider_changeHandler(event:Event):Void {
        this.bpm = this.bpmSlider.value;
        this.refreshAll();
    }

    private function play_triggerHandler(event:TriggerEvent):Void {
        var button = cast(event.currentTarget, Button);
        play.enabled = false;
        stop.enabled = true;

        trace("button triggered: " + button.text);
        // start decompte -1, -2
        tick = 0;
        mesure = 1;
        timer = new haxe.Timer(cast(60000/bpm)); // 1000ms delay
        timer.run = function() { 
            tick += 1;
            refreshDecompte();
        }
    
    }
    private function stop_triggerHandler(event:TriggerEvent):Void {
        var button = cast(event.currentTarget, Button);
        play.enabled = true;
        stop.enabled = false;
        trace("button triggered: " + button.text);
        timer.stop();
        tick = 0;
        mesure = 1;
        refreshDecompte();
    }
}
