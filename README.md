<h1>Joystick Controller</h1>
<h2>1 Introduction</h2>
<p>This project aims to design and implement an easy-to-operate multi-effect controller. By manipulating the joystick to different positions, the user can generate different sound effects on instruments, audio or white noise in real-time. This project has also designed and implemented a graphical interface that reflects the sound effects visually. The idea of this project could be applied to the following scenarios：</p>
<ul>
  <li>Simplifying the equipment for live performances： With a joystick to control all the effects, the performers save a lot of effects monoblocks and connection cables.</li>
  <li>ntegration with audio playback devices： Making it easier for users to adjust the audio playback they want.</li>
<h2>2 Scheme</h2>
</ul>
<h3>Overall Structure</h3>
<p>In this project, the Arduino sent the values(x-axis, y-axis and z) read from the analog and digital pins to the SuperCollider by serial port. In Supercollider, different equations for using the x and y axis were set in the algorithm of three different effects. And then retrieve the three values in the array sent from a serial port and set them as arguments in the three effects. Finally, the 3 values from SuperCollider and the values of buttons on GUI are transferred mutually by the OSC protocols.</p>
<img src=https://github.com/polimi-cmls-23/group12-hw-ID-0.5-Musician/assets/118919012/d8800112-b6bf-4775-869a-71ea7ae12b32>
<h4>2.1.1 Serial communication (Arduino-SuperCollider)</h4>
<p>Arduino:</p>
<ul>
  <li>Serial.begin(9600) initializes serial communication with a baud rate of 9600.</li>
  <li>Use ‘Serial.print’ to read the x, y and z values through the serial communication.</li>
  <li>Serial.begin(9600) initializes serial communication with a baud rate of 9600.</li>
</ul>
<p>Use ‘p = SerialPort.new("COM3",9600)’ to open a port so that SuperCollider can read the message sent from Arduino via serial port.</p>
<p>The message received from the serial port is a string. E.g. “516,518,1”.</p>
<p>Use ‘arr=str.split(Char.comma).asInteger’ to convert the string into an integer array.</p>
<p>Use ‘arr.at()’ to retrieve the first, second and third values to the x axis, y axis and z.</p>
<h4>2.2.2 OSC Protocol (SuperCollider – Proccessing)</h4>
<ul>
  <li>var recAddr=NetAddr("127.0.0.1",57120); //receiver</li>
  <li>var sendAddr=NetAddr("127.0.0.1",12000); //sender</li>
</ul>
<ul>
  <li>sender = new NetAddress("127.0.0.1",57120); //send to SC recAddress</li>
  <li>voscP5 = new OscP5(this,12000); //rec</li>
</ul>
<p>In these two parts, loopback IP "127.0.0.1" is set to send messages</p>
<p>Port 12000 is for transferring the data from SuperCollider to Processing, and port 57120 is for transferring backwards.2.2 Arduino and Joystick</p>

  
  
<h1>Interface</h1>
<img src=https://github.com/polimi-cmls-23/group12-hw-ID-0.5-Musician/assets/118919012/a0341ca1-6e90-4951-800f-f1a89d1517d4>
