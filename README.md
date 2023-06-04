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
<h2>3 Interface</h2>
<img src=https://github.com/polimi-cmls-23/group12-hw-ID-0.5-Musician/assets/118919012/be3e76fe-13db-47f2-a238-75089d28637b>
