"""Original synthesized ability sounds; no external samples."""
import math,random,struct,wave
from pathlib import Path
root=Path(__file__).resolve().parents[1]/'assets/audio'
rng=random.Random(522)
rate=22050
for name,duration in [('dash',.30),('seismic',.60),('orb',.38),('blink',.28),('frost',.65),('bolt',.16)]:
 samples=[]
 for i in range(int(rate*duration)):
  t=i/rate;u=t/duration;n=rng.uniform(-1,1)
  attack=min(1,u*25);decay=(1-u)**2;env=attack*decay
  if name=='dash':v=n*.5*math.sin(math.pi*u)**2+math.sin(math.tau*(180*t-180*t*t))*.1*env
  elif name=='seismic':v=(math.sin(math.tau*(70*t-40*t*t))*.65+n*.2)*env
  elif name=='orb':v=(math.sin(math.tau*(260*t+300*t*t))*.3+math.sin(math.tau*390*t)*.13)*env
  elif name=='blink':v=(math.sin(math.tau*(900*t-1100*t*t))*.3+n*.08)*env
  elif name=='frost':v=(math.sin(math.tau*1300*t)*.10+math.sin(math.tau*1783*t)*.07+n*.09)*env*(.6+.4*math.sin(t*40)**2)
  else:v=math.sin(math.tau*(650*t-900*t*t))*.25*env
  samples.append(struct.pack('<h',int(max(-.85,min(.85,v))*32767)))
 with wave.open(str(root/(name+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(b''.join(samples))
print('six original ability sounds written')
