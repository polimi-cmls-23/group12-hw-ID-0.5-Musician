// SynthDefs and SerialPort initialization code (same as before)
SerialPort.devices;
p = SerialPort.new("COM3",9600);
s.boot;
b = Buffer.read(s,"C:/Users/pc/Desktop/CMLS/HW1/Guitar.wav");
//p.close;


(
SynthDef(\noise,{
	arg inBus = 0, outBus = 0;
	var in, out;

	out = 0.4 * WhiteNoise.ar(0.5).dup;

	Out.ar(outBus, Pan2.ar(out));

}).add;

SynthDef(\wah,{
	arg mix=0, freqBand=0, bw=0, inBus, outBus;
	var sgn,x_n,x_n_out,y_n;

	// x_n = PlayBuf.ar(2, 0, BufRateScale.kr(0), doneAction: Done.freeSelf);  //use this line for wav file
	x_n = In.ar(inBus, 2);  //uncomment this line for white noise input
	//x = {SoundIn.ar(0!2)}.play; //uncomment this line for instrument in

	freqBand = 1 - freqBand;
	sgn = BBandPass.ar(x_n, 2599*freqBand+300, 3*bw+0.05, mix);

	// y_n = Mix.ar([x_n * (1-mix), sgn * mix]); mix will make single channel
	y_n = (0.6 * x_n * (1-mix)) + (sgn * mix);
	Out.ar(outBus, Pan2.ar(y_n));

}).add;

SynthDef(\phaser, {
	arg inBus, outBus, freq1 = 500, freq2 = 1000, freq3 = 3000, freq4 = 5000, kfreq = 0, kmul = 0, rq = 1, depth = 0, num = 0;
    var input, sig, dry, wet1, wet2, wet3, out;

    input = In.ar(inBus, 2);
	dry = input;
	kmul = kmul * 500;
	kfreq = kfreq * 8;

	sig = SelectX.ar(
		num.varlag(1),
		[
			BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq, depth),
			wet1 = BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq, depth); BAllPass.ar(wet1, SinOsc.kr(kfreq, 0, kmul, freq2), rq, depth),
			wet1 = BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq, depth);	wet2 = BAllPass.ar(wet1, SinOsc.kr(kfreq, 0, kmul, freq2), rq, depth); wet3 = BAllPass.ar(wet2, SinOsc.kr(kfreq, 0, kmul, freq3), rq, depth); BAllPass.ar(wet3, SinOsc.kr(kfreq, 0, kmul, freq4), rq, depth);
		]
	);

	out = dry + (sig * depth);
	Out.ar(outBus, Pan2.ar((0.6-(0.1 * depth)) * out));

}).add;

SynthDef(\flanger, {
	arg inBus, outBus, bufnum, rate=0, width=0, feedback=0, mix=0; //width:0.1-2.5
    var inSig, outSig, lfo, delay, mixed;

	inSig = In.ar(inBus, 2);

	lfo = SinOsc.kr(rate * 5, 0, 0.001 * width * 2); // *2 cause slider, dial only support 0-1. also normalizes every gui para.
	delay = CombL.ar(inSig, 0.01, 0.0025 + lfo, 0.05 * feedback, 1, 0);
	mix = 0.5 * mix;
	mixed = (inSig * (1-mix)) + (delay * mix);
    // 输出
	Out.ar(outBus, Pan2.ar(0.6 * mixed));

}).add;
)


////////////////////////////Processing////////////////////////////////////
//#######################################################################################

r.stop;

(
var recAddr=NetAddr("127.0.0.1",57120);   //receiver
var sendAddr=NetAddr("127.0.0.1",12000);  //sender

OSCdef('OSCreceiver',

	{
		arg msg;//addr= recAddr;
		~mode = msg[1];
		~play = msg[2];
	},
	"/mode");


~wah = Synth("wah", [\inBus, 4, \outBus, 0, \mix, 1]);
~pha = Synth("phaser", [\inBus, 4, \outBus, 6, \depth, 1, \num, 1]);
~fla = Synth("flanger", [\inBus, 4, \outBus, 6, \mix, 1, \feedback, 0.2]);
//n = Synth("noise", [\outBus, 4]);
//~wah.set(\mix, 1, \bw, 0.5);

r= Routine({
	var byte, str, res, x, y, z, arr, snd = SoundIn.ar(0!2);
	var buttonState = 1; // Initial button state is 1 (not pressed)
	var counter = 0; // Initialize counter to 0
	var lastButtonState = 1; // Initialize last button state to 1 (not pressed)
	var playState = 1; // Initial play state is 1 (not pressed)
	var lastplayState = 1; // Initialize last play state to 1 (not pressed)
	var stateCounter = 0;
    9999.do{|i|

		//~mode.postln;
		//~play.postln;

        if(p.read == Char.nl.asInteger, {   //newline
            str = "";
            while({byte = p.read; byte != Char.ret.asInteger }, {   //return
                str= str++byte.asAscii;
            });
            //("read value:"+str).postln;    //String
			arr = str.split(Char.comma).asInteger;
			//arr.class.postln;   //Array
			x = arr.at(0);
			y = arr.at(1);
			z = arr.at(2);
			//x.postln;
			sendAddr.sendMsg(\data, x,y,z);
			//x.class.postln;
			x = x / 1023;
			y = y / 1023;


			~wah.set(\freqBand, x);
			~wah.set(\bw, y);
			~pha.set(\kfreq, x);
			~pha.set(\kmul, y);
			~fla.set(\rate, x);
			~fla.set(\width, y);

			if (z != buttonState, { // Detect button state change
				lastButtonState = buttonState;
				buttonState = z;

				if (buttonState == 0 && lastButtonState == 1, { // Button changed from not pressed to pressed
					stateCounter = stateCounter + 1;
					switch (stateCounter % 3,
						0, {
							("Wah").postln;
							~fla.set(\inBus, 4, \outBus, 6);
							~wah.set(\inBus, 4, \outBus, 0);
							//~wah.set(\freqBand, x); ~wah.set(\bw, y);
						},


						1, { // SynthDef 2: phaser
							("phaser").postln;
							~wah.set(\inBus, 4, \outBus, 6);
							~pha.set(\inBus, 4, \outBus, 0);
							//~phaser.set(\kfreq, x); ~phaser.set(\kmul, y)
						},


						2, {// SynthDef 3: flanger
							("Flanger").postln;
							~pha.set(\inBus, 4, \outBus, 6);
							~fla.set(\inBus, 4, \outBus, 0);
							//~flanger.set(\rate, x); ~flanger.set(\width, y);
						},
					);

				},{});
			},{});


			// Update parameters of the active SynthDef based on x and y values

		},{});

		if (~play != playState, { // Detect play state change
			lastplayState = playState;
			playState = ~play;
			if (playState == 1 && lastplayState == 0, {
				switch (~mode,
					0, {
						g = {Out.ar(4, SoundIn.ar(0!2))}.play;
						('instrument').postln
					},

					1, {
						g = {Out.ar(4, PlayBuf.ar(2, 0, BufRateScale.kr(0), doneAction: Done.freeSelf))}.play;
						('demo').postln
					},

					2, {
						g = {Out.ar(4, 0.5 * WhiteNoise.ar(0.5).dup)}.play;
						('whitenoise').postln
					},
				);
				('play').postln;
			},{
				g.free;
				('stop').postln;
			});
		},{});
    };
}).play;
)


r.stop;






/*(
var funcs,menu,snd;
w = Window("my Window", Rect(200, 200, 200, 100));

menu = PopUpMenu(w, Rect(10, 10, 90, 20)).items_(["Instrument", "Demo", "WhiteNoise"]);

funcs = [
	{ SoundIn.ar(0!2) },
	{ PlayBuf.ar(2, 0, BufRateScale.kr(0), doneAction: Done.freeSelf) },
	{ 0.4 * WhiteNoise.ar(0.5).dup }
	];
w.front;


b = Button(w, Rect(110, 10, 180, 20))
 .states_([["play", Color.black, Color.green], ["stop", Color.black, Color.red]])
 .mouseDownAction_({
  snd = funcs.at(menu.value);

  //snd = menu.value;
 })
 .action_({ arg obj; //arg butt, mod;
  if(obj.value == 1) { k = {Out.ar(4, snd)}.play; obj.value.postln;} { k.free; obj.value.postln;}
  //snd.release;
 });
)*/




